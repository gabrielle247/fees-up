import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'schema.dart';
import 'supabase_connector.dart';

/// The Central Engine for Data Management.
/// Handles Initialization, Sync, and basic CRUD operations.
class DatabaseService {
  // Singleton Pattern
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  late final PowerSyncDatabase _db;
  bool _isInitialized = false;

  // Getter to access the raw database if needed
  PowerSyncDatabase get db => _db;

  /// Initialize the Database Engine.
  /// Must be called in main.dart before runApp.
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Define the storage path
    final dir = await getApplicationSupportDirectory();
    final path = join(dir.path, 'greyway_feesup.db');

    // 2. Setup the PowerSync Database with our Schema
    _db = PowerSyncDatabase(
      schema: appSchema,
      path: path,
    );

    // 3. Initialize the database (opens SQLite)
    await _db.initialize();

    // 4. Connect to Supabase
    // Note: Supabase.initialize() must be called in main.dart BEFORE this.
    final connector = SupabaseConnector(Supabase.instance.client);
    
    // FIX: Use named parameter 'connector'
    _db.connect(connector: connector);

    _isInitialized = true;
    if (kDebugMode) {
      print("✅ Database Service Initialized & Connected");
    }
  }

  /// Check if the database is currently connected and syncing
  bool get isConnected => _db.currentStatus.connected;

  // =================================================================
  // GENERIC CRUD OPERATIONS
  // These methods allow you to interact with ANY table defined in schema.
  // =================================================================

  /// Get all records from a table as a List of Maps.
  /// This is reactive and can be used with StreamBuilder.
  Stream<List<Map<String, dynamic>>> watchAll(String table) {
    return _db.watch('SELECT * FROM $table ORDER BY created_at DESC');
  }

  /// Get a single record by ID.
  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final result = await _db.get('SELECT * FROM $table WHERE id = ?', [id]);
    return result; // Returns null if not found
  }

  /// Insert a new record.
  /// Ensure 'id' is a UUID.
  Future<void> insert(String table, Map<String, dynamic> data) async {
    final keys = data.keys.toList();
    final values = data.values.toList();
    
    // Create placeholders (?, ?, ?)
    final placeholders = List.filled(keys.length, '?').join(', ');
    final columns = keys.join(', ');

    final sql = 'INSERT INTO $table ($columns) VALUES ($placeholders)';
    
    await _db.execute(sql, values);
  }

  /// Update an existing record by ID.
  Future<void> update(String table, String id, Map<String, dynamic> data) async {
    if (data.isEmpty) return;

    final updates = <String>[];
    final values = <dynamic>[];

    data.forEach((key, value) {
      updates.add('$key = ?');
      values.add(value);
    });

    // Add ID to the end of values for the WHERE clause
    values.add(id);

    final sql = 'UPDATE $table SET ${updates.join(', ')} WHERE id = ?';
    await _db.execute(sql, values);
  }

  /// Delete a record by ID.
  Future<void> delete(String table, String id) async {
    await _db.execute('DELETE FROM $table WHERE id = ?', [id]);
  }

  // =================================================================
  // SPECIFIC HELPERS
  // =================================================================

  /// Get User Profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    return await getById('user_profiles', userId);
  }

  /// Get Students for the current school
  Stream<List<Map<String, dynamic>>> watchStudents(String schoolId) {
    return _db.watch(
      'SELECT * FROM students WHERE school_id = ? ORDER BY full_name ASC', 
      parameters: [schoolId]
    );
  }
}