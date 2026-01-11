// lib/data/init_backend.dart
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:powersync/powersync.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/powersync_schema.dart';

/// Environment variables loaded at app startup
class AppEnvironment {
  static String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL');
  static String get supabaseAnonKey => const String.fromEnvironment('SUPABASE_ANON_KEY');
  static String get powerSyncUrl => const String.fromEnvironment('POWERSYNC_ENDPOINT_URL');
  static String get environment => const String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  /// Validate critical environment variables
  static void validate() {
    final missing = <String>[];
    if (supabaseUrl.isEmpty) missing.add('SUPABASE_URL');
    if (supabaseAnonKey.isEmpty) missing.add('SUPABASE_ANON_KEY');
    if (powerSyncUrl.isEmpty) missing.add('POWERSYNC_ENDPOINT_URL');

    if (missing.isNotEmpty) {
      final error = '''
      🚨 CRITICAL: Missing environment variables:
      ${missing.join(', ')}
      
      How to fix:
      1. Create assets/keys.env with your keys, OR
      2. Run with --dart-define flags:
         flutter run \\
           --dart-define=SUPABASE_URL=your_url \\
           --dart-define=SUPABASE_ANON_KEY=your_key \\
           --dart-define=POWERSYNC_ENDPOINT_URL=your_powersync_url
      ''';
      debugPrint(error);
      throw Exception('Missing environment variables: ${missing.join(', ')}');
    }
  }
}

/// Centralized backend initialization for Supabase + PowerSync
class BackendInitializer {
  static final BackendInitializer _instance = BackendInitializer._internal();
  factory BackendInitializer() => _instance;
  BackendInitializer._internal();

  final Logger _logger = Logger('BackendInit');
  late PowerSyncDatabase _db;
  bool _isInitialized = false;

  PowerSyncDatabase get database => _db;

  /// Initialize both Supabase and PowerSync
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _logger.info('🚀 Starting backend initialization...');
      
      // 1. Validate environment
      AppEnvironment.validate();
      
      // 2. Initialize Supabase
      await _initSupabase();
      
      // 3. Initialize PowerSync
      await _initPowerSync();
      
      _isInitialized = true;
      _logger.info('✅ Backend fully initialized');
    } catch (e) {
      _logger.severe('❌ Backend initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _initSupabase() async {
    _logger.info('🔌 Initializing Supabase...');
    await Supabase.initialize(
      url: AppEnvironment.supabaseUrl,
      anonKey: AppEnvironment.supabaseAnonKey,
    );
    _logger.info('✅ Supabase initialized');
  }

  Future<void> _initPowerSync() async {
    _logger.info('⚡ Initializing PowerSync...');
    
    // Get local DB path
    final dir = await getApplicationSupportDirectory();
    final dbPath = join(dir.path, 'fees_up.db');
    _logger.info('🗃️ Database path: $dbPath');
    
    // Create DB instance
    _db = PowerSyncDatabase(
      schema: powersyncSchema,
      path: dbPath,
    );
    
    await _db.initialize();
    
    // Run setup queries after initialization
    await _db.execute('PRAGMA journal_mode=WAL;');
    
    _logger.info('✅ PowerSync DB initialized');
    
    // Connect to backend
    await _db.connect(connector: _SupabaseConnector());
    _logger.info('✅ PowerSync connected to backend');
  }
}

/// Bridge between PowerSync and Supabase
class _SupabaseConnector extends PowerSyncBackendConnector {
  final Logger _logger = Logger('SyncConnector');
  
  @override
  Future<PowerSyncCredentials?> fetchCredentials() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      _logger.info('🔒 No active session - sync paused');
      return null;
    }
    
    // Check if user has a school assigned
    final supabase = Supabase.instance.client;
    final profile = await supabase
        .schema('access')
        .from('profiles')
        .select('school_id')
        .eq('id', session.user.id)
        .maybeSingle();
    
    final hasSchool = profile?['school_id'] != null;
    if (!hasSchool) {
      _logger.info('🏫 User has no school assigned - sync paused');
      return null;
    }
    
    _logger.info('✅ Credentials issued for user: ${session.user.id}');
    return PowerSyncCredentials(
      endpoint: AppEnvironment.powerSyncUrl,
      token: session.accessToken,
      userId: session.user.id,
    );
  }

  @override
  Future<void> uploadData(PowerSyncDatabase database) async {
    final batch = await database.getCrudBatch();
    if (batch == null) return;
    
    try {
      for (var op in batch.crud) {
        await _uploadOperation(op);
      }
      await batch.complete();
      _logger.fine('✅ Upload batch completed (${batch.crud.length} operations)');
    } catch (e) {
      _logger.severe('❌ Upload failed: $e');
      rethrow;
    }
  }

  Future<void> _uploadOperation(CrudEntry op) async {
    final supabase = Supabase.instance.client;
    final table = op.table;
    final id = op.id;
    
    switch (op.op) {
      case UpdateType.put:
        await supabase.from(table).upsert({...op.opData!, 'id': id});
        break;
      case UpdateType.patch:
        await supabase.from(table).update(op.opData!).eq('id', id);
        break;
      case UpdateType.delete:
        await supabase.from(table).delete().eq('id', id);
        break;
    }
  }
}