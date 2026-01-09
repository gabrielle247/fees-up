import 'dart:developer' as dev;

import 'package:drift/drift.dart' as drift;
import 'package:fees_up/data/database/drift_database.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SyncService {
  SyncService({required AppDatabase db, required SupabaseClient supabase})
      : _db = db,
        _supabase = supabase;

  final AppDatabase _db;
  final SupabaseClient _supabase;

  Future<String?> _getCurrentUserSchoolId() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    try {
      final res = await _supabase
          .schema('access')
          .from('profiles')
          .select('school_id')
          .eq('id', user.id)
          .maybeSingle();
      return (res != null) ? (res['school_id'] as String?) : null;
    } catch (e) {
      dev.log('SyncService: failed to get profile school_id: $e', name: 'Sync');
      return null;
    }
  }

  Future<void> syncAll({String? schoolId}) async {
    final online = await InternetConnectionChecker().hasConnection;
    if (!online) {
      dev.log('SyncService: skipped, offline', name: 'Sync');
      return;
    }

    final sid = schoolId ?? await _getCurrentUserSchoolId();
    if (sid == null) {
      dev.log('SyncService: No school id available; skipping sync',
          name: 'Sync');
      return;
    }

    await _db.transaction(() async {
      await _syncSchool(sid);
      await _syncStudents(sid);
      await _syncEnrollments(sid);
      await _syncFeeCategories(sid);
      await _syncFeeStructures(sid);
      await _syncInvoices(sid);
      await _syncInvoiceItems(sid);
      await _syncPayments(sid);
      await _syncLedger(sid);
    });
  }

  Future<void> _syncSchool(String schoolId) async {
    try {
      final data = await _supabase
          .schema('saas')
          .from('schools')
          .select()
          .eq('id', schoolId)
          .maybeSingle();
      if (data == null) return;

      final companion = SchoolsCompanion(
        id: drift.Value(data['id'] as String),
        name: drift.Value(data['name'] as String),
        subdomain: drift.Value((data['subdomain'] as String?) ?? ''),
        logoUrl: drift.Value(data['logo_url'] as String?),
        currentPlanId: drift.Value(data['current_plan_id'] as String?),
        subscriptionStatus:
            drift.Value((data['subscription_status'] as String?) ?? 'ACTIVE'),
        subscriptionEndsAt: drift.Value(
          (data['subscription_ends_at'] != null)
              ? DateTime.tryParse(data['subscription_ends_at'] as String)
              : null,
        ),
        createdAt: drift.Value(
          DateTime.tryParse((data['created_at'] as String?) ?? '') ??
              DateTime.now(),
        ),
      );

      final updated = await (_db.update(_db.schools)
            ..where((tbl) => tbl.id.equals(schoolId)))
          .write(companion);
      if (updated == 0) {
        await _db.into(_db.schools).insert(companion);
      }
    } catch (e) {
      dev.log('SyncService: _syncSchool error: $e', name: 'Sync');
    }
  }

  Future<void> _syncStudents(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('people')
          .from('students')
          .select()
          .eq('school_id', schoolId);

      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = StudentsCompanion(
          id: drift.Value(id),
          schoolId: drift.Value(r['school_id'] as String),
          firstName: drift.Value(r['first_name'] as String),
          lastName: drift.Value(r['last_name'] as String),
          gender: drift.Value(r['gender'] as String?),
          nationalId: drift.Value(r['national_id'] as String?),
          status: drift.Value((r['status'] as String?) ?? 'ACTIVE'),
          dateOfBirth: drift.Value(
            (r['dob'] != null) ? DateTime.tryParse(r['dob'] as String) : null,
          ),
          createdAt: drift.Value(
            DateTime.tryParse((r['created_at'] as String?) ?? '') ??
                DateTime.now(),
          ),
        );

        final updated = await (_db.update(_db.students)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.students).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncStudents error: $e', name: 'Sync');
    }
  }

  Future<void> _syncEnrollments(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('people')
          .from('enrollments')
          .select()
          .eq('school_id', schoolId);
      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = EnrollmentsCompanion(
          id: drift.Value(id),
          schoolId: drift.Value(r['school_id'] as String),
          studentId: drift.Value(r['student_id'] as String),
          academicYearId: drift.Value(r['academic_year_id'] as String),
          gradeLevel: drift.Value(r['grade_level'] as String),
          classStream: drift.Value(r['class_stream'] as String?),
          snapshotGrade: drift.Value(r['snapshot_grade'] as String?),
          targetGrade: drift.Value(r['target_grade'] as String?),
          isActive: drift.Value((r['is_active'] as bool?) ?? true),
          enrolledAt: drift.Value(
            (r['enrollment_date'] != null)
                ? DateTime.tryParse(r['enrollment_date'] as String)
                : null,
          ),
        );
        final updated = await (_db.update(_db.enrollments)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.enrollments).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncEnrollments error: $e', name: 'Sync');
    }
  }

  Future<void> _syncFeeCategories(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('finance')
          .from('fee_categories')
          .select()
          .eq('school_id', schoolId);
      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = FeeCategoriesCompanion(
          id: drift.Value(id),
          schoolId: drift.Value(r['school_id'] as String),
          name: drift.Value(r['name'] as String),
        );
        final updated = await (_db.update(_db.feeCategories)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.feeCategories).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncFeeCategories error: $e', name: 'Sync');
    }
  }

  Future<void> _syncFeeStructures(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('finance')
          .from('fee_structures')
          .select()
          .eq('school_id', schoolId);
      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = FeeStructuresCompanion(
          id: drift.Value(id),
          schoolId: drift.Value(r['school_id'] as String),
          academicYearId: drift.Value(r['academic_year_id'] as String),
          name: drift.Value(r['name'] as String),
          targetGrade: drift.Value(r['target_grade'] as String?),
          categoryId: drift.Value(r['category_id'] as String?),
          amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
          currency: drift.Value((r['currency'] as String?) ?? 'USD'),
          recurrence: drift.Value((r['recurrence'] as String?) ?? 'TERM'),
          billingType: drift.Value((r['billing_type'] as String?) ?? 'FIXED'),
          billableMonths: drift.Value(r['billable_months']?.toString()),
          isActive: drift.Value((r['is_active'] as bool?) ?? true),
          suspensions: drift.Value(r['suspensions']?.toString()),
          createdAt: drift.Value(
            DateTime.tryParse((r['created_at'] as String?) ?? '') ??
                DateTime.now(),
          ),
        );
        final updated = await (_db.update(_db.feeStructures)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.feeStructures).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncFeeStructures error: $e', name: 'Sync');
    }
  }

  Future<void> _syncInvoices(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('finance')
          .from('invoices')
          .select()
          .eq('school_id', schoolId);
      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = InvoicesCompanion(
          id: drift.Value(id),
          schoolId: drift.Value(r['school_id'] as String),
          studentId: drift.Value(r['student_id'] as String),
          invoiceNumber: drift.Value(r['invoice_number'] as String),
          termId: drift.Value(r['term_id'] as String?),
          snapshotGrade: drift.Value(r['snapshot_grade'] as String?),
          status: drift.Value((r['status'] as String?) ?? 'ISSUED'),
          dueDate: drift.Value(
            (r['due_date'] != null)
                ? DateTime.tryParse(r['due_date'] as String)
                : null,
          ),
          createdAt: drift.Value(
            (r['created_at'] != null)
                ? DateTime.tryParse(r['created_at'] as String)
                : null,
          ),
        );
        final updated = await (_db.update(_db.invoices)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.invoices).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncInvoices error: $e', name: 'Sync');
    }
  }

  Future<void> _syncInvoiceItems(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('finance')
          .from('invoice_items')
          .select(
              'id, invoice_id, description, amount, fee_structure_id, invoices!inner(school_id)')
          .eq('invoices.school_id', schoolId);
      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = InvoiceItemsCompanion(
          id: drift.Value(id),
          invoiceId: drift.Value(r['invoice_id'] as String),
          description: drift.Value(r['description'] as String),
          amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
          feeStructureId: drift.Value(r['fee_structure_id'] as String?),
        );
        final updated = await (_db.update(_db.invoiceItems)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.invoiceItems).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncInvoiceItems error: $e', name: 'Sync');
    }
  }

  Future<void> _syncPayments(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('finance')
          .from('payments')
          .select()
          .eq('school_id', schoolId);
      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = PaymentsCompanion(
          id: drift.Value(id),
          schoolId: drift.Value(r['school_id'] as String),
          studentId: drift.Value(r['student_id'] as String),
          amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
          method: drift.Value(r['method'] as String),
          referenceCode: drift.Value(r['reference_code'] as String?),
          receivedAt: drift.Value(
            DateTime.tryParse((r['received_at'] as String?) ?? '') ??
                DateTime.now(),
          ),
          createdAt: drift.Value(
            DateTime.tryParse((r['created_at'] as String?) ?? '') ??
                DateTime.now(),
          ),
        );
        final updated = await (_db.update(_db.payments)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.payments).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncPayments error: $e', name: 'Sync');
    }
  }

  Future<void> _syncLedger(String schoolId) async {
    try {
      final rows = await _supabase
          .schema('finance')
          .from('ledger')
          .select()
          .eq('school_id', schoolId);
      for (final r in (rows as List)) {
        final id = r['id'] as String;
        final companion = LedgerEntriesCompanion(
          id: drift.Value(id),
          schoolId: drift.Value(r['school_id'] as String),
          studentId: drift.Value(r['student_id'] as String),
          type: drift.Value(r['type'] as String),
          category: drift.Value(r['category'] as String),
          amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
          description: drift.Value(r['description'] as String?),
          invoiceId: drift.Value(r['invoice_id'] as String?),
          referenceCode: drift.Value(r['reference_code'] as String?),
          currency: drift.Value((r['currency'] as String?) ?? 'USD'),
          occurredAt: drift.Value(
            DateTime.tryParse((r['occurred_at'] as String?) ?? '') ??
                DateTime.now(),
          ),
        );
        final updated = await (_db.update(_db.ledgerEntries)
              ..where((t) => t.id.equals(id)))
            .write(companion);
        if (updated == 0) {
          await _db.into(_db.ledgerEntries).insert(companion);
        }
      }
    } catch (e) {
      dev.log('SyncService: _syncLedger error: $e', name: 'Sync');
    }
  }
}
