import 'dart:async';
import 'dart:convert';
import 'package:fees_up/data/services/encryption_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/broadcast_model.dart';

final broadcastServiceProvider = Provider((ref) => BroadcastService());

class BroadcastService {
  final _supabase = Supabase.instance.client;
  static const _storageKey = 'cached_broadcasts_encrypted';

  /// 1. ONLINE STREAM (Supabase Realtime)
  /// Listens to the live Websocket feed.
  Stream<List<Broadcast>> streamBroadcasts(String schoolId) {
    return _supabase
        .from('broadcasts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((maps) {
          final list = maps.map((e) => Broadcast.fromRow(e)).toList();
          
          // SIDE EFFECT: Encrypt & Cache immediately
          _cacheBroadcasts(list);
          
          return list;
        });
  }

  /// 2. OFFLINE LOAD (Encrypted Local Storage)
  Future<List<Broadcast>> loadCachedBroadcasts() async {
    final prefs = await SharedPreferences.getInstance();
    final encryptedData = prefs.getString(_storageKey);

    if (encryptedData == null) return [];

    try {
      // Decrypt
      final jsonStr = EncryptionService.decrypt(encryptedData);
      final List<dynamic> decoded = jsonDecode(jsonStr);
      
      final broadcasts = decoded.map((e) => Broadcast.fromRow(e)).toList();

      // Filter: Auto-expire messages older than 7 days
      return broadcasts.where((b) {
        return DateTime.now().difference(b.createdAt).inDays < 7;
      }).toList();

    } catch (e) {
      // If data is corrupt, clear it
      await prefs.remove(_storageKey);
      return [];
    }
  }

  /// Helper: Encrypt -> Save
  Future<void> _cacheBroadcasts(List<Broadcast> list) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Only cache the newest 50 to keep it fast
    final subset = list.take(50).toList();
    
    // Convert to JSON
    final jsonStr = jsonEncode(subset.map((b) => b.toMap()).toList());
    
    // Encrypt
    final encryptedStr = EncryptionService.encrypt(jsonStr);
    
    // Save
    await prefs.setString(_storageKey, encryptedStr);
  }

  /// 3. SENDING (Admin Only)
  /// Sends directly via REST API (bypassing PowerSync)
  Future<void> sendBroadcast({
    required String schoolId,
    required String authorId,
    required String title,
    required String body,
    String priority = 'normal',
    String targetRole = 'all',
  }) async {
    await _supabase.from('broadcasts').insert({
      'school_id': schoolId,
      'author_id': authorId,
      'title': title,
      'body': body,
      'priority': priority,
      'target_role': targetRole,
      'is_system_message': false,
    });
  }
}