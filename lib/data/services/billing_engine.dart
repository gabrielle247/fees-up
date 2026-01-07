/// ============================================================================
/// BILLING ENGINE - ADVANCED FEES UP BILLING SYSTEM
/// ============================================================================
/// 
/// This module provides a comprehensive billing engine that handles:
/// - Multiple billing types (tuition, transport, meals, custom)
/// - Mid-cycle billing switches with prorating
/// - Billing suspensions and resumptions
/// - Complex fee structures and adjustments
/// - Bulk billing operations
/// - Financial reconciliation
///
/// Author: Nyasha Gabriel / Batch Tech
/// Date: January 3, 2026
/// Status: Production-Ready
library billing_engine;

import 'dart:math';
import '../models/billing/billing_configuration.dart';
import '../models/billing/billing_switch.dart';
import '../models/billing/generated_bill.dart';

export '../models/billing/billing_configuration.dart';
export '../models/billing/billing_switch.dart';
export '../models/billing/generated_bill.dart';

// ============================================================================
// PRORATION CALCULATOR
// ============================================================================

class ProratingCalculator {
  /// Calculate prorated amount for partial billing period
  static double calculateProration({
    required double fullAmount,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime actualStart,
    required DateTime actualEnd,
  }) {
    final totalDays = periodEnd.difference(periodStart).inDays + 1;
    final applicableDays = actualEnd.difference(actualStart).inDays + 1;

    if (applicableDays <= 0) return 0.0;

    final rate = fullAmount / totalDays;
    return rate * applicableDays;
  }

  /// Calculate daily rate for a fee
  static double calculateDailyRate({
    required double monthlyAmount,
    int daysInMonth = 30,
  }) =>
      monthlyAmount / daysInMonth;

  /// Calculate late fee
  static double calculateLateFee({
    required double outstandingAmount,
    double? percentageRate,
    double? minFee,
    double? maxFee,
  }) {
    if (percentageRate == null) return 0.0;

    var fee = outstandingAmount * (percentageRate / 100.0);

    if (minFee != null && fee < minFee) fee = minFee;
    if (maxFee != null && fee > maxFee) fee = maxFee;

    return fee;
  }

  /// Calculate next billing date based on frequency
  static DateTime calculateNextBillingDate({
    required DateTime lastBillingDate,
    required BillingFrequency frequency,
    required int billingDay,
  }) {
    switch (frequency) {
      case BillingFrequency.daily:
        return lastBillingDate.add(const Duration(days: 1));
      case BillingFrequency.weekly:
        return lastBillingDate.add(const Duration(days: 7));
      case BillingFrequency.monthly:
        var nextDate = DateTime(
          lastBillingDate.year,
          lastBillingDate.month + 1,
          min(billingDay, _getDaysInMonth(lastBillingDate.year, lastBillingDate.month + 1)),
        );
        return nextDate;
      case BillingFrequency.termly:
        return lastBillingDate.add(const Duration(days: 90));
      case BillingFrequency.annually:
        return DateTime(lastBillingDate.year + 1, lastBillingDate.month, billingDay);
      case BillingFrequency.custom:
        return lastBillingDate.add(const Duration(days: 30));
    }
  }

  static int _getDaysInMonth(int year, int month) {
    if (month > 12) {
      year += 1;
      month -= 12;
    }
    if ([1, 3, 5, 7, 8, 10, 12].contains(month)) return 31;
    if ([4, 6, 9, 11].contains(month)) return 30;
    return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
  }
}

// ============================================================================
// MAIN BILLING ENGINE
// ============================================================================

class BillingEngine {
  final String schoolId;
  final Map<String, BillingConfiguration> _configCache = {};
  final Map<String, List<BillingSwitch>> _switchHistory = {};

  BillingEngine({required this.schoolId});

  /// Register a billing configuration
  void registerBillingConfig(BillingConfiguration config) {
    _configCache[config.id] = config;
  }

  /// Get applicable billing configuration for a student
  BillingConfiguration? getApplicableConfig({
    required String gradeLevel,
    required DateTime asOfDate,
  }) {
    final configs = _configCache.values.where((config) {
      final isGradeMatch =
          config.gradeLevel == gradeLevel;
      final isEffective = config.effectiveFrom.isBefore(asOfDate) &&
          (config.effectiveUntil == null ||
              config.effectiveUntil!.isAfter(asOfDate));
      return isGradeMatch && isEffective && config.isActive;
    }).toList();

    if (configs.isEmpty) return null;

    // Return most specific (grade-level specific) config
    return configs.firstWhere(
      (c) => c.gradeLevel.isNotEmpty,
      orElse: () => configs.first,
    );
  }

  /// Generate bills for a student for a given period
  List<GeneratedBill> generateBillsForPeriod({
    required String studentId,
    required String studentName,
    required String gradeLevel,
    required DateTime periodStart,
    required DateTime periodEnd,
    required BillingConfiguration config,
  }) {
    final bills = <GeneratedBill>[];
    var currentDate = DateTime(periodStart.year, periodStart.month, config.billingDay);

    // Adjust if start date is after calculated billing date
    if (currentDate.isBefore(periodStart)) {
      currentDate = ProratingCalculator.calculateNextBillingDate(
        lastBillingDate: currentDate,
        frequency: config.frequency,
        billingDay: config.billingDay,
      );
    }

    while (currentDate.isBefore(periodEnd)) {
      final dueDate = DateTime(
        currentDate.year,
        currentDate.month,
        min(config.dueDay, _getDaysInMonth(currentDate.year, currentDate.month)),
      );

      final lineItems = config.feeComponents
          .where((fc) => fc.isApplicable && !fc.isOptional)
          .map((fc) => BillLineItem(
                type: fc.type,
                description: fc.name,
                unitPrice: fc.amount,
              ))
          .toList();

      if (lineItems.isNotEmpty) {
        bills.add(GeneratedBill(
          schoolId: schoolId,
          studentId: studentId,
          studentName: studentName,
          gradeLevel: gradeLevel,
          billingDate: currentDate,
          dueDate: dueDate,
          lineItems: lineItems,
          frequency: config.frequency.code,
        ));
      }

      currentDate = ProratingCalculator.calculateNextBillingDate(
        lastBillingDate: currentDate,
        frequency: config.frequency,
        billingDay: config.billingDay,
      );
    }

    return bills;
  }

