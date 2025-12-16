import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
// Note: Do NOT import sqflite_common_ffi here.
// The factory must be initialized exactly ONCE in main.dart to avoid warnings.
import 'package:uuid/uuid.dart';

// Models
import '../models/billing_config.dart';
import '../models/student_full.dart';

/// ----------------------------------------------------------------------------
/// DATABASE SERVICE (Production V3)
/// ----------------------------------------------------------------------------
/// Handles SQLite persistence for the Public Schema (Business Logic).
/// ----------------------------------------------------------------------------
class DatabaseService {
  // Singleton
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static const _dbName = 'fees_up_prod.db';
  static const _dbVersion = 1;

  Database? _db;

  // Reactive Streams
  final StreamController<List<StudentFull>> _studentStreamController =
      StreamController<List<StudentFull>>.broadcast();
  Stream<List<StudentFull>> get studentFullStream =>
      _studentStreamController.stream;

  final StreamController<Map<String, dynamic>> _changeController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get changes => _changeController.stream;

  List<StudentFull>? _studentFullCache;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // 🛑 NO FFI INIT HERE (Handled in main.dart)
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );

    await _runMigrations(db);
    return db;
  }

  Future<void> _runMigrations(Database db) async {
    // Add missing school_name to user_profiles if absent
    await _ensureColumn(
      db,
      table: 'user_profiles',
      column: 'school_name',
      addSql: 'ALTER TABLE user_profiles ADD COLUMN school_name TEXT',
    );

    // Ensure student_archives table exists for older installs
    await _ensureTableExists(
      db,
      table: 'student_archives',
      createSql: '''
        CREATE TABLE student_archives (
          id TEXT,
          school_id TEXT NOT NULL,
          full_name TEXT,
          reason TEXT,
          archived_at TEXT,
          original_data TEXT,
          created_at INTEGER,
          PRIMARY KEY (id, school_id),
          FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
        );
      '''
    );
  }

  Future<void> _ensureColumn(
    Database db, {
    required String table,
    required String column,
    required String addSql,
  }) async {
    final res = await db.rawQuery('PRAGMA table_info($table)');
    final exists = res.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute(addSql);
    }
  }

  // ---------------------------------------------------------------------------
  // 1. SCHEMA DEFINITION
  // ---------------------------------------------------------------------------
  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // --- TENANCY TABLES (Matching Public Schema) ---

    // 1. Schools
    batch.execute('''
      CREATE TABLE schools (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        subscription_tier TEXT DEFAULT 'free', -- 'free', 'basic', 'pro'
        max_students INTEGER DEFAULT 50,
        is_suspended INTEGER DEFAULT 0,
        created_at INTEGER
      )
    ''');

    // 2. User Profiles (Linked to Schools & Auth UID)
    batch.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY, -- Matches auth.users.id
        email TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT DEFAULT 'teacher', -- 'super_admin', 'school_admin', 'teacher', 'student'
        school_id TEXT,
        is_banned INTEGER DEFAULT 0,
        avatar_url TEXT,
        last_synced_at TEXT,
        created_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // --- CORE BUSINESS TABLES ---

    // 3. Students
    batch.execute('''
      CREATE TABLE students (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        full_name TEXT NOT NULL,
        grade TEXT,
        parent_contact TEXT,
        registration_date TEXT,
        billing_date TEXT,
        billing_type TEXT DEFAULT 'monthly',
        is_active INTEGER DEFAULT 1,
        default_fee REAL DEFAULT 0.0,
        subjects TEXT,
        admin_uid TEXT, -- Legacy ownership, synced with user_profiles.id
        paid_total REAL DEFAULT 0,
        owed_total REAL DEFAULT 0,
        last_synced_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // 4. Bills
    batch.execute('''
      CREATE TABLE bills (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        school_id TEXT, -- Multi-tenancy support
        term_id TEXT,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0.0,
        month_year TEXT,
        due_date TEXT,
        billing_cycle_start TEXT,
        billing_cycle_end TEXT,
        bill_type TEXT DEFAULT 'monthly',
        cycle_interval TEXT,
        is_closed INTEGER DEFAULT 0,
        created_at INTEGER,
        updated_at INTEGER,
        admin_uid TEXT,
        title TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');
    // Enforce unique monthly bills per student
    batch.execute(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_bill ON bills (student_id, month_year) WHERE month_year IS NOT NULL',
    );

    // 5. Payments
    batch.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        bill_id TEXT,
        student_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date_paid TEXT NOT NULL,
        method TEXT DEFAULT 'Cash',
        payer_name TEXT,
        category TEXT DEFAULT 'tuition',
        reference_number TEXT,
        admin_uid TEXT,
        created_at INTEGER,
        FOREIGN KEY (bill_id) REFERENCES bills (id) ON DELETE SET NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // --- ACADEMICS ---

    // 6. Teachers
    batch.execute('''
      CREATE TABLE teachers (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        full_name TEXT NOT NULL,
        admin_uid TEXT,
        created_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // 7. Classes
    batch.execute('''
      CREATE TABLE classes (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        name TEXT NOT NULL,
        grade TEXT,
        room_number TEXT,
        teacher_id TEXT,
        subject_code TEXT,
        admin_uid TEXT,
        created_at INTEGER,
        FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE SET NULL,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // 8. Enrollments
    batch.execute('''
      CREATE TABLE enrollments (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        student_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        enrolled_at TEXT,
        admin_uid TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE,
        FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE
      )
    ''');

    // 9. Terms
    batch.execute('''
      CREATE TABLE school_terms (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        name TEXT,
        academic_year INTEGER,
        start_date TEXT,
        end_date TEXT,
        term_dates TEXT, -- JSON
        term_number INTEGER,
        created_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // 10. Attendance
    batch.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        student_id TEXT NOT NULL,
        class_id TEXT,
        date TEXT NOT NULL,
        status TEXT DEFAULT 'present',
        remarks TEXT,
        admin_uid TEXT,
        created_at INTEGER,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // --- OPERATIONS ---

    // 11. Expenses
    batch.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        school_id TEXT,
        title TEXT NOT NULL,
        category TEXT,
        amount REAL NOT NULL,
        date_incurred TEXT NOT NULL,
        description TEXT,
        recipient TEXT,
        admin_uid TEXT,
        created_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // 12. Campaigns
    batch.execute('''
      CREATE TABLE campaigns (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        title TEXT NOT NULL,
        goal_amount REAL DEFAULT 0,
        description TEXT,
        start_date TEXT,
        end_date TEXT,
        is_active INTEGER DEFAULT 1,
        created_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    // 13. Campaign Donations
    batch.execute('''
      CREATE TABLE campaign_donations (
        id TEXT PRIMARY KEY,
        campaign_id TEXT NOT NULL,
        donor_type TEXT,
        donor_id TEXT, 
        donor_name TEXT,
        amount REAL NOT NULL,
        payment_method TEXT,
        date_received TEXT,
        notes TEXT,
        created_at INTEGER,
        FOREIGN KEY (campaign_id) REFERENCES campaigns (id) ON DELETE CASCADE
      )
    ''');

    // 14. Teacher Access Tokens (One-time access codes for delegated duties)
    batch.execute('''
      CREATE TABLE teacher_access_tokens (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        granted_by_teacher_id TEXT NOT NULL,
        access_code TEXT NOT NULL UNIQUE,
        permission_type TEXT NOT NULL,
        is_used INTEGER DEFAULT 0,
        used_at TEXT,
        expires_at TEXT NOT NULL,
        created_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE,
        FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE CASCADE,
        FOREIGN KEY (granted_by_teacher_id) REFERENCES teachers (id) ON DELETE CASCADE
      )
    ''');

    // 15. Attendance Sessions (Sessions where student_admin marks attendance with teacher permission)
    batch.execute('''
      CREATE TABLE attendance_sessions (
        id TEXT PRIMARY KEY,
        school_id TEXT NOT NULL,
        class_id TEXT NOT NULL,
        teacher_id TEXT NOT NULL,
        student_admin_id TEXT NOT NULL,
        access_token_id TEXT NOT NULL,
        session_date TEXT NOT NULL,
        is_confirmed_by_teacher INTEGER DEFAULT 0,
        confirmed_at TEXT,
        created_at INTEGER,
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE,
        FOREIGN KEY (class_id) REFERENCES classes (id) ON DELETE CASCADE,
        FOREIGN KEY (teacher_id) REFERENCES teachers (id) ON DELETE CASCADE,
        FOREIGN KEY (access_token_id) REFERENCES teacher_access_tokens (id) ON DELETE CASCADE
      )
    ''');

    // --- SYSTEM & UTILS ---

    // 16. Sync Queue (Offline-First Engine)
    batch.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload TEXT,
        created_at INTEGER,
        tries INTEGER DEFAULT 0,
        school_id TEXT
      )
    ''');

    // 17. Billing Settings (JSON Blob)
    batch.execute('''
      CREATE TABLE billing_settings (
        id TEXT PRIMARY KEY, 
        config_json TEXT NOT NULL,
        updated_at INTEGER
      )
    ''');

    // 18. Metadata (Local Prefs)
    batch.execute('''
      CREATE TABLE metadata (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // 19. Notifications
    batch.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        school_id TEXT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        created_at INTEGER
      )
    ''');

    // 20. Student Archives
    batch.execute('''
      CREATE TABLE student_archives (
        id TEXT,
        school_id TEXT NOT NULL,
        full_name TEXT,
        reason TEXT,
        archived_at TEXT,
        original_data TEXT, -- JSON
        created_at INTEGER, -- The column we just fixed in SQL
        PRIMARY KEY (id, school_id),
        FOREIGN KEY (school_id) REFERENCES schools (id) ON DELETE CASCADE
      )
    ''');

    await batch.commit();
    debugPrint("✅ Database Schema V3 Initialized (Full Backend Alignment)");
  }

  Future<void> _ensureTableExists(
    Database db, {
    required String table,
    required String createSql,
  }) async {
    final res = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name = ?",
      [table],
    );
    final exists = res.isNotEmpty;
    if (!exists) {
      await db.execute(createSql);
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  // ---------------------------------------------------------------------------
  // 2. ADMIN & SCHOOL BOOTSTRAPPING
  // ---------------------------------------------------------------------------

  /// Ensures a local School and User Profile exist for the logged-in user.
  /// If not, it creates them (Offline-First approach).
  Future<String> ensureAdminExists(
    String uid, {
    Map<String, Object?>? defaults,
  }) async {
    final db = await database;

    // Check if user exists locally
    final exists = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [uid],
      limit: 1,
    );

    if (exists.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Generate new School ID
      final schoolId = _generateId('SCH');
      final schoolName = defaults?['school_name']?.toString() ?? 'My School';

      await db.transaction((txn) async {
        // 2. Create School
        final schoolData = {
          'id': schoolId,
          'name': schoolName,
          'subscription_tier': 'free',
          'max_students': 50,
          'is_suspended': 0,
          'created_at': now,
        };
        await txn.insert('schools', schoolData);
        await _addToSyncQueue(txn, 'schools', 'INSERT', schoolData);

        // 3. Create User Profile
        final userData = {
          'id': uid,
          'email': defaults?['email'] ?? '$uid@local',
          'full_name': defaults?['full_name'] ?? 'Admin',
          'role': 'school_admin',
          'school_id': schoolId,
          'is_banned': 0,
          'created_at': now,
        };
        await txn.insert('user_profiles', userData);
        await _addToSyncQueue(txn, 'user_profiles', 'INSERT', userData);
      });

      debugPrint("✅ AdminEnough: Created School ($schoolName) & User ($uid)");
    }
    return uid;
  }

  /// Helper to patch legacy tables with the current admin UID if missing
  Future<int> enforceAdminUidToAllTables(String uid) async {
    final db = await database;
    final tables = [
      'students',
      'bills',
      'payments',
      'teachers',
      'classes',
      'expenses',
      'campaigns',
    ];
    int total = 0;
    await db.transaction((txn) async {
      for (var table in tables) {
        try {
          final count = await txn.rawUpdate(
            "UPDATE $table SET admin_uid = ? WHERE admin_uid IS NULL OR admin_uid = ''",
            [uid],
          );
          total += count;
        } catch (_) {
          // Ignore tables that might be missing the column during migration
        }
      }
    });
    return total;
  }

  // ---------------------------------------------------------------------------
  // 3. STUDENT & FINANCIALS (CRUD + Logic)
  // ---------------------------------------------------------------------------

  /// Returns true if there is at least one school in local DB.
  Future<bool> hasAnySchool() async {
    final db = await database;
    final res = await db.rawQuery('SELECT COUNT(*) as c FROM schools');
    final count = (res.first['c'] as int?) ?? 0;
    return count > 0;
  }

  /// Returns true if the given school has at least one term defined.
  Future<bool> hasAnyTermForSchool(String schoolId) async {
    final db = await database;
    final res = await db.rawQuery(
      'SELECT COUNT(*) as c FROM school_terms WHERE school_id = ?',
      [schoolId],
    );
    final count = (res.first['c'] as int?) ?? 0;
    return count > 0;
  }

  /// Get local user profile row by auth UID.
  Future<Map<String, Object?>?> getUserProfileById(String uid) async {
    final db = await database;
    final res = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [uid],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<String> createStudent(
    Map<String, dynamic> values, {
    bool queueForSync = false,
    bool createBackdatedBills = false,
  }) async {
    final db = await database;
    final id = values['id'] ?? _generateId('STU');
    values['id'] = id;
    
    // Enforce: student must be linked to an existing school
    if (values['school_id'] == null || (values['school_id'] as String).isEmpty) {
      throw Exception('Cannot add student: no school is linked to this account.');
    }
    
    // Enforce: termly billing requires at least one term for the school
    final billingType = (values['billing_type'] as String?)?.toLowerCase();
    if (billingType == 'termly') {
      final schoolId = values['school_id'] as String;
      final hasTerm = await hasAnyTermForSchool(schoolId);
      if (!hasTerm) {
        throw Exception('Cannot add termly student: no academic term is set up yet.');
      }
    }
    
    // **SECURITY: Verify admin owns this school (client-side guard; RLS required server-side)**
    final adminUid = values['admin_uid'] as String?;
    final schoolId = values['school_id'] as String;
    if (adminUid != null) {
      final profile = await getUserProfileById(adminUid);
      if (profile == null || (profile['school_id'] as String?) != schoolId) {
        throw Exception('Access denied: you cannot add students to a school you do not admin.');
      }
    }
    
    values['paid_total'] ??= 0.0;
    values['owed_total'] ??= 0.0;

    await db.transaction((txn) async {
      await txn.insert(
        'students',
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (queueForSync) {
        await _addToSyncQueue(txn, 'students', 'INSERT', values);
      }
    });

    if (createBackdatedBills) {
      await generateBackdatedBillsForStudent(id);
    }

    _emitChange({'action': 'create_student', 'id': id});
    refreshStudentFullCache();
    return id;
  }

  Future<Map<String, Object?>?> getStudentById(String id) async {
    final db = await database;
    final res = await db.query(
      'students',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> updateStudent(String id, Map<String, dynamic> data) async {
    await update('students', data, 'id = ?', [id], queueForSync: true);
    refreshStudentFullCache();
  }

  Future<String> createBillForStudent({
    required String studentId,
    required double totalAmount,
    String billType = 'monthly',
    String? monthYear,
    DateTime? cycleStart,
    DateTime? cycleEnd,
    String? adminUid,
    String? termId,
    bool queueForSync = false,
    DateTime? createdAt,
  }) async {
    final db = await database;
    final id = _generateId('BILL');
    final now = (createdAt ?? DateTime.now()).millisecondsSinceEpoch;

    final values = {
      'id': id,
      'student_id': studentId,
      'term_id': termId,
      'total_amount': totalAmount,
      'paid_amount': 0.0,
      'month_year': monthYear,
      'billing_cycle_start': cycleStart?.toIso8601String(),
      'billing_cycle_end': cycleEnd?.toIso8601String(),
      'bill_type': billType,
      'is_closed': 0,
      'created_at': now,
      'updated_at': now,
      'admin_uid': adminUid,
    };

    await db.transaction((txn) async {
      await txn.insert('bills', values);
      if (queueForSync) {
        await _addToSyncQueue(txn, 'bills', 'INSERT', values);
      }
      await _recalcStudentAggregates(txn, studentId);
    });

    refreshStudentFullCache();
    return id;
  }

  Future<String> recordPayment({
    String? id,
    String? billId,
    required String studentId,
    required double amount,
    required DateTime datePaid,
    String? method,
    String? adminUid,
    bool queueForSync = false,
  }) async {
    final db = await database;
    final pid = id ?? _generateId('PAY');
    final now = DateTime.now().millisecondsSinceEpoch;

    final values = {
      'id': pid,
      'bill_id': billId,
      'student_id': studentId,
      'amount': amount,
      'date_paid': datePaid.toIso8601String(),
      'method': method ?? 'Cash',
      'admin_uid': adminUid,
      'created_at': now,
    };

    await db.transaction((txn) async {
      await txn.insert('payments', values);

      if (billId != null) {
        await txn.rawUpdate(
          'UPDATE bills SET paid_amount = IFNULL(paid_amount,0) + ? WHERE id = ?',
          [amount, billId],
        );
        final bill = await txn.query(
          'bills',
          where: 'id = ?',
          whereArgs: [billId],
          limit: 1,
        );
        if (bill.isNotEmpty) {
          final total = (bill.first['total_amount'] as num).toDouble();
          final paid = (bill.first['paid_amount'] as num).toDouble();
          if (paid >= total) {
            await txn.update(
              'bills',
              {'is_closed': 1},
              where: 'id = ?',
              whereArgs: [billId],
            );
          }
        }
      }

      if (queueForSync) {
        await _addToSyncQueue(txn, 'payments', 'INSERT', values);
      }
      await _recalcStudentAggregates(txn, studentId);
    });

    refreshStudentFullCache();
    return pid;
  }

  // ---------------------------------------------------------------------------
  // 4. WATERFALL BILLING (Unified Logic)
  // ---------------------------------------------------------------------------

  Future<int> runAutoBillingRoutine() async {
    debugPrint("🌊 Starting Billing Waterfall...");
    int total = 0;
    total += await _runMonthlyBillingWaterfall();
    total += await _runTermlyBillingWaterfall();
    total += await _runYearlyBillingWaterfall();

    if (total > 0) refreshStudentFullCache();
    return total;
  }

  Future<int> _runMonthlyBillingWaterfall() async {
    final db = await database;
    final now = DateTime.now();
    final currentMonthKey = DateFormat('yyyy-MM').format(now);
    int count = 0;

    await db.transaction((txn) async {
      final students = await txn.query(
        'students',
        where: 'is_active = 1 AND billing_type = ?',
        whereArgs: ['monthly'],
      );
      for (var s in students) {
        final fee = (s['default_fee'] as num?)?.toDouble() ?? 0.0;
        if (fee <= 0) continue;
        final sid = s['id'] as String;

        final exists = await txn.query(
          'bills',
          where: 'student_id = ? AND month_year = ?',
          whereArgs: [sid, currentMonthKey],
        );
        if (exists.isEmpty) {
          DateTime anchor;
          try {
            anchor = DateTime.parse(s['billing_date'] as String);
          } catch (_) {
            anchor = now;
          }
          final strictDueDate = DateTime(now.year, now.month, anchor.day);
          await _insertBill(
            txn,
            s,
            sid,
            fee,
            currentMonthKey,
            strictDueDate,
            'monthly',
          );
          count++;
        }
      }
    });
    return count;
  }

  Future<int> _runTermlyBillingWaterfall() async {
    final db = await database;
    final now = DateTime.now();
    int count = 0;
    final terms = await getTermsForYear(now.year);

    await db.transaction((txn) async {
      final students = await txn.query(
        'students',
        where: 'is_active = 1 AND billing_type = ?',
        whereArgs: ['termly'],
      );
      for (var term in terms) {
        final termDatesJson = term['term_dates'] as String?;
        if (termDatesJson == null) continue;
        final termId = term['id'] as String;
        final datesMap = jsonDecode(termDatesJson) as Map<String, dynamic>;

        for (final entry in datesMap.entries) {
          final termSegment = entry.key;
          final d = entry.value as Map<String, dynamic>;
          final startDate = DateTime.parse(d['start']);
          // Don't bill if term is > 14 days away
          if (now.isBefore(startDate.subtract(const Duration(days: 14)))) {
            continue;
          }
          final compositeKey = "$termId-$termSegment";

          for (var s in students) {
            final fee = (s['default_fee'] as num?)?.toDouble() ?? 0.0;
            if (fee <= 0) continue;
            final sid = s['id'] as String;

            final exists = await txn.query(
              'bills',
              where: 'student_id = ? AND term_id = ?',
              whereArgs: [sid, compositeKey],
            );
            if (exists.isEmpty) {
              await _insertBill(
                txn,
                s,
                sid,
                fee,
                null,
                startDate,
                'termly',
                termId: compositeKey,
              );
              count++;
            }
          }
        }
      }
    });
    return count;
  }

  Future<int> _runYearlyBillingWaterfall() async {
    final db = await database;
    final now = DateTime.now();
    final currentYearKey = now.year.toString();
    int count = 0;

    await db.transaction((txn) async {
      final students = await txn.query(
        'students',
        where: 'is_active = 1 AND billing_type = ?',
        whereArgs: ['yearly'],
      );
      for (var s in students) {
        final fee = (s['default_fee'] as num?)?.toDouble() ?? 0.0;
        if (fee <= 0) continue;
        final sid = s['id'] as String;

        final exists = await txn.query(
          'bills',
          where: 'student_id = ? AND month_year = ?',
          whereArgs: [sid, currentYearKey],
        );
        if (exists.isEmpty) {
          final dueDate = DateTime(now.year, 1, 31);
          await _insertBill(
            txn,
            s,
            sid,
            fee,
            currentYearKey,
            dueDate,
            'yearly',
          );
          count++;
        }
      }
    });
    return count;
  }

  Future<void> _insertBill(
    Transaction txn,
    Map<String, Object?> studentRow,
    String sid,
    double fee,
    String? monthYear,
    DateTime dueDate,
    String type, {
    String? termId,
  }) async {
    final now = DateTime.now();
    final newBill = {
      'id': _generateId('BILL'),
      'student_id': sid,
      'term_id': termId,
      'total_amount': fee,
      'paid_amount': 0.0,
      'month_year': monthYear,
      'due_date': dueDate.toIso8601String(),
      'bill_type': type,
      'cycle_interval': type,
      'is_closed': 0,
      'created_at': now.millisecondsSinceEpoch,
      'updated_at': now.millisecondsSinceEpoch,
      'admin_uid': studentRow['admin_uid'],
    };

    await txn.insert('bills', newBill);
    await _addToSyncQueue(txn, 'bills', 'INSERT', newBill);
    await _recalcStudentAggregates(txn, sid);
  }

  // ---------------------------------------------------------------------------
  // 5. INTERNAL HELPERS (Aggregates & Sync)
  // ---------------------------------------------------------------------------

  Future<void> _recalcStudentAggregates(
    Transaction txn,
    String studentId,
  ) async {
    final billRes = await txn.rawQuery(
      'SELECT SUM(total_amount) as t FROM bills WHERE student_id = ?',
      [studentId],
    );
    final totalBilled = (billRes.first['t'] as num?)?.toDouble() ?? 0.0;

    final payRes = await txn.rawQuery(
      'SELECT SUM(amount) as t FROM payments WHERE student_id = ?',
      [studentId],
    );
    final totalPaid = (payRes.first['t'] as num?)?.toDouble() ?? 0.0;

    final owed = (totalBilled - totalPaid).clamp(0.0, double.infinity);

    await txn.update(
      'students',
      {'paid_total': totalPaid, 'owed_total': owed},
      where: 'id = ?',
      whereArgs: [studentId],
    );
  }

  Future<void> recalcStudentAggregates(String studentId) async {
    final db = await database;
    await db.transaction((txn) async {
      await _recalcStudentAggregates(txn, studentId);
    });
    _emitChange({'action': 'recalc_student', 'id': studentId});
  }

  Future<void> _addToSyncQueue(
    Transaction txn,
    String table,
    String op,
    Map<String, dynamic> data,
  ) async {
    await txn.insert('sync_queue', {
      'table_name': table,
      'operation': op,
      'payload': jsonEncode(data),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'tries': 0,
    });
  }

  // ---------------------------------------------------------------------------
  // 6. GENERIC CRUD & HELPERS
  // ---------------------------------------------------------------------------

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    bool queueForSync = false,
  }) async {
    final db = await database;
    int id = 0;
    await db.transaction((txn) async {
      id = await txn.insert(
        table,
        values,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (queueForSync) {
        await _addToSyncQueue(txn, table, 'INSERT', values);
      }
    });
    return id;
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values,
    String where,
    List<Object?> whereArgs, {
    bool queueForSync = false,
  }) async {
    final db = await database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.update(
        table,
        values,
        where: where,
        whereArgs: whereArgs,
      );
      if (queueForSync) {
        await _addToSyncQueue(txn, table, 'UPDATE', values);
      }
    });
    return count;
  }

  Future<int> delete(
    String table,
    String where,
    List<Object?> whereArgs, {
    bool queueForSync = false,
  }) async {
    final db = await database;
    int count = 0;
    await db.transaction((txn) async {
      count = await txn.delete(table, where: where, whereArgs: whereArgs);
      if (queueForSync && whereArgs.isNotEmpty) {
        await _addToSyncQueue(txn, table, 'DELETE', {'id': whereArgs.first});
      }
    });
    return count;
  }

  Future<List<Map<String, Object?>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  Future<int> rawUpdate(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  Future<int> rawDelete(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawDelete(sql, arguments);
  }

  Future<int> rawInsert(String sql, [List<Object?>? arguments]) async {
    final db = await database;
    return await db.rawInsert(sql, arguments);
  }

  // ---------------------------------------------------------------------------
  // 7. GETTERS & SPECIAL QUERIES
  // ---------------------------------------------------------------------------

  Future<List<Map<String, Object?>>> getStudentBills(String studentId) async {
    final db = await database;
    return await db.query(
      'bills',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, Object?>>> getTermsForYear(int year) async {
    final db = await database;
    return await db.query(
      'school_terms',
      where: 'academic_year = ?',
      whereArgs: [year],
      orderBy: 'term_number ASC',
    );
  }

  Future<List<Map<String, Object?>>> getAllTeachers() async {
    final db = await database;
    return await db.query('teachers', orderBy: 'full_name ASC');
  }

  Future<List<Map<String, Object?>>> getAllClasses() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT c.*, t.full_name as teacher_name 
      FROM classes c 
      LEFT JOIN teachers t ON c.teacher_id = t.id 
      ORDER BY c.name ASC
    ''');
  }

  Future<List<Map<String, Object?>>> getAttendanceForClass(
    String classId,
    String date,
  ) async {
    final db = await database;
    return await db.query(
      'attendance',
      where: 'class_id = ? AND date = ?',
      whereArgs: [classId, date],
    );
  }

  Future<List<Map<String, dynamic>>> getActiveCampaigns() async {
    final db = await database;
    return await db.query(
      'campaigns',
      where: 'is_active = 1',
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, Object?>>> getPendingSyncOperations({
    int limit = 50,
  }) async {
    final db = await database;
    return await db.query(
      'sync_queue',
      orderBy: 'created_at ASC',
      limit: limit,
    );
  }

  Future<void> confirmSyncList(List<int> ids) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var id in ids) {
        await txn.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
      }
    });
  }

  Future<void> setMetadata(String key, String value) async {
    final db = await database;
    await db.insert('metadata', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getMetadata(String key) async {
    final db = await database;
    final res = await db.query('metadata', where: 'key = ?', whereArgs: [key]);
    return res.isNotEmpty ? res.first['value'] as String? : null;
  }

  Future<void> saveBillingConfig(BillingConfig config, {String? schoolId}) async {
    final db = await database;
    await db.insert('billing_settings', {
      'id': 'current_config',
      'config_json': config.toJson(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    // Persist terms into dedicated table if a school is known
    if (schoolId != null && schoolId.isNotEmpty) {
      await db.transaction((txn) async {
        await txn.delete('school_terms', where: 'school_id = ?', whereArgs: [schoolId]);

        for (var i = 0; i < config.terms.length; i++) {
          final term = config.terms[i];
          final termId = term.id.isNotEmpty ? term.id : _generateId('TERM');
          final yearInt = int.tryParse(term.year) ?? DateTime.now().year;
          await txn.insert('school_terms', {
            'id': termId,
            'school_id': schoolId,
            'name': term.name,
            'academic_year': yearInt,
            'start_date': term.start.toIso8601String(),
            'end_date': term.end.toIso8601String(),
            'term_number': i + 1,
            'created_at': DateTime.now().millisecondsSinceEpoch,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    }

    _emitChange({'action': 'update_billing_config'});
  }

  Future<BillingConfig> getBillingConfig() async {
    final db = await database;
    try {
      final res = await db.query(
        'billing_settings',
        where: 'id = ?',
        whereArgs: ['current_config'],
      );
      if (res.isNotEmpty) {
        return BillingConfig.fromJson(res.first['config_json'] as String);
      }
    } catch (_) {}
    return BillingConfig();
  }

  // ---------------------------------------------------------------------------
  // 8. HYDRATION
  // ---------------------------------------------------------------------------

  Future<List<StudentFull>> refreshStudentFullCache({
    bool includeInactive = false,
  }) async {
    final db = await database;
    try {
      final where = includeInactive ? null : 'is_active = 1';
      final studentsData = await db.query(
        'students',
        where: where,
        orderBy: 'full_name ASC',
      );

      List<StudentFull> results = [];
      for (var sRow in studentsData) {
        final sid = sRow['id'] as String;
        final billsData = await db.query(
          'bills',
          where: 'student_id = ?',
          whereArgs: [sid],
          orderBy: 'created_at DESC',
        );
        final paymentsData = await db.query(
          'payments',
          where: 'student_id = ?',
          whereArgs: [sid],
          orderBy: 'date_paid DESC',
        );

        final sModel = StudentModel.fromMap(sRow);
        final bModels = billsData.map((e) => BillModel.fromMap(e)).toList();
        final pModels = paymentsData
            .map((e) => PaymentModel.fromMap(e))
            .toList();

        results.add(
          StudentFull(student: sModel, bills: bModels, payments: pModels),
        );
      }
      _studentFullCache = results;
      _studentStreamController.add(results);
      return results;
    } catch (e) {
      debugPrint("Cache refresh error: $e");
      return [];
    }
  }

  Future<List<StudentFull>> getAllStudentsWithFinancials({
    bool includeInactive = false,
  }) async {
    if (_studentFullCache == null) {
      return await refreshStudentFullCache(includeInactive: includeInactive);
    }
    if (!includeInactive) {
      return _studentFullCache!.where((s) => s.student.isActive).toList();
    }
    return _studentFullCache!;
  }

  Future<StudentFull?> getStudentFullById(String id) async {
    final list = await getAllStudentsWithFinancials(includeInactive: true);
    try {
      return list.firstWhere((s) => s.student.id == id);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // 9. WRAPPERS & UTILS
  // ---------------------------------------------------------------------------

  String _generateId(String prefix) {
    return '${prefix}_${const Uuid().v4().substring(0, 8).toUpperCase()}';
  }

  void _emitChange(Map<String, dynamic> event) {
    if (!_changeController.isClosed) _changeController.add(event);
  }

  Future<void> wipeAllData() async {
    final db = await database;
    final tables = [
      'students',
      'bills',
      'payments',
      'expenses',
      'classes',
      'teachers',
      'school_terms',
      'sync_queue',
      'notifications',
      'attendance',
      'campaigns',
    ];
    await db.transaction((txn) async {
      for (var t in tables) {
        await txn.delete(t);
      }
    });
    refreshStudentFullCache();
  }

  // Creation helper wrappers to maintain API compatibility
  Future<String> createTerm({
    String? id,
    required String name,
    required int academicYear,
    required Map<int, Map<String, DateTime>> termDates,
    int? termNumber,
    String? schoolId,
  }) async {
    final tid = id ?? _generateId('TERM');
    final mappedDates = <String, Map<String, String>>{};
    termDates.forEach((k, v) {
      mappedDates['$k'] = {
        'start': v['start']!.toIso8601String(),
        'end': v['end']!.toIso8601String(),
      };
    });
    await insert('school_terms', {
      'id': tid,
      'school_id': schoolId,
      'name': name,
      'academic_year': academicYear,
      'term_number': termNumber,
      'term_dates': jsonEncode(mappedDates),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    return tid;
  }

  Future<String> createTeacher(
    Map<String, dynamic> values, {
    bool queueForSync = true,
  }) async {
    final id = _generateId('TCH');
    values['id'] = id;
    values['created_at'] = DateTime.now().millisecondsSinceEpoch;
    await insert('teachers', values, queueForSync: queueForSync);
    return id;
  }

  Future<String> createClass(
    Map<String, dynamic> values, {
    bool queueForSync = true,
  }) async {
    final id = _generateId('CLS');
    values['id'] = id;
    values['created_at'] = DateTime.now().millisecondsSinceEpoch;
    await insert('classes', values, queueForSync: queueForSync);
    return id;
  }

  Future<String> enrollStudentInClass({
    required String studentId,
    required String classId,
  }) async {
    final db = await database;
    final exists = await db.query(
      'enrollments',
      where: 'student_id = ? AND class_id = ?',
      whereArgs: [studentId, classId],
    );
    if (exists.isNotEmpty) return exists.first['id'] as String;
    final id = _generateId('ENR');
    await insert('enrollments', {
      'id': id,
      'student_id': studentId,
      'class_id': classId,
      'enrolled_at': DateTime.now().toIso8601String(),
    }, queueForSync: true);
    return id;
  }

  Future<void> markAttendance(Map<String, dynamic> values) async {
    final id = _generateId('ATT');
    values['id'] = id;
    values['created_at'] = DateTime.now().millisecondsSinceEpoch;
    await insert('attendance', values, queueForSync: true);
  }

  Future<int> recordExpense({
    required String title,
    required double amount,
    required DateTime date,
  }) async {
    final id = _generateId('EXP');
    return await insert('expenses', {
      'id': id,
      'title': title,
      'amount': amount,
      'date_incurred': date.toIso8601String(),
    });
  }

  Future<String> createCampaign(
    Map<String, dynamic> values, {
    bool queueForSync = true,
  }) async {
    final id = _generateId('CMP');
    values['id'] = id;
    values['created_at'] = DateTime.now().millisecondsSinceEpoch;
    await insert('campaigns', values, queueForSync: queueForSync);
    return id;
  }

  Future<int> generateBackdatedBillsForStudent(String studentId) async {
    return 0;
  }

  // ---------------------------------------------------------------------------
  // TEACHER ACCESS TOKENS & ATTENDANCE SESSIONS (Permission-Based Access)
  // ---------------------------------------------------------------------------

  /// Generate a one-time access code for a teacher to delegate attendance/campaign duties
  /// 
  /// Returns the access code string
  Future<String> createTeacherAccessToken({
    required String schoolId,
    required String teacherId,
    required String permissionType, // 'attendance', 'campaigns', or 'both'
    required Duration expiresIn,
  }) async {
    final id = _generateId('TAT');
    final accessCode = _generateAccessCode();
    final expiresAt = DateTime.now().add(expiresIn);

    await insert(
      'teacher_access_tokens',
      {
        'id': id,
        'school_id': schoolId,
        'teacher_id': teacherId,
        'granted_by_teacher_id': teacherId,
        'access_code': accessCode,
        'permission_type': permissionType,
        'is_used': 0,
        'used_at': null,
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      queueForSync: true,
    );

    return accessCode;
  }

  /// Get all unused access tokens for a school
  Future<List<Map<String, Object?>>> getUnusedAccessTokens(String schoolId) async {
    final db = await database;
    return await db.query(
      'teacher_access_tokens',
      where: 'school_id = ? AND is_used = 0 AND expires_at > ?',
      whereArgs: [schoolId, DateTime.now().toIso8601String()],
      orderBy: 'created_at DESC',
    );
  }

  /// Get access token by code
  Future<Map<String, Object?>?> getAccessTokenByCode(String code) async {
    final db = await database;
    final result = await db.query(
      'teacher_access_tokens',
      where: 'access_code = ?',
      whereArgs: [code],
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Mark access token as used
  Future<void> markAccessTokenAsUsed(String tokenId) async {
    await update(
      'teacher_access_tokens',
      {
        'is_used': 1,
        'used_at': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [tokenId],
    );
  }

  /// Create an attendance session (used by student_admin with valid token)
  /// 
  /// Returns the session ID
  Future<String> createAttendanceSession({
    required String schoolId,
    required String classId,
    required String teacherId,
    required String studentAdminId,
    required String accessTokenId,
    required DateTime sessionDate,
  }) async {
    final id = _generateId('ASS');

    await insert(
      'attendance_sessions',
      {
        'id': id,
        'school_id': schoolId,
        'class_id': classId,
        'teacher_id': teacherId,
        'student_admin_id': studentAdminId,
        'access_token_id': accessTokenId,
        'session_date': sessionDate.toIso8601String(),
        'is_confirmed_by_teacher': 0,
        'confirmed_at': null,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      queueForSync: true,
    );

    return id;
  }

  /// Get pending attendance sessions awaiting teacher confirmation
  Future<List<Map<String, Object?>>> getPendingAttendanceSessions(
    String teacherId,
  ) async {
    final db = await database;
    return await db.query(
      'attendance_sessions',
      where: 'teacher_id = ? AND is_confirmed_by_teacher = 0',
      whereArgs: [teacherId],
      orderBy: 'created_at DESC',
    );
  }

  /// Confirm an attendance session by teacher
  Future<void> confirmAttendanceSession(String sessionId) async {
    await update(
      'attendance_sessions',
      {
        'is_confirmed_by_teacher': 1,
        'confirmed_at': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [sessionId],
    );
  }

  /// Get all attendance sessions for a school (admin view)
  Future<List<Map<String, Object?>>> getAttendanceSessionsForSchool(
    String schoolId,
  ) async {
    final db = await database;
    return await db.query(
      'attendance_sessions',
      where: 'school_id = ?',
      whereArgs: [schoolId],
      orderBy: 'created_at DESC',
    );
  }

  /// Mark attendance for multiple students in a session
  Future<void> markBulkAttendance({
    required String sessionId,
    required String classId,
    required DateTime attendanceDate,
    required List<Map<String, dynamic>> attendanceRecords, // [{studentId, status}, ...]
  }) async {
    final db = await database;
    final batch = db.batch();

    // Get session details
    final sessions = await db.query(
      'attendance_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (sessions.isEmpty) throw Exception('Attendance session not found');

    final session = sessions.first;
    final schoolId = session['school_id'] as String;

    // Insert attendance records
    for (final record in attendanceRecords) {
      final attendanceId = _generateId('ATT');
      batch.insert(
        'attendance',
        {
          'id': attendanceId,
          'school_id': schoolId,
          'student_id': record['student_id'],
          'class_id': classId,
          'date': attendanceDate.toIso8601String(),
          'status': record['status'] ?? 'present',
          'remarks': record['remarks'],
          'admin_uid': record['admin_uid'],
          'created_at': DateTime.now().millisecondsSinceEpoch,
        },
      );
    }

    await batch.commit();
  }

  /// Get campaign creation history for school admin
  Future<List<Map<String, Object?>>> getCampaignsForSchool(
    String schoolId,
  ) async {
    final db = await database;
    return await db.query(
      'campaigns',
      where: 'school_id = ?',
      whereArgs: [schoolId],
      orderBy: 'created_at DESC',
    );
  }

  /// Update campaign status
  Future<void> updateCampaignStatus(
    String campaignId,
    String status,
  ) async {
    await update(
      'campaigns',
      {
        'status': status,
      },
      'id = ?',
      [campaignId],
    );
  }

  // ---------------------------------------------------------------------------
  // UTILITY METHODS
  // ---------------------------------------------------------------------------

  /// Generate a random access code (6 alphanumeric characters)
  String _generateAccessCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().microsecond;
    String code = '';
    for (int i = 0; i < 6; i++) {
      code += chars[(random + i) % chars.length];
    }
    return code;
  }

  Future<void> close() async {
    if (_db != null) await _db!.close();
    _changeController.close();
    _studentStreamController.close();
  }
}
