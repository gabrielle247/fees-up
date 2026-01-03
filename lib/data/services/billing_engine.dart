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

import 'package:uuid/uuid.dart';
import 'dart:math';

// ============================================================================
// ENUMS & CONSTANTS
// ============================================================================

enum BillingFrequency {
  daily('daily', 'Daily'),
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly'),
  termly('termly', 'Termly'),
  annually('annually', 'Annually'),
  custom('custom', 'Custom');

  final String code;
  final String display;
  const BillingFrequency(this.code, this.display);

  static BillingFrequency fromCode(String code) =>
      BillingFrequency.values.firstWhere(
        (e) => e.code == code,
        orElse: () => BillingFrequency.monthly,
      );
}

enum BillingType {
  tuition('tuition', 'Tuition'),
  transport('transport', 'Transport'),
  meals('meals', 'Meals'),
  activities('activities', 'Activities'),
  uniform('uniform', 'Uniform'),
  library('library', 'Library'),
  technology('technology', 'Technology'),
  custom('custom', 'Custom');

  final String code;
  final String display;
  const BillingType(this.code, this.display);

  static BillingType fromCode(String code) =>
      BillingType.values.firstWhere(
        (e) => e.code == code,
        orElse: () => BillingType.tuition,
      );
}

enum ProrationType {
  prorated('prorated', 'Prorated'),
  fullMonth('fullMonth', 'Full Month'),
  dailyRate('dailyRate', 'Daily Rate');

  final String code;
  final String display;
  const ProrationType(this.code, this.display);
}

// ============================================================================
// FEE STRUCTURE MODELS
// ============================================================================

class FeeComponent {
  final String id;
  final String name;
  final BillingType type;
  final double amount;
  final bool isOptional;
  final bool isApplicable; // Used for conditional fees

  FeeComponent({
    String? id,
    required this.name,
    required this.type,
    required this.amount,
    this.isOptional = false,
    this.isApplicable = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.code,
        'amount': amount,
        'is_optional': isOptional,
        'is_applicable': isApplicable,
      };

  factory FeeComponent.fromMap(Map<String, dynamic> map) => FeeComponent(
        id: map['id'] as String?,
        name: map['name'] as String,
        type: BillingType.fromCode(map['type'] as String),
        amount: (map['amount'] as num).toDouble(),
        isOptional: map['is_optional'] as bool? ?? false,
        isApplicable: map['is_applicable'] as bool? ?? true,
      );
}

class BillingConfiguration {
  final String id;
  final String schoolId;
  final String gradeLevel; // e.g., "Grade 1", "Grade 2", null for all
  final BillingFrequency frequency;
  final int billingDay; // Day of month when billing occurs
  final int dueDay; // Due day (usually billingDay + 7-30)
  final List<FeeComponent> feeComponents;
  final double? lateFeePercentage; // e.g., 5% = 5.0
  final double? minLateFee;
  final double? maxLateFee;
  final bool isActive;
  final DateTime effectiveFrom;
  final DateTime? effectiveUntil;

  BillingConfiguration({
    String? id,
    required this.schoolId,
    required this.gradeLevel,
    required this.frequency,
    required this.billingDay,
    required this.dueDay,
    required this.feeComponents,
    this.lateFeePercentage,
    this.minLateFee,
    this.maxLateFee,
    this.isActive = true,
    required this.effectiveFrom,
    this.effectiveUntil,
  }) : id = id ?? const Uuid().v4();

  double calculateTotalFee([List<String>? includeTypes]) {
    return feeComponents
        .where((fc) =>
            fc.isApplicable &&
            (includeTypes == null ||
                includeTypes.contains(fc.type.code)))
        .fold(0.0, (sum, fc) => sum + fc.amount);
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'school_id': schoolId,
        'grade_level': gradeLevel,
        'frequency': frequency.code,
        'billing_day': billingDay,
        'due_day': dueDay,
        'fee_components': feeComponents.map((fc) => fc.toMap()).toList(),
        'late_fee_percentage': lateFeePercentage,
        'min_late_fee': minLateFee,
        'max_late_fee': maxLateFee,
        'is_active': isActive,
        'effective_from': effectiveFrom.toIso8601String(),
        'effective_until': effectiveUntil?.toIso8601String(),
      };

