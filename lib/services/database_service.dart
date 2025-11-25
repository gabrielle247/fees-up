// lib/services/database_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;
  bool get isOpen => _db != null && _db!.isOpen;

  // 🛑 EXPOSE RAW DB for Sync Service
  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    await init();
    return _db!;
  }

  // --------------------------
  // 1. Initialization and Schema
  // --------------------------
  Future<void> init() async {
    if (isOpen) return;

    final docs = await getApplicationDocumentsDirectory();
    final dbPath = join(docs.path, 'feesup.db');

    // lib/services/database_service.dart

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        // Students Table
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            studentId TEXT UNIQUE, 
            studentName TEXT,
            registrationDate TEXT,
            isActive INTEGER,       
            defaultMonthlyFee REAL,
            parentContact TEXT,
            subjects TEXT,          
            frequency TEXT,
            admin_uid TEXT           -- 🛑 ADDED: For local ownership consistency
          )
        ''');

        // Bills Table
        await db.execute('''
          CREATE TABLE bills (
            id TEXT PRIMARY KEY,    
            studentId TEXT,
            totalAmount REAL,
            paidAmount REAL,
            monthYear TEXT,
            dueDate TEXT,
            createdAt TEXT,
            admin_uid TEXT           -- 🛑 ADDED: For local ownership consistency
          )
        ''');

        // Payments Table
        await db.execute('''
          CREATE TABLE payments (
            id TEXT PRIMARY KEY,
            billId TEXT,
            studentId TEXT,
            amount REAL,
            datePaid TEXT,
            method TEXT,
            admin_uid TEXT           -- 🛑 ADDED: For local ownership consistency
          )
        ''');

        // Notifications Table
        await db.execute('''
          CREATE TABLE notifications (
            id TEXT PRIMARY KEY,
            title TEXT,
            body TEXT,
            timestamp TEXT,
            isRead INTEGER,         
            type TEXT,
            admin_uid TEXT           -- 🛑 ADDED: For local ownership consistency
          )
        ''');

        // 🛑 ADMIN PROFILE (No change needed, already uses 'id' as primary key)
        await db.execute('''
          CREATE TABLE admin_profile (
            id TEXT PRIMARY KEY,       
            email TEXT,
            full_name TEXT,
            school_name TEXT,
            avatar_url TEXT,           
            last_synced_at TEXT
          )
        ''');

        // LOCAL SYNC QUEUE
        await db.execute('''
          CREATE TABLE local_sync_status (
            table_name TEXT,
            record_id TEXT,
            action TEXT,
            PRIMARY KEY (table_name, record_id)
          )
        ''');
      },
      // 🛑 CRITICAL FIX: onOpen runs every time the DB opens.
      // We must ensure the IF NOT EXISTS definitions match the onCreate logic.
      onOpen: (db) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS students (
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            studentId TEXT UNIQUE, 
            studentName TEXT,
            registrationDate TEXT,
            isActive INTEGER,       
            defaultMonthlyFee REAL,
            parentContact TEXT,
            subjects TEXT,          
            frequency TEXT,
            admin_uid TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS bills (
            id TEXT PRIMARY KEY,    
            studentId TEXT,
            totalAmount REAL,
            paidAmount REAL,
            monthYear TEXT,
            dueDate TEXT,
            createdAt TEXT,
            admin_uid TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS payments (
            id TEXT PRIMARY KEY,
            billId TEXT,
            studentId TEXT,
            amount REAL,
            datePaid TEXT,
            method TEXT,
            admin_uid TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS notifications (
            id TEXT PRIMARY KEY,
            title TEXT,
            body TEXT,
            timestamp TEXT,
            isRead INTEGER,         
            type TEXT,
            admin_uid TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS admin_profile (
            id TEXT PRIMARY KEY,
            email TEXT,
            full_name TEXT,
            school_name TEXT,
            avatar_url TEXT,
            last_synced_at TEXT
          )
        ''');

        // Ensure local_sync_status exists
        await db.execute('''
          CREATE TABLE IF NOT EXISTS local_sync_status (
            table_name TEXT,
            record_id TEXT,
            action TEXT,
            PRIMARY KEY (table_name, record_id)
          )
        ''');
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  // --------------------------
  // 2. Core CRUD Operations
  // --------------------------

  Future<int> insert(String table, Map<String, dynamic> data) async {
    await init();
    return await _db!.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateStudent(String studentId, Map<String, dynamic> data) async {
    await init();
    return await _db!.update(
      'students',
      data,
      where: 'studentId = ?',
      whereArgs: [studentId],
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    required String where,
    required List whereArgs,
  }) async {
    await init();
    return await _db!.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    required String where,
    required List whereArgs,
  }) async {
    await init();
    return await _db!.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    await init();
    return await _db!.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List whereArgs,
  ) async {
    await init();
    return await _db!.query(table, where: where, whereArgs: whereArgs);
  }

  Future<void> clearTable(String table) async {
    await init();
    await _db!.delete(table);
  }

  // --------------------------
  // 3. JSON Migration Helper
  // --------------------------

  String? _tableFromFilename(String fname) {
    if (fname.contains('student')) return 'students';
    if (fname.contains('bill')) return 'bills';
    if (fname.contains('payment')) return 'payments';
    if (fname.contains('notification')) return 'notifications';
    return null;
  }

  Future<void> migrateFromJsonFiles({
    List<String> filenames = const [
      'students.json',
      'bills.json',
      'payments.json',
      'notifications.json',
    ],
  }) async {
    await init();
    try {
      final docs = await getApplicationDocumentsDirectory();
      for (final fname in filenames) {
        final f = File(join(docs.path, fname));
        if (!await f.exists()) continue;

        final contents = await f.readAsString();
        if (contents.trim().isEmpty) continue;

        dynamic decoded;
        try {
          decoded = jsonDecode(contents);
        } catch (e) {
          debugPrint(
            'DatabaseService:migrateFromJsonFiles: invalid json for $fname -> $e',
          );
          continue;
        }

        List<dynamic> list = (decoded is List) ? decoded : [decoded];
        final table = _tableFromFilename(fname);
        if (table == null) continue;

        await _db!.transaction((txn) async {
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final normalized = Map<String, dynamic>.from(item);

              if (normalized.containsKey('subjects') &&
                  normalized['subjects'] is List) {
                normalized['subjects'] = jsonEncode(normalized['subjects']);
              }

              if (normalized.containsKey('isActive') &&
                  normalized['isActive'] is bool) {
                normalized['isActive'] = normalized['isActive'] ? 1 : 0;
              }

              if (normalized.containsKey('isRead') &&
                  normalized['isRead'] is bool) {
                normalized['isRead'] = normalized['isRead'] ? 1 : 0;
              }

              await txn.insert(
                table,
                normalized,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          }
        });
        debugPrint('✅ Migration successful for $fname into $table.');
      }
    } catch (e) {
      debugPrint('❌ Error during migration: $e');
    }
  }

  // Leftover code for reference, not used currently
  // Future<Student?> _getStudentByStudentId(String studentId) async {
  // final rows = await _db.queryWhere('students', 'studentId = ?', [studentId]); [cite_start]// Use existing DB queryWhere [cite: 399]
  // if (rows.isEmpty) return null; [cite_start]// Handle no result [cite: 400]
  // return _rowToStudent(rows.first); [cite_start]// Convert back to model [cite: 401]

  // --------------------------
  // 4. Critical Actions
  // --------------------------
  Future<void> wipeAllBusinessData() async {
    await init();
    await _db!.transaction((txn) async {
      // Clear core business tables
      await txn.delete('students');
      await txn.delete('bills');
      await txn.delete('payments');
      await txn.delete('notifications');
      await txn.delete('local_sync_status');

      // NOTE: We do NOT delete 'admin_profile' so you stay logged in.
    });
    debugPrint("⚠️ DATABASE WIPED: All business data cleared.");
  }
}
