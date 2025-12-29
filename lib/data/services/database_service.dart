import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'schema.dart';
import 'supabase_connector.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late PowerSyncDatabase _db;
  bool _isInitialized = false;
  late String _dbPath; // Store path locally since PS doesn't expose it

  PowerSyncDatabase get db => _db;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final dir = await getApplicationSupportDirectory();
    _dbPath = join(dir.path, 'greyway_feesup.db');

    _db = PowerSyncDatabase(
      schema: appSchema,
      path: _dbPath,
    );

    await _db.initialize();

    final connector = SupabaseConnector(Supabase.instance.client);
    _db.connect(connector: connector);

    _isInitialized = true;
    if (kDebugMode) {
      print("✅ Database Service Initialized & Connected");
    }
  }

  /// THE NUCLEAR OPTION
  /// Wipes local SQLite and disconnects.
  Future<void> factoryReset() async {
    try {
      await _db.close();
      final file = File(_dbPath);
      if (await file.exists()) {
        await file.delete();
      }
      _isInitialized = false;
      debugPrint("✅ Local database wiped completely.");
    } catch (e) {
      debugPrint("❌ Error during factory reset: $e");
    }
  }

  bool get isConnected => _db.currentStatus.connected;

  Stream<List<Map<String, dynamic>>> watchAll(String table) {
    return _db.watch('SELECT * FROM $table ORDER BY created_at DESC');
  }

  /// Required by Student and Payment Dialogs
  Stream<List<Map<String, dynamic>>> watchStudents(String schoolId) {
    return _db.watch(
      'SELECT * FROM students WHERE school_id = ? ORDER BY full_name ASC',
      parameters: [schoolId],
    );
  }

  /// Runs a raw SQL SELECT query and returns the list of results once.
  /// Useful for one-off fetches like getting the last invoice number.
  Future<List<Map<String, dynamic>>> select(String sql, [List<Object?>? arguments]) async {
    return await _db.getAll(sql, arguments ?? []);
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final results = await _db.getAll('SELECT * FROM $table WHERE id = ?', [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<Map<String, dynamic>?> tryGet(String sql, [List<Object?>? arguments]) async {
    final results = await _db.getAll(sql, arguments ?? []);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    final keys = data.keys.toList();
    final values = data.values.toList();
    final placeholders = List.filled(keys.length, '?').join(', ');
    final columns = keys.join(', ');
    final sql = 'INSERT INTO $table ($columns) VALUES ($placeholders)';
    await _db.execute(sql, values);
  }

  Future<void> update(String table, String id, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    final updates = <String>[];
    final values = <dynamic>[];
    data.forEach((key, value) {
      updates.add('$key = ?');
      values.add(value);
    });
    values.add(id);
    final sql = 'UPDATE $table SET ${updates.join(', ')} WHERE id = ?';
    await _db.execute(sql, values);
  }

  Future<void> delete(String table, String id) async {
    await _db.execute('DELETE FROM $table WHERE id = ?', [id]);
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await getById('user_profiles', userId);
  }
}