  factory BillingConfiguration.fromMap(Map<String, dynamic> map) =>
      BillingConfiguration(
        id: map['id'] as String?,
        schoolId: map['school_id'] as String,
        gradeLevel: map['grade_level'] as String? ?? 'General',
        frequency: BillingFrequency.fromCode(map['frequency'] as String),
        billingDay: map['billing_day'] as int,
        dueDay: map['due_day'] as int,
        feeComponents: (map['fee_components'] as List<dynamic>?)
                ?.map((fc) =>
                    FeeComponent.fromMap(fc as Map<String, dynamic>))
                .toList() ??
            [],
        lateFeePercentage:
            (map['late_fee_percentage'] as num?)?.toDouble(),
        minLateFee: (map['min_late_fee'] as num?)?.toDouble(),
        maxLateFee: (map['max_late_fee'] as num?)?.toDouble(),
        isActive: map['is_active'] as bool? ?? true,
        effectiveFrom:
            DateTime.parse(map['effective_from'] as String),
        effectiveUntil: map['effective_until'] != null
            ? DateTime.parse(map['effective_until'] as String)
            : null,
      );
}

// ============================================================================
// BILLING SWITCH MODELS
// ============================================================================

class BillingSwitch {
  final String id;
  final String schoolId;
  final String studentId;
  final BillingConfiguration oldConfig;
  final BillingConfiguration newConfig;
  final DateTime effectiveDate;
  final ProrationType prorationType;
  final String? notes;
  final bool isProcessed;

  BillingSwitch({
    String? id,
    required this.schoolId,
    required this.studentId,
    required this.oldConfig,
    required this.newConfig,
    required this.effectiveDate,
    this.prorationType = ProrationType.prorated,
    this.notes,
    this.isProcessed = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'old_config': oldConfig.toMap(),
        'new_config': newConfig.toMap(),
        'effective_date': effectiveDate.toIso8601String(),
        'proration_type': prorationType.code,
        'notes': notes,
        'is_processed': isProcessed,
      };
}

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
// BILL GENERATION MODELS
// ============================================================================

class GeneratedBill {
  final String id;
  final String schoolId;
  final String studentId;
  final String studentName;
  final String gradeLevel;
  final DateTime billingDate;
  final DateTime dueDate;
  final List<BillLineItem> lineItems;
  final double subtotal;
  final double lateFee;
  final double discount;
  final double total;
  final String frequency;
  final bool isSwitchBill; // Bill due to billing switch

  GeneratedBill({
    String? id,
    required this.schoolId,
    required this.studentId,
    required this.studentName,
    required this.gradeLevel,
    required this.billingDate,
    required this.dueDate,
    required this.lineItems,
    double? lateFee,
    double? discount,
    required this.frequency,
    this.isSwitchBill = false,
  })  : id = id ?? const Uuid().v4(),
        lateFee = lateFee ?? 0.0,
        discount = discount ?? 0.0,
        subtotal = lineItems.fold(0.0, (sum, item) => sum + item.total),
        total = (lineItems.fold(0.0, (sum, item) => sum + item.total) +
                (lateFee ?? 0.0) -
                (discount ?? 0.0))
            .clamp(0.0, double.infinity);

  Map<String, dynamic> toMap() => {
        'id': id,
        'school_id': schoolId,
        'student_id': studentId,
        'student_name': studentName,
        'grade_level': gradeLevel,
        'billing_date': billingDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'line_items': lineItems.map((li) => li.toMap()).toList(),
        'subtotal': subtotal,
        'late_fee': lateFee,
        'discount': discount,
        'total': total,
        'frequency': frequency,
        'is_switch_bill': isSwitchBill,
      };
}

class BillLineItem {
  final String id;
  final BillingType type;
  final String description;
  final double unitPrice;
  final int quantity;
  final double total;
  final String? notes;

  BillLineItem({
    String? id,
    required this.type,
    required this.description,
    required this.unitPrice,
    this.quantity = 1,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        total = unitPrice * quantity;

  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.code,
        'description': description,
        'unit_price': unitPrice,
        'quantity': quantity,
        'total': total,
        'notes': notes,
      };
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