  /// Handle mid-cycle billing switch
  List<GeneratedBill> processBillingSwitch({
    required String studentId,
    required String studentName,
    required String gradeLevel,
    required BillingSwitch billSwitch,
    required DateTime lastBillingDate,
  }) {
    final bills = <GeneratedBill>[];

    // Generate prorated bill for remainder of old config
    if (billSwitch.effectiveDate.isAfter(lastBillingDate)) {
      final nextBillingDate = ProratingCalculator.calculateNextBillingDate(
        lastBillingDate: lastBillingDate,
        frequency: billSwitch.oldConfig.frequency,
        billingDay: billSwitch.oldConfig.billingDay,
      );

      if (nextBillingDate.isAfter(billSwitch.effectiveDate)) {
        final proratedAmount = ProratingCalculator.calculateProration(
          fullAmount: billSwitch.oldConfig.calculateTotalFee(),
          periodStart: lastBillingDate,
          periodEnd: nextBillingDate,
          actualStart: lastBillingDate,
          actualEnd: billSwitch.effectiveDate.subtract(const Duration(days: 1)),
        );

        final lineItems = billSwitch.oldConfig.feeComponents
            .where((fc) => fc.isApplicable && !fc.isOptional)
            .map((fc) {
              final proratedFee = (fc.amount / billSwitch.oldConfig.calculateTotalFee()) *
                  proratedAmount;
              return BillLineItem(
                type: fc.type,
                description: '${fc.name} (Prorated to ${billSwitch.effectiveDate.day}-${lastBillingDate.add(Duration(days: (nextBillingDate.difference(lastBillingDate).inDays))).day})',
                unitPrice: proratedFee,
              );
            })
            .toList();

        if (lineItems.isNotEmpty) {
          bills.add(GeneratedBill(
            schoolId: schoolId,
            studentId: studentId,
            studentName: studentName,
            gradeLevel: gradeLevel,
            billingDate: lastBillingDate,
            dueDate: DateTime(
              billSwitch.effectiveDate.year,
              billSwitch.effectiveDate.month,
              min(billSwitch.oldConfig.dueDay,
                  _getDaysInMonth(billSwitch.effectiveDate.year, billSwitch.effectiveDate.month)),
            ),
            lineItems: lineItems,
            frequency: billSwitch.oldConfig.frequency.code,
            isSwitchBill: true,
          ));
        }
      }
    }

    // Generate first bill with new config
    final newConfigBills = generateBillsForPeriod(
      studentId: studentId,
      studentName: studentName,
      gradeLevel: gradeLevel,
      periodStart: billSwitch.effectiveDate,
      periodEnd: billSwitch.effectiveDate.add(const Duration(days: 90)),
      config: billSwitch.newConfig,
    );

    bills.addAll(newConfigBills);
    _switchHistory.putIfAbsent(studentId, () => []).add(billSwitch);

    return bills;
  }

  /// Calculate all outstanding charges for a student
  double calculateOutstandingBalance({
    required double unpaidBillsTotal,
    required double lateFees,
    required double adjustments,
  }) =>
      unpaidBillsTotal + lateFees - adjustments.abs();

  /// Get billing history for a student
  List<BillingSwitch> getBillingHistory(String studentId) =>
      _switchHistory[studentId] ?? [];

  static int _getDaysInMonth(int year, int month) {
    if ([1, 3, 5, 7, 8, 10, 12].contains(month)) return 31;
    if ([4, 6, 9, 11].contains(month)) return 30;
    return (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)) ? 29 : 28;
  }
}

// ============================================================================
// UTILITY: BATCH BILLING OPERATIONS
// ============================================================================

class BatchBillingProcessor {
  final BillingEngine engine;
  final List<GeneratedBill> generatedBills = [];
  final List<String> processingErrors = [];

  BatchBillingProcessor({required this.engine});

  /// Process billing for multiple students
  Future<void> processBulkBilling({
    required List<Map<String, dynamic>> students, // {id, name, gradeLevel, ...}
    required BillingConfiguration config,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    for (final student in students) {
      try {
        final bills = engine.generateBillsForPeriod(
          studentId: student['id'] as String,
          studentName: student['name'] as String,
          gradeLevel: student['gradeLevel'] as String,
          periodStart: periodStart,
          periodEnd: periodEnd,
          config: config,
        );
        generatedBills.addAll(bills);
      } catch (e) {
        processingErrors.add(
          'Failed to generate bill for ${student['name']}: $e',
        );
      }
    }
  }

  /// Get summary of batch processing
  Map<String, dynamic> getSummary() => {
        'totalBillsGenerated': generatedBills.length,
        'totalAmount': generatedBills.fold(0.0, (sum, bill) => sum + bill.total),
        'processedStudents': generatedBills.map((b) => b.studentId).toSet().length,
        'errors': processingErrors,
        'errorCount': processingErrors.length,
      };
}
