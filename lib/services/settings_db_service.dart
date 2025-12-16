import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// A dedicated database service for App Preferences.
/// This is SEPARATE from the main 'fees_up.db' (School Data).
class SettingsDatabaseService {
  // Singleton
  SettingsDatabaseService._internal();
  static final SettingsDatabaseService instance = SettingsDatabaseService._internal();

  static const _dbName = 'app_settings.db'; // Distinct filename
  static const _dbVersion = 1;
  static const _tableName = 'user_preferences';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        // Key-Value store structure for maximum flexibility
        await db.execute('''
          CREATE TABLE $_tableName (
            key TEXT PRIMARY KEY,
            value TEXT,
            type TEXT -- 'bool', 'int', 'string', 'double'
          )
        ''');

        // Insert Defaults
        await db.insert(_tableName, {'key': 'biometric_enabled', 'value': 'false', 'type': 'bool'});
        await db.insert(_tableName, {'key': 'notifications_enabled', 'value': 'true', 'type': 'bool'});
        await db.insert(_tableName, {'key': 'language', 'value': 'English (US)', 'type': 'string'});
        await db.insert(_tableName, {'key': 'dark_mode', 'value': 'true', 'type': 'bool'});
      },
    );
  }

  // --- CRUD Operations ---

  Future<dynamic> getSetting(String key, {dynamic defaultValue}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return defaultValue;

    final row = maps.first;
    final val = row['value'] as String;
    final type = row['type'] as String;

    // Type casting
    if (type == 'bool') return val == 'true';
    if (type == 'int') return int.tryParse(val) ?? defaultValue;
    if (type == 'double') return double.tryParse(val) ?? defaultValue;
    return val; // string
  }

  Future<void> setSetting(String key, dynamic value) async {
    final db = await database;
    String type = 'string';
    String stringVal = value.toString();

    if (value is bool) type = 'bool';
    if (value is int) type = 'int';
    if (value is double) type = 'double';

    await db.insert(
      _tableName,
      {'key': key, 'value': stringVal, 'type': type},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}