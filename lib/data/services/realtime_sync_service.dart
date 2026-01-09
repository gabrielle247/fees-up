import 'dart:async';
import 'dart:developer' as dev;

import 'package:fees_up/data/database/drift_database.dart';
import 'package:drift/drift.dart' as drift;
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeSyncService {
  RealtimeSyncService({required this.db, required this.supabase});

  final AppDatabase db;
  final SupabaseClient supabase;

  final List<RealtimeChannel> _channels = [];

  Future<void> start({String? schoolId}) async {
    final sid = schoolId ??
        supabase.auth.currentUser?.id; // fallback; prefer explicit school
    // Schools
    _channels.add(
        _subscribe('realtime:saas:schools', 'saas', 'schools', (payload) async {
      final r =
          payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord;
      if (r.isEmpty) return;
      try {
        if (payload.eventType == PostgresChangeEvent.delete) {
          await (db.delete(db.schools)..where((t) => t.id.equals(r['id'])))
              .go();
          return;
        }
        final c = SchoolsCompanion(
          id: drift.Value(r['id'] as String),
          name: drift.Value((r['name'] as String?) ?? ''),
          subdomain: drift.Value((r['subdomain'] as String?) ?? ''),
          logoUrl: drift.Value(r['logo_url'] as String?),
          currentPlanId: drift.Value(r['current_plan_id'] as String?),
          subscriptionStatus:
              drift.Value((r['subscription_status'] as String?) ?? 'ACTIVE'),
          subscriptionEndsAt: drift.Value(_ts(r['subscription_ends_at'])),
          createdAt: drift.Value(_ts(r['created_at']) ?? DateTime.now()),
        );
        await db.into(db.schools).insertOnConflictUpdate(c);
      } catch (e) {
        dev.log('Realtime schools error: $e', name: 'Realtime');
      }
    }));

    // Students
    _channels.add(_subscribe('realtime:people:students', 'people', 'students',
        (payload) async {
      final r =
          payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord;
      if (r.isEmpty) return;
      try {
        if (sid != null && r['school_id'] != sid && r['school_id'] != null) {
          // If filtering by school, ignore others
        }
        if (payload.eventType == PostgresChangeEvent.delete) {
          await (db.delete(db.students)..where((t) => t.id.equals(r['id'])))
              .go();
          return;
        }
        final c = StudentsCompanion(
          id: drift.Value(r['id'] as String),
          schoolId: drift.Value((r['school_id'] as String?) ?? ''),
          firstName: drift.Value((r['first_name'] as String?) ?? ''),
          lastName: drift.Value((r['last_name'] as String?) ?? ''),
          gender: drift.Value(r['gender'] as String?),
          nationalId: drift.Value(r['national_id'] as String?),
          status: drift.Value((r['status'] as String?) ?? 'ACTIVE'),
          dateOfBirth: drift.Value(_ts(r['dob'])),
          createdAt: drift.Value(_ts(r['created_at']) ?? DateTime.now()),
        );
        await db.into(db.students).insertOnConflictUpdate(c);
      } catch (e) {
        dev.log('Realtime students error: $e', name: 'Realtime');
      }
    }));

    // Enrollments
    _channels.add(
        _subscribe('realtime:people:enrollments', 'people', 'enrollments',
            (payload) async {
      final r =
          payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord;
      if (r.isEmpty) return;
      try {
        if (payload.eventType == PostgresChangeEvent.delete) {
          await (db.delete(db.enrollments)..where((t) => t.id.equals(r['id'])))
              .go();
          return;
        }
        final c = EnrollmentsCompanion(
          id: drift.Value(r['id'] as String),
          schoolId: drift.Value((r['school_id'] as String?) ?? ''),
          studentId: drift.Value((r['student_id'] as String?) ?? ''),
          academicYearId: drift.Value((r['academic_year_id'] as String?) ?? ''),
          gradeLevel: drift.Value((r['grade_level'] as String?) ?? ''),
          classStream: drift.Value(r['class_stream'] as String?),
          snapshotGrade: drift.Value(r['snapshot_grade'] as String?),
          targetGrade: drift.Value(r['target_grade'] as String?),
          isActive: drift.Value((r['is_active'] as bool?) ?? true),
          enrolledAt: drift.Value(_ts(r['enrollment_date'])),
        );
        await db.into(db.enrollments).insertOnConflictUpdate(c);
      } catch (e) {
        dev.log('Realtime enrollments error: $e', name: 'Realtime');
      }
    }));

    // Finance tables
    _subscribeFinance('fee_categories', (r, event) async {
      if (event == PostgresChangeEvent.delete) {
        await (db.delete(db.feeCategories)..where((t) => t.id.equals(r['id'])))
            .go();
        return;
      }
      final c = FeeCategoriesCompanion(
        id: drift.Value(r['id'] as String),
        schoolId: drift.Value((r['school_id'] as String?) ?? ''),
        name: drift.Value((r['name'] as String?) ?? ''),
      );
      await db.into(db.feeCategories).insertOnConflictUpdate(c);
    });

    _subscribeFinance('fee_structures', (r, event) async {
      if (event == PostgresChangeEvent.delete) {
        await (db.delete(db.feeStructures)..where((t) => t.id.equals(r['id'])))
            .go();
        return;
      }
      final c = FeeStructuresCompanion(
        id: drift.Value(r['id'] as String),
        schoolId: drift.Value((r['school_id'] as String?) ?? ''),
        academicYearId: drift.Value((r['academic_year_id'] as String?) ?? ''),
        name: drift.Value((r['name'] as String?) ?? ''),
        targetGrade: drift.Value(r['target_grade'] as String?),
        categoryId: drift.Value(r['category_id'] as String?),
        amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
        currency: drift.Value((r['currency'] as String?) ?? 'USD'),
        recurrence: drift.Value((r['recurrence'] as String?) ?? 'TERM'),
        billingType: drift.Value((r['billing_type'] as String?) ?? 'FIXED'),
        billableMonths: drift.Value(r['billable_months']?.toString()),
        isActive: drift.Value((r['is_active'] as bool?) ?? true),
        suspensions: drift.Value(r['suspensions']?.toString()),
        createdAt: drift.Value(_ts(r['created_at']) ?? DateTime.now()),
      );
      await db.into(db.feeStructures).insertOnConflictUpdate(c);
    });

    _subscribeFinance('invoices', (r, event) async {
      if (event == PostgresChangeEvent.delete) {
        await (db.delete(db.invoices)..where((t) => t.id.equals(r['id']))).go();
        return;
      }
      final c = InvoicesCompanion(
        id: drift.Value(r['id'] as String),
        schoolId: drift.Value((r['school_id'] as String?) ?? ''),
        studentId: drift.Value((r['student_id'] as String?) ?? ''),
        invoiceNumber: drift.Value((r['invoice_number'] as String?) ?? ''),
        termId: drift.Value(r['term_id'] as String?),
        snapshotGrade: drift.Value(r['snapshot_grade'] as String?),
        status: drift.Value((r['status'] as String?) ?? 'ISSUED'),
        dueDate: drift.Value(_ts(r['due_date'])),
        createdAt: drift.Value(_ts(r['created_at'])),
      );
      await db.into(db.invoices).insertOnConflictUpdate(c);
    });

    _subscribeFinance('invoice_items', (r, event) async {
      if (event == PostgresChangeEvent.delete) {
        await (db.delete(db.invoiceItems)..where((t) => t.id.equals(r['id'])))
            .go();
        return;
      }
      final c = InvoiceItemsCompanion(
        id: drift.Value(r['id'] as String),
        invoiceId: drift.Value((r['invoice_id'] as String?) ?? ''),
        description: drift.Value((r['description'] as String?) ?? ''),
        amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
        feeStructureId: drift.Value(r['fee_structure_id'] as String?),
      );
      await db.into(db.invoiceItems).insertOnConflictUpdate(c);
    });

    _subscribeFinance('payments', (r, event) async {
      if (event == PostgresChangeEvent.delete) {
        await (db.delete(db.payments)..where((t) => t.id.equals(r['id']))).go();
        return;
      }
      final c = PaymentsCompanion(
        id: drift.Value(r['id'] as String),
        schoolId: drift.Value((r['school_id'] as String?) ?? ''),
        studentId: drift.Value((r['student_id'] as String?) ?? ''),
        amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
        method: drift.Value((r['method'] as String?) ?? ''),
        referenceCode: drift.Value(r['reference_code'] as String?),
        receivedAt: drift.Value(_ts(r['received_at']) ?? DateTime.now()),
        createdAt: drift.Value(_ts(r['created_at']) ?? DateTime.now()),
      );
      await db.into(db.payments).insertOnConflictUpdate(c);
    });

    _subscribeFinance('ledger', (r, event) async {
      if (event == PostgresChangeEvent.delete) {
        await (db.delete(db.ledgerEntries)..where((t) => t.id.equals(r['id'])))
            .go();
        return;
      }
      final c = LedgerEntriesCompanion(
        id: drift.Value(r['id'] as String),
        schoolId: drift.Value((r['school_id'] as String?) ?? ''),
        studentId: drift.Value((r['student_id'] as String?) ?? ''),
        type: drift.Value((r['type'] as String?) ?? ''),
        category: drift.Value((r['category'] as String?) ?? ''),
        amount: drift.Value(((r['amount'] as num?) ?? 0).toInt()),
        description: drift.Value(r['description'] as String?),
        invoiceId: drift.Value(r['invoice_id'] as String?),
        referenceCode: drift.Value(r['reference_code'] as String?),
        currency: drift.Value((r['currency'] as String?) ?? 'USD'),
        occurredAt: drift.Value(_ts(r['occurred_at']) ?? DateTime.now()),
      );
      await db.into(db.ledgerEntries).insertOnConflictUpdate(c);
    });
  }

  Future<void> stop() async {
    for (final ch in _channels) {
      await ch.unsubscribe();
    }
    _channels.clear();
  }

  RealtimeChannel _subscribe(String topic, String schema, String table,
      Future<void> Function(PostgresChangePayload payload) onChange) {
    final ch = supabase.channel(topic);
    ch.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: schema,
        table: table,
        callback: onChange);
    ch.subscribe();
    return ch;
  }

  void _subscribeFinance(
      String table,
      Future<void> Function(Map<String, dynamic> r, PostgresChangeEvent event)
          onChange) {
    final topic = 'realtime:finance:$table';
    final ch = supabase.channel(topic);
    ch.onPostgresChanges(
      event: PostgresChangeEvent.all,
      table: table,
      schema: 'finance',
      callback: (payload) async {
        final record = payload.newRecord.isNotEmpty
            ? payload.newRecord
            : payload.oldRecord;
        if (record.isEmpty) return;
        await onChange(record, payload.eventType);
      },
    );
    ch.subscribe();
    _channels.add(ch);
  }

  static DateTime? _ts(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    return null;
  }
}
