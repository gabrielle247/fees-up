import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
// import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Uncomment for Desktop/Test support

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  // VERSION BUMP: Set to 2 to trigger onUpgrade for existing users
  static const int _dbVersion = 2;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    await init();
    return _db!;
  }

  Future<void> init() async {
    if (_db != null && _db!.isOpen) return;

    final docsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDirectory.path, 'fees_up_core.db');

    _db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      // 1. PRIMARY CREATION (Runs if DB doesn't exist)
      onCreate: (db, version) async {
        await _createTables(db);
      },
      // 2. MIGRATION LOGIC (Runs if DB exists but version is lower)
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // If the user has version 1, add the 'grade' column.
          // Wrapped in try-catch to be safe if it somehow exists.
          try {
            await db.execute("ALTER TABLE students ADD COLUMN grade TEXT");
            debugPrint("MIGRATION SUCCESS: Added 'grade' column to students table.");
          } catch (e) {
            debugPrint(
              "MIGRATION INFO: Column 'grade' might already exist. Error: $e",
            );
          }
        }
      },
      // 3. SAFETY CHECK (Runs every time DB opens)
      onOpen: (db) async {
        // Ensures tables exist even if file was corrupted
        await _createTables(db, ifNotExists: true);
      },
    );
  }

  // Helper function to define schema in one place
  Future<void> _createTables(Database db, {bool ifNotExists = false}) async {
    final constraint = ifNotExists ? 'IF NOT EXISTS' : '';

    // 1. Students Table
    await db.execute('''
      CREATE TABLE $constraint students (
        id TEXT PRIMARY KEY,
        full_name TEXT NOT NULL,
        grade TEXT, 
        parent_contact TEXT,
        registration_date TEXT,
        is_active INTEGER DEFAULT 1,
        default_monthly_fee REAL,
        subjects TEXT, -- JSON String
        admin_uid TEXT
      )
    ''');

    // 2. Bills Table
    await db.execute('''
      CREATE TABLE $constraint bills (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0.0,
        month_year TEXT NOT NULL,         
        billing_cycle_start TEXT NOT NULL, 
        cycle_interval TEXT DEFAULT 'monthly',
        created_at TEXT,
        updated_at TEXT,
        admin_uid TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // 3. Payments Table
    await db.execute('''
      CREATE TABLE $constraint payments (
        id TEXT PRIMARY KEY,
        bill_id TEXT,
        student_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date_paid TEXT NOT NULL,
        method TEXT,
        admin_uid TEXT,
        FOREIGN KEY (bill_id) REFERENCES bills (id) ON DELETE SET NULL,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // 4. Notifications Table
    await db.execute('''
      CREATE TABLE $constraint notifications (
        id TEXT PRIMARY KEY,
        title TEXT,
        body TEXT,
        timestamp TEXT,
        is_read INTEGER DEFAULT 0,
        type TEXT,
        admin_uid TEXT
      )
    ''');

    // 5. Sync Queue
    await db.execute('''
      CREATE TABLE $constraint local_sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
        timestamp TEXT NOT NULL
      )
    ''');

    // 6. Admin Profile
    await db.execute('''
      CREATE TABLE $constraint admin_profile (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL UNIQUE,
        full_name TEXT NOT NULL,
        school_name TEXT NOT NULL,
        last_synced_at TEXT,
        avatar_url TEXT
      )
    ''');

    // 7. School Terms Table (NEW)
    await db.execute('''
      CREATE TABLE $constraint school_terms (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        year INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        is_active INTEGER DEFAULT 0, -- 0 or 1
        admin_uid TEXT
      )
    ''');
  }

  // ---------------------------------------------------------------------------
  // GENERIC CRUD OPERATIONS
  // ---------------------------------------------------------------------------

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table,
    String where,
    List<Object?> whereArgs,
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // ---------------------------------------------------------------------------
  // DATA DESTRUCTION
  // ---------------------------------------------------------------------------

  Future<void> wipeAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('payments');
      await txn.delete('bills');
      await txn.delete('students');
      await txn.delete('notifications');
      await txn.delete('local_sync_queue');
      await txn.delete('admin_profile');
    });
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
