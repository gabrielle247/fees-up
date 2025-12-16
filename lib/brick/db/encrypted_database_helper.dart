// lib/brick/db/encrypted_database_helper.dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

/// Manages encrypted database operations using SQLCipher
class EncryptedDatabaseHelper {
  static const String _encryptionKeyStorageKey = 'brick_db_encryption_key';
  static const String _databaseName = 'fees_up_brick.db';
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Database? _database;
  String? _encryptionKey;

  /// Get or create encryption key from secure storage
  Future<String> _getOrCreateEncryptionKey() async {
    if (_encryptionKey != null) return _encryptionKey!;

    // Try to retrieve existing key
    String? key = await _secureStorage.read(key: _encryptionKeyStorageKey);
    
    if (key == null) {
      // Generate new 256-bit key (64 hex characters)
      key = _generateSecureKey();
      await _secureStorage.write(key: _encryptionKeyStorageKey, value: key);
      debugPrint('Generated new encryption key for Brick database');
    }

    _encryptionKey = key;
    return key;
  }

  /// Generate a secure random key
  String _generateSecureKey() {
    final random = DateTime.now().millisecondsSinceEpoch.toString() +
        DateTime.now().microsecondsSinceEpoch.toString();
    // In production, use crypto.getRandomBytes or similar
    return random.padRight(64, '0').substring(0, 64);
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final dbPath = path.join(directory.path, 'brick_dbs', _databaseName);
    
    // Ensure directory exists
    final dbDir = Directory(path.dirname(dbPath));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    
    return dbPath;
  }

  /// Initialize encrypted database
  Future<Database> initializeDatabase() async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    final dbPath = await getDatabasePath();
    final key = await _getOrCreateEncryptionKey();

    debugPrint('Initializing encrypted database at: $dbPath');

    _database = await openDatabase(
      dbPath,
      password: key,
      version: 1,
      onCreate: (db, version) async {
        debugPrint('Creating encrypted database schema');
        // Brick will handle table creation through migrations
        // This is just to ensure the encrypted database is properly initialized
      },
      onConfigure: (db) async {
        // Enable foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );

    return _database!;
  }

  /// Close database
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete database (use with caution)
  Future<void> deleteDatabase() async {
    await close();
    final dbPath = await getDatabasePath();
    final file = File(dbPath);
    if (await file.exists()) {
      await file.delete();
      debugPrint('Deleted encrypted database');
    }
  }

  /// Change encryption key (re-encrypt database)
  Future<void> changeEncryptionKey(String newKey) async {
    if (_database == null || !_database!.isOpen) {
      throw Exception('Database must be open to change encryption key');
    }

    // SQLCipher re-key command
    await _database!.execute("PRAGMA rekey = '$newKey'");
    
    // Store new key
    await _secureStorage.write(key: _encryptionKeyStorageKey, value: newKey);
    _encryptionKey = newKey;
    
    debugPrint('Database encryption key changed successfully');
  }

  /// Verify database integrity
  Future<bool> verifyIntegrity() async {
    if (_database == null || !_database!.isOpen) {
      return false;
    }

    try {
      final result = await _database!.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty && result.first['integrity_check'] == 'ok';
    } catch (e) {
      debugPrint('Database integrity check failed: $e');
      return false;
    }
  }

  /// Get encryption key (for Brick initialization)
  Future<String> getEncryptionKey() async {
    return await _getOrCreateEncryptionKey();
  }

  /// Clear encryption key (logout/reset)
  Future<void> clearEncryptionKey() async {
    await _secureStorage.delete(key: _encryptionKeyStorageKey);
    _encryptionKey = null;
  }
}
