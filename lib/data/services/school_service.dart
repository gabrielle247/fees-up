import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolService {
  final DatabaseService _db;
  final _supabase = Supabase.instance.client;

  SchoolService(this._db);

  /// -----------------------------------------------------------------------
  /// REFRESH HELPER (Required by school_provider.dart)
  /// -----------------------------------------------------------------------
  Future<Map<String, dynamic>?> getSchoolForUser(String userId, {bool waitForSync = true}) async {
    Future<Map<String, dynamic>?> fetch() async {
      final profile = await _db.tryGet('SELECT school_id FROM user_profiles WHERE id = ?', [userId]);
      if (profile == null || profile['school_id'] == null) return null;
      
      return await _db.tryGet('SELECT * FROM schools WHERE id = ?', [profile['school_id']]);
    }

    final result = await fetch();
    if (result != null) return result;
    if (!waitForSync) return null;

    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(seconds: 1));
      final retryResult = await fetch();
      if (retryResult != null) return retryResult;
    }
    return null;
  }

  /// -----------------------------------------------------------------------
  /// CREATION HELPER
  /// -----------------------------------------------------------------------
  Future<String?> createSchool({
    required String adminId,
    required String schoolName,
    String tier = 'free',
  }) async {
    final schoolId = const Uuid().v4();
    final now = DateTime.now().toIso8601String();

    try {
      await _db.db.writeTransaction((tx) async {
        await tx.execute('''
          INSERT INTO schools (id, name, subscription_tier, max_students, is_suspended, created_at)
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [schoolId, schoolName, tier, 100, 0, now]);

        await tx.execute('''
          UPDATE user_profiles SET school_id = ?, role = 'admin' WHERE id = ?
        ''', [schoolId, adminId]);

        await tx.execute('''
          INSERT INTO billing_configs (id, school_id, currency_code, late_fee_percentage, updated_at)
          VALUES (?, ?, ?, ?, ?)
        ''', [const Uuid().v4(), schoolId, 'USD', 0.0, now]);
      });

      return schoolId;
    } catch (e) {
      rethrow; 
    }
  }

  Future<void> createSchoolWithDiagnostics(
    BuildContext context, {
    required String adminId,
    required String schoolName,
  }) async {
    try {
      await createSchool(adminId: adminId, schoolName: schoolName);
    } catch (e) {
      try {
        final response = await _supabase.rpc('debug_user_access', params: {
          'target_user_id': adminId,
        });

        final recommendation = response['recommendation'] ?? 'UNKNOWN_ERROR';
        
        if (context.mounted) {
          showProperChannelDialog(context, recommendation);
        }
      } catch (rpcError) {
        throw Exception("System is currently unreachable.");
      }
    }
  }

  /// -----------------------------------------------------------------------
  /// FORCE LOGOUT AND RE-AUTHENTICATE
  /// -----------------------------------------------------------------------
  Future<void> _forceLogoutAndReauth() async {
    await _db.factoryReset(); // Uses the new internal factoryReset
    await _supabase.auth.signOut();
  }

  void showProperChannelDialog(BuildContext context, String recommendation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF121212),
        title: const Text("System Alignment Required", style: TextStyle(color: Colors.blue)),
        content: Text(
          "Diagnostic Result: $recommendation\n\nTo resolve this, the app must restart your session.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _forceLogoutAndReauth();
            },
            child: const Text("RESET & RE-AUTHENTICATE", style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}