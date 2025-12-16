// lib/brick/repository/brick_repository.dart
import 'package:brick_offline_first_with_supabase/brick_offline_first_with_supabase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../db/encrypted_database_helper.dart';
import '../brick.g.dart';

/// Singleton repository manager for offline-first Brick operations
class BrickRepository {
  static BrickRepository? _instance;
  static OfflineFirstWithSupabaseRepository? _repository;
  static final EncryptedDatabaseHelper _dbHelper = EncryptedDatabaseHelper();

  BrickRepository._();

  /// Get singleton instance
  static BrickRepository get instance {
    _instance ??= BrickRepository._();
    return _instance!;
  }

  /// Initialize Brick repository with encryption
  Future<OfflineFirstWithSupabaseRepository> initialize() async {
    if (_repository != null) {
      return _repository!;
    }

    try {
      // Get encrypted database path
      final dbPath = await _dbHelper.getDatabasePath();
      
      // Get or create encryption key
      final encryptionKey = await _dbHelper.getEncryptionKey();
      
      // Get Supabase credentials from environment
      final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception('Supabase credentials not found in environment');
      }

      debugPrint('Initializing Brick repository with encrypted database');
      
      // Initialize Brick repository
      _repository = await initializeBrickRepository(
        databasePath: dbPath,
        encryptionKey: encryptionKey,
        supabaseUrl: supabaseUrl,
        supabaseAnonKey: supabaseAnonKey,
      );

      debugPrint('Brick repository initialized successfully');
      return _repository!;
    } catch (e) {
      debugPrint('Failed to initialize Brick repository: $e');
      rethrow;
    }
  }

  /// Get repository instance (must be initialized first)
  OfflineFirstWithSupabaseRepository get repository {
    if (_repository == null) {
      throw Exception('Brick repository not initialized. Call initialize() first.');
    }
    return _repository!;
  }

  /// Check if repository is initialized
  bool get isInitialized => _repository != null;

  /// Get a model by ID with offline-first approach
  Future<T?> get<T extends OfflineFirstWithSupabaseModel>(
    String id, {
    bool requireRemote = false,
  }) async {
    try {
      final result = await repository.get<T>(
        query: Query.where('id', id),
        requireRemote: requireRemote,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error getting model: $e');
      return null;
    }
  }

  /// Get all models with optional query
  Future<List<T>> getAll<T extends OfflineFirstWithSupabaseModel>({
    Query? query,
    bool requireRemote = false,
  }) async {
    try {
      return await repository.get<T>(
        query: query,
        requireRemote: requireRemote,
      );
    } catch (e) {
      debugPrint('Error getting all models: $e');
      return [];
    }
  }

  /// Upsert (insert or update) a model
  Future<T?> upsert<T extends OfflineFirstWithSupabaseModel>(T model) async {
    try {
      return await repository.upsert<T>(model);
    } catch (e) {
      debugPrint('Error upserting model: $e');
      return null;
    }
  }

  /// Delete a model
  Future<bool> delete<T extends OfflineFirstWithSupabaseModel>(T model) async {
    try {
      await repository.delete<T>(model);
      return true;
    } catch (e) {
      debugPrint('Error deleting model: $e');
      return false;
    }
  }

  /// Subscribe to model changes (real-time updates)
  Future<void> subscribe<T extends OfflineFirstWithSupabaseModel>({
    Query? query,
    required Function(List<T>) onData,
    Function(Object error)? onError,
  }) async {
    try {
      repository.subscribe<T>(
        query: query,
      ).listen(
        onData,
        onError: onError,
      );
    } catch (e) {
      debugPrint('Error subscribing to model changes: $e');
      if (onError != null) onError(e);
    }
  }

  /// Sync data with Supabase (pull latest changes)
  Future<bool> sync<T extends OfflineFirstWithSupabaseModel>() async {
    try {
      await repository.migrate();
      debugPrint('Sync completed for ${T.toString()}');
      return true;
    } catch (e) {
      debugPrint('Error syncing: $e');
      return false;
    }
  }

  /// Clear all local data for a model type
  Future<void> clearLocal<T extends OfflineFirstWithSupabaseModel>() async {
    try {
      final models = await repository.get<T>(
        requireRemote: false,
      );
      for (final model in models) {
        await repository.delete<T>(model);
      }
      debugPrint('Cleared local data for ${T.toString()}');
    } catch (e) {
      debugPrint('Error clearing local data: $e');
    }
  }

  /// Reset repository and clear encryption key
  Future<void> reset() async {
    try {
      await _dbHelper.close();
      await _dbHelper.deleteDatabase();
      await _dbHelper.clearEncryptionKey();
      _repository = null;
      debugPrint('Brick repository reset completed');
    } catch (e) {
      debugPrint('Error resetting repository: $e');
    }
  }

  /// Verify database integrity
  Future<bool> verifyIntegrity() async {
    return await _dbHelper.verifyIntegrity();
  }

  /// Get offline queue status
  int get offlineQueueLength {
    // This would need to be implemented based on your queue manager
    return 0;
  }
}
