// lib/brick/brick.g.dart
// GENERATED CODE - DO NOT MODIFY BY HAND
// This file is the main Brick configuration that connects models with adapters

import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:brick_sqlite/brick_sqlite.dart';
import 'package:brick_supabase/brick_supabase.dart';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

// Import models
import '../models/student_brick.dart';

// Import adapters
import 'adapters/student_adapter.g.dart';

/// Concrete Brick repository configuration with generated adapters.
/// Configures offline-first data sync with Supabase backend and encrypted SQLite storage.
Future<OfflineFirstWithSupabaseRepository> initializeBrickRepository({
  required String databasePath,
  required String encryptionKey,
  required String supabaseUrl,
  required String supabaseAnonKey,
}) async {
  // Configure Supabase provider
  final supabaseProvider = SupabaseProvider(
    supabaseUrl,
    supabaseAnonKey,
    modelDictionary: {
      ...studentModelDictionary,
      // Add more model dictionaries as they are created
    },
  );

  // Configure SQLite provider with encryption
  final sqliteProvider = SqliteProvider(
    databasePath,
    modelDictionary: {
      ...studentSqliteDictionary,
      // Add more SQLite dictionaries as they are created
    },
    databaseFactory: databaseFactoryCipher,
  );

  // Initialize the encrypted database
  await sqliteProvider.resetDb();

  // Create and return repository
  return OfflineFirstWithSupabaseRepository(
    supabaseProvider: supabaseProvider,
    sqliteProvider: sqliteProvider,
    migrations: {
      // Add migrations as schema evolves
      // Example:
      // const Migration(version: 1, up: _migration1Up, down: _migration1Down),
    },
    offlineRequestQueue: RestOfflineQueueClient(
      supabaseProvider.client,
    ),
  );
}

// Future migration examples (uncomment when needed)
/*
Future<void> _migration1Up(Batch batch, Database db) async {
  // Add new columns, tables, etc.
  // Example:
  // await db.execute('ALTER TABLE Student ADD COLUMN new_field TEXT');
}

Future<void> _migration1Down(Batch batch, Database db) async {
  // Revert changes from _migration1Up
}
*/
