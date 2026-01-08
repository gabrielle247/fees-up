import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/access.dart';
import '../models/finance.dart';
import '../models/people.dart';
import '../models/saas.dart';
import 'isar_service.dart';
import 'app_logger.dart';

class SyncService {
  final _isar = IsarService();
  final _supabase = Supabase.instance.client;

  /// Sync local changes to Supabase (push)
  Future<void> pushToCloud({required String schoolId}) async {
    try {
      AppLogger.info('Starting push to cloud for school: $schoolId');
      final isar = await _isar.db;

      // Sync SAAS
      await _pushPlans(isar);
      await _pushSchools(isar);

      // Sync ACCESS
      await _pushRoles(isar);
      await _pushProfiles(isar, schoolId);

      // Sync PEOPLE
      await _pushAcademicYears(isar, schoolId);
      await _pushStudents(isar, schoolId);
      await _pushEnrollments(isar, schoolId);

      // Sync FINANCE
      await _pushFeeCategories(isar, schoolId);
      await _pushFeeStructures(isar, schoolId);
      await _pushInvoices(isar, schoolId);
      await _pushInvoiceItems(isar);
      await _pushLedgerEntries(isar, schoolId);
      await _pushPayments(isar, schoolId);
      await _pushPaymentAllocations(isar);

      AppLogger.success('Push to cloud completed for school: $schoolId');
    } catch (e) {
      AppLogger.error('Push to cloud failed', e);
      rethrow;
    }
  }

  /// Sync cloud changes to local (pull)
  Future<void> pullFromCloud({required String schoolId}) async {
    try {
      AppLogger.info('Starting pull from cloud for school: $schoolId');
      final isar = await _isar.db;

      // Sync SAAS
      await _pullPlans(isar);
      await _pullSchools(isar);

      // Sync ACCESS
      await _pullRoles(isar);
      await _pullProfiles(isar, schoolId);

      // Sync PEOPLE
      await _pullAcademicYears(isar, schoolId);
      await _pullStudents(isar, schoolId);
      await _pullEnrollments(isar, schoolId);

      // Sync FINANCE
      await _pullFeeCategories(isar, schoolId);
      await _pullFeeStructures(isar, schoolId);
      await _pullInvoices(isar, schoolId);
      await _pullInvoiceItems(isar);
      await _pullLedgerEntries(isar, schoolId);
      await _pullPayments(isar, schoolId);
      await _pullPaymentAllocations(isar);

      AppLogger.success('Pull from cloud completed for school: $schoolId');
    } catch (e) {
      AppLogger.error('Pull from cloud failed', e);
      rethrow;
    }
  }

  // =========================================================================
  // PUSH OPERATIONS (Local → Cloud)
  // =========================================================================

  Future<void> _pushPlans(Isar isar) async {
    try {
      final records = await isar.plans.where().findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('saas.plans').upsert(json);
      AppLogger.info('Pushed ${records.length} plans');
    } catch (e) {
      AppLogger.warning('Push plans failed: $e');
    }
  }

  Future<void> _pushSchools(Isar isar) async {
    try {
      final records = await isar.schools.where().findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('saas.schools').upsert(json);
      AppLogger.info('Pushed ${records.length} schools');
    } catch (e) {
      AppLogger.warning('Push schools failed: $e');
    }
  }

  Future<void> _pushRoles(Isar isar) async {
    try {
      final records = await isar.roles.where().findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('access.roles').upsert(json);
      AppLogger.info('Pushed ${records.length} roles');
    } catch (e) {
      AppLogger.warning('Push roles failed: $e');
    }
  }

  Future<void> _pushProfiles(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.profiles.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('access.profiles').upsert(json);
      AppLogger.info('Pushed ${records.length} profiles');
    } catch (e) {
      AppLogger.warning('Push profiles failed: $e');
    }
  }

  Future<void> _pushAcademicYears(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.academicYears.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('people.academic_years').upsert(json);
      AppLogger.info('Pushed ${records.length} academic years');
    } catch (e) {
      AppLogger.warning('Push academic years failed: $e');
    }
  }

  Future<void> _pushStudents(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.students.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('people.students').upsert(json);
      AppLogger.info('Pushed ${records.length} students');
    } catch (e) {
      AppLogger.warning('Push students failed: $e');
    }
  }

  Future<void> _pushEnrollments(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.enrollments.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('people.enrollments').upsert(json);
      AppLogger.info('Pushed ${records.length} enrollments');
    } catch (e) {
      AppLogger.warning('Push enrollments failed: $e');
    }
  }

  Future<void> _pushFeeCategories(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.feeCategorys.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('finance.fee_categories').upsert(json);
      AppLogger.info('Pushed ${records.length} fee categories');
    } catch (e) {
      AppLogger.warning('Push fee categories failed: $e');
    }
  }

  Future<void> _pushFeeStructures(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.feeStructures.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('finance.fee_structures').upsert(json);
      AppLogger.info('Pushed ${records.length} fee structures');
    } catch (e) {
      AppLogger.warning('Push fee structures failed: $e');
    }
  }

  Future<void> _pushInvoices(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.invoices.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('finance.invoices').upsert(json);
      AppLogger.info('Pushed ${records.length} invoices');
    } catch (e) {
      AppLogger.warning('Push invoices failed: $e');
    }
  }

  Future<void> _pushInvoiceItems(Isar isar) async {
    try {
      final records = await isar.invoiceItems.where().findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('finance.invoice_items').upsert(json);
      AppLogger.info('Pushed ${records.length} invoice items');
    } catch (e) {
      AppLogger.warning('Push invoice items failed: $e');
    }
  }

  Future<void> _pushLedgerEntries(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.ledgerEntrys.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('finance.ledger').upsert(json);
      AppLogger.info('Pushed ${records.length} ledger entries');
    } catch (e) {
      AppLogger.warning('Push ledger entries failed: $e');
    }
  }

  Future<void> _pushPayments(Isar isar, String schoolId) async {
    try {
      final records =
          await isar.payments.where().schoolIdEqualTo(schoolId).findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('finance.payments').upsert(json);
      AppLogger.info('Pushed ${records.length} payments');
    } catch (e) {
      AppLogger.warning('Push payments failed: $e');
    }
  }

  Future<void> _pushPaymentAllocations(Isar isar) async {
    try {
      final records = await isar.paymentAllocations.where().findAll();
      if (records.isEmpty) return;
      final json = records.map((r) => r.toJson()).toList();
      await _supabase.from('finance.payment_allocations').upsert(json);
      AppLogger.info('Pushed ${records.length} payment allocations');
    } catch (e) {
      AppLogger.warning('Push payment allocations failed: $e');
    }
  }

  // =========================================================================
  // PULL OPERATIONS (Cloud → Local)
  // =========================================================================

  Future<void> _pullPlans(Isar isar) async {
    try {
      final data = await _supabase.from('saas.plans').select() as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.plans.put(Plan.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} plans');
    } catch (e) {
      AppLogger.warning('Pull plans failed: $e');
    }
  }

  Future<void> _pullSchools(Isar isar) async {
    try {
      final data = await _supabase.from('saas.schools').select() as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.schools.put(School.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} schools');
    } catch (e) {
      AppLogger.warning('Pull schools failed: $e');
    }
  }

  Future<void> _pullRoles(Isar isar) async {
    try {
      final data = await _supabase.from('access.roles').select() as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.roles.put(Role.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} roles');
    } catch (e) {
      AppLogger.warning('Pull roles failed: $e');
    }
  }

  Future<void> _pullProfiles(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('access.profiles')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.profiles
              .put(Profile.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} profiles');
    } catch (e) {
      AppLogger.warning('Pull profiles failed: $e');
    }
  }

  Future<void> _pullAcademicYears(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('people.academic_years')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.academicYears
              .put(AcademicYear.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} academic years');
    } catch (e) {
      AppLogger.warning('Pull academic years failed: $e');
    }
  }

  Future<void> _pullStudents(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('people.students')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.students
              .put(Student.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} students');
    } catch (e) {
      AppLogger.warning('Pull students failed: $e');
    }
  }

  Future<void> _pullEnrollments(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('people.enrollments')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.enrollments
              .put(Enrollment.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} enrollments');
    } catch (e) {
      AppLogger.warning('Pull enrollments failed: $e');
    }
  }

  Future<void> _pullFeeCategories(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('finance.fee_categories')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.feeCategorys
              .put(FeeCategory.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} fee categories');
    } catch (e) {
      AppLogger.warning('Pull fee categories failed: $e');
    }
  }

  Future<void> _pullFeeStructures(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('finance.fee_structures')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.feeStructures
              .put(FeeStructure.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} fee structures');
    } catch (e) {
      AppLogger.warning('Pull fee structures failed: $e');
    }
  }

  Future<void> _pullInvoices(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('finance.invoices')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.invoices
              .put(Invoice.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} invoices');
    } catch (e) {
      AppLogger.warning('Pull invoices failed: $e');
    }
  }

  Future<void> _pullInvoiceItems(Isar isar) async {
    try {
      final data =
          await _supabase.from('finance.invoice_items').select() as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.invoiceItems
              .put(InvoiceItem.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} invoice items');
    } catch (e) {
      AppLogger.warning('Pull invoice items failed: $e');
    }
  }

  Future<void> _pullLedgerEntries(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('finance.ledger')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.ledgerEntrys
              .put(LedgerEntry.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} ledger entries');
    } catch (e) {
      AppLogger.warning('Pull ledger entries failed: $e');
    }
  }

  Future<void> _pullPayments(Isar isar, String schoolId) async {
    try {
      final data = await _supabase
          .from('finance.payments')
          .select()
          .eq('school_id', schoolId) as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.payments
              .put(Payment.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} payments');
    } catch (e) {
      AppLogger.warning('Pull payments failed: $e');
    }
  }

  Future<void> _pullPaymentAllocations(Isar isar) async {
    try {
      final data =
          await _supabase.from('finance.payment_allocations').select() as List;
      if (data.isEmpty) return;
      await isar.writeTxn(() async {
        for (final json in data) {
          await isar.paymentAllocations
              .put(PaymentAllocation.fromJson(json as Map<String, dynamic>));
        }
      });
      AppLogger.info('Pulled ${data.length} payment allocations');
    } catch (e) {
      AppLogger.warning('Pull payment allocations failed: $e');
    }
  }

  /// Full bidirectional sync
  Future<void> fullSync({required String schoolId}) async {
    try {
      AppLogger.info('🔄 Starting full sync for school: $schoolId');
      await pullFromCloud(schoolId: schoolId);
      await pushToCloud(schoolId: schoolId);
      AppLogger.success('✅ Full sync completed successfully');
    } catch (e) {
      AppLogger.error('Full sync failed', e);
      rethrow;
    }
  }

  /// Check sync status
  Future<Map<String, dynamic>> getSyncStatus({required String schoolId}) async {
    try {
      final isar = await _isar.db;

      return {
        'schools': await isar.schools.count(),
        'students':
            await isar.students.where().schoolIdEqualTo(schoolId).count(),
        'invoices':
            await isar.invoices.where().schoolIdEqualTo(schoolId).count(),
        'payments':
            await isar.payments.where().schoolIdEqualTo(schoolId).count(),
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'healthy',
      };
    } catch (e) {
      AppLogger.warning('Could not get sync status: $e');
      return {'error': e.toString(), 'status': 'error'};
    }
  }
}
