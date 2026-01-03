/// ============================================================================
/// BILLING REPOSITORY - DATABASE & API OPERATIONS
/// ============================================================================
library billing_repository;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../services/billing_engine.dart';

/// Helper function for debug logging
void debugPrintError(String message) {
  if (kDebugMode) {
    debugPrint('[ERROR] $message');
  }
}

class BillingRepository {
  final SupabaseClient supabase;

  BillingRepository({required this.supabase});

  /// Fetch all billing configurations for a school
  Future<List<BillingConfiguration>> fetchBillingConfigurations(
      String schoolId) async {
    try {
      final response = await supabase
          .from('billing_configurations')
          .select()
          .eq('school_id', schoolId)
          .eq('is_active', true)
          .order('effective_from', ascending: false);

      return (response as List<dynamic>)
          .map((config) =>
              BillingConfiguration.fromMap(config as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // TODO: Replace with proper logging framework
      debugPrintError('Error fetching billing configurations: $e');
      return [];
    }
  }

  /// Save a new billing configuration
  Future<BillingConfiguration?> saveBillingConfiguration(
      BillingConfiguration config) async {
    try {
      final response = await supabase
          .from('billing_configurations')
          .insert(config.toMap())
          .select()
          .single();

      return BillingConfiguration.fromMap(response);
    } catch (e) {
      debugPrintError('Error saving billing configuration: $e');
      return null;
    }
  }

  /// Update a billing configuration
  Future<bool> updateBillingConfiguration(
      BillingConfiguration config) async {
    try {
      await supabase
          .from('billing_configurations')
          .update(config.toMap())
          .eq('id', config.id);
      return true;
    } catch (e) {
      debugPrintError('Error updating billing configuration: $e');
      return false;
    }
  }

  /// Deactivate a billing configuration
  Future<bool> deactivateBillingConfiguration(String configId) async {
    try {
      await supabase
          .from('billing_configurations')
          .update({'is_active': false})
          .eq('id', configId);
      return true;
    } catch (e) {
      debugPrintError('Error deactivating configuration: $e');
      return false;
    }
  }

  /// Record a billing switch
  Future<bool> recordBillingSwitch(BillingSwitch billSwitch) async {
    try {
      await supabase.from('billing_switches').insert(billSwitch.toMap());
      return true;
    } catch (e) {
      debugPrintError('Error recording billing switch: $e');
      return false;
    }
  }

  /// Save generated bills to database
  Future<bool> saveBills(List<GeneratedBill> bills) async {
    try {
      final billMaps = bills.map((b) => {
            'id': b.id,
            'school_id': b.schoolId,
            'student_id': b.studentId,
            'student_name': b.studentName,
            'grade_level': b.gradeLevel,
            'billing_date': b.billingDate.toIso8601String(),
            'due_date': b.dueDate.toIso8601String(),
            'subtotal': b.subtotal,
            'late_fee': b.lateFee,
            'discount': b.discount,
            'total': b.total,
            'frequency': b.frequency,
            'is_switch_bill': b.isSwitchBill,
            'created_at': DateTime.now().toIso8601String(),
          }).toList();

      await supabase.from('bills').insert(billMaps);

      // Save line items
      final lineItemMaps = <Map<String, dynamic>>[];
      for (final bill in bills) {
        for (final item in bill.lineItems) {
          lineItemMaps.add({
            'id': item.id,
            'bill_id': bill.id,
            'type': item.type.code,
            'description': item.description,
            'unit_price': item.unitPrice,
            'quantity': item.quantity,
            'total': item.total,
            'notes': item.notes,
          });
        }
      }

      if (lineItemMaps.isNotEmpty) {
        await supabase.from('bill_line_items').insert(lineItemMaps);
      }

      return true;
    } catch (e) {
      debugPrintError('Error saving bills: $e');
      return false;
    }
  }

  /// Fetch bills for a student
  Future<List<GeneratedBill>> fetchStudentBills(String studentId) async {
    try {
      final response = await supabase
          .from('bills')
          .select()
          .eq('student_id', studentId)
          .order('billing_date', ascending: false);

      return (response as List<dynamic>)
          .map((bill) => _billFromMap(bill as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrintError('Error fetching student bills: $e');
      return [];
    }
  }

  /// Fetch billing switches for a student
  Future<List<BillingSwitch>> fetchBillingSwitches(String studentId) async {
    try {
      final response = await supabase
          .from('billing_switches')
          .select()
          .eq('student_id', studentId)
          .order('effective_date', ascending: false);

      return (response as List<dynamic>)
          .map((switch_) => _billingSwitchFromMap(
              switch_ as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrintError('Error fetching billing switches: $e');
      return [];
    }
  }

  /// Generate bills in bulk
  Future<Map<String, dynamic>> generateBillsInBulk({
    required String schoolId,
    required String configId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required List<Map<String, dynamic>> students,
  }) async {
    try {
      // Call Edge Function to handle bulk billing
      final response = await supabase.functions.invoke(
        'generate_bills_bulk',
        body: {
          'school_id': schoolId,
          'config_id': configId,
          'period_start': periodStart.toIso8601String(),
          'period_end': periodEnd.toIso8601String(),
          'students': students,
        },
      );

      return response as Map<String, dynamic>;
    } catch (e) {
      debugPrintError('Error generating bills in bulk: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Mark bills as processed
  Future<bool> markBillsAsProcessed(List<String> billIds) async {
    try {
      await supabase
          .from('bills')
          .update({'is_processed': true})
          .inFilter('id', billIds);
      return true;
    } catch (e) {
      debugPrintError('Error marking bills as processed: $e');
      return false;
    }
  }

  /// Get billing statistics for school
  Future<Map<String, dynamic>> getBillingStatistics(String schoolId) async {
    try {
      final billsResponse = await supabase
          .from('bills')
          .select('total, is_paid')
          .eq('school_id', schoolId);

      final bills = billsResponse as List<dynamic>;
      final totalBilled = bills.fold<double>(
        0.0,
        (sum, bill) => sum + ((bill['total'] as num?) ?? 0.0).toDouble(),
      );
      final totalCollected = bills
          .where((bill) => bill['is_paid'] == true)
          .fold<double>(
        0.0,
        (sum, bill) => sum + ((bill['total'] as num?) ?? 0.0).toDouble(),
      );

      return {
        'total_billed': totalBilled,
        'total_collected': totalCollected,
        'outstanding': totalBilled - totalCollected,
        'collection_rate': totalBilled > 0
            ? ((totalCollected / totalBilled) * 100).toStringAsFixed(2)
            : '0',
        'total_bills': bills.length,
        'paid_bills': bills.where((b) => b['is_paid'] == true).length,
      };
    } catch (e) {
      debugPrintError('Error fetching billing statistics: $e');
      return {};
    }
  }

  /// Helper: Convert map to GeneratedBill
  GeneratedBill _billFromMap(Map<String, dynamic> map) {
    return GeneratedBill(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      studentId: map['student_id'] as String,
      studentName: map['student_name'] as String,
      gradeLevel: map['grade_level'] as String,
      billingDate: DateTime.parse(map['billing_date'] as String),
      dueDate: DateTime.parse(map['due_date'] as String),
      lineItems: [], // Would need separate query to populate
      lateFee: (map['late_fee'] as num?)?.toDouble() ?? 0.0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0.0,
      frequency: map['frequency'] as String,
      isSwitchBill: map['is_switch_bill'] as bool? ?? false,
    );
  }

  /// Helper: Convert map to BillingSwitch
  BillingSwitch _billingSwitchFromMap(Map<String, dynamic> map) {
    return BillingSwitch(
      id: map['id'] as String,
      schoolId: map['school_id'] as String,
      studentId: map['student_id'] as String,
      oldConfig: BillingConfiguration.fromMap(
          map['old_config'] as Map<String, dynamic>),
      newConfig: BillingConfiguration.fromMap(
          map['new_config'] as Map<String, dynamic>),
      effectiveDate: DateTime.parse(map['effective_date'] as String),
      prorationType: ProrationType.values.firstWhere(
        (e) => e.code == map['proration_type'],
        orElse: () => ProrationType.prorated,
      ),
      notes: map['notes'] as String?,
      isProcessed: map['is_processed'] as bool? ?? false,
    );
  }
}
