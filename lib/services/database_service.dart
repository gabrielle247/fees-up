import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    await init();
    return _db!;
  }

  Future<void> init() async {
    if (_db != null && _db!.isOpen) return;

    final docsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(docsDirectory.path, 'fees_up_core.db');

    // Future-proofing: This is where we will inject the password for SQLCipher later.
    // For now, we use standard openDatabase.
    _db = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _onCreate,
    );
  }

  // Enforce foreign keys support in SQLite
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Students Table
    // Aligned with Supabase schema naming (snake_case)
    await db.execute('''
      CREATE TABLE students (
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
    // Updated to match your new Postgres DDL supporting Billing Cycles
    await db.execute('''
      CREATE TABLE bills (
        id TEXT PRIMARY KEY,
        student_id TEXT NOT NULL,
        total_amount REAL NOT NULL,
        paid_amount REAL DEFAULT 0.0,
        month_year TEXT NOT NULL,         -- ISO8601 String (e.g., "2025-02-01T00:00:00Z")
        billing_cycle_start TEXT NOT NULL, -- ISO8601 String
        cycle_interval TEXT DEFAULT 'monthly',
        created_at TEXT,
        updated_at TEXT,
        admin_uid TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // 3. Payments Table
    await db.execute('''
      CREATE TABLE payments (
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
      CREATE TABLE notifications (
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
    // Critical for offline-first architecture
    await db.execute('''
      CREATE TABLE local_sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        action TEXT NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
        timestamp TEXT NOT NULL
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
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table, 
    String where, 
    List<Object?> whereArgs
  ) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(
    String table, 
    Map<String, dynamic> data, 
    String where, 
    List<Object?> whereArgs
  ) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, 
    String where, 
    List<Object?> whereArgs
  ) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  // ---------------------------------------------------------------------------
  // DATA DESTRUCTION (Logout/Reset)
  // ---------------------------------------------------------------------------
  
  Future<void> wipeAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('payments');
      await txn.delete('bills');
      await txn.delete('students');
      await txn.delete('notifications');
      await txn.delete('local_sync_queue');
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