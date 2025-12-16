import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/database_service.dart';

/// User profile data model for offline storage
class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? schoolName;
  final String? schoolId;
  final String? avatarUrl;
  final String role;
  final DateTime? lastSyncedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.schoolName,
    this.schoolId,
    this.avatarUrl,
    this.role = 'school_admin',
    this.lastSyncedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String? ?? '',
      fullName: map['full_name'] as String? ?? 'User',
      schoolName: map['school_name'] as String?,
      schoolId: map['school_id'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'school_admin',
      lastSyncedAt: map['last_synced_at'] != null 
          ? DateTime.tryParse(map['last_synced_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'school_name': schoolName,
      'school_id': schoolId,
      'avatar_url': avatarUrl,
      'role': role,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }
}

/// School data model (remote-first; optionally cached later)
class School {
  final String id;
  final String name;
  final String? subscriptionTier;
  final int? maxStudents;
  final bool isSuspended;

  School({
    required this.id,
    required this.name,
    this.subscriptionTier,
    this.maxStudents,
    this.isSuspended = false,
  });

  factory School.fromMap(Map<String, dynamic> m) => School(
        id: m['id'] as String,
        name: m['name'] as String? ?? 'School',
        subscriptionTier: m['subscription_tier'] as String?,
        maxStudents: m['max_students'] as int?,
        isSuspended: (m['is_suspended'] is bool)
            ? (m['is_suspended'] as bool)
            : ((m['is_suspended'] as int?) ?? 0) == 1,
      );
}

/// Provider for the current user's profile (offline-first with sync)
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  try {
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    
    if (currentUser == null) {
      debugPrint('DEBUG: No current user, returning null');
      return null;
    }

    debugPrint('DEBUG: Fetching profile for user ${currentUser.id}');
    final db = DatabaseService.instance;
    final database = await db.database;

    // 1. Check local database first (offline-first)
    try {
      final localProfile = await database.query(
        'user_profiles',
        where: 'id = ?',
        whereArgs: [currentUser.id],
        limit: 1,
      );

      if (localProfile.isNotEmpty) {
        debugPrint('DEBUG: Found local profile');
        final profile = UserProfile.fromMap(localProfile.first);
        
        // Check if we need to sync (if last sync was more than 1 hour ago or never)
        final shouldSync = profile.lastSyncedAt == null ||
            DateTime.now().difference(profile.lastSyncedAt!).inHours > 1;

        if (shouldSync) {
          debugPrint('DEBUG: Triggering background sync');
          // Trigger background sync but don't wait for it
          Future.microtask(() => ref.read(syncUserProfileProvider(currentUser.id)));
        }

        return profile;
      }
    } catch (e) {
      debugPrint('DEBUG: Error querying local profile: $e');
    }

    // 2. No local profile - try to sync from Supabase
    debugPrint('DEBUG: No local profile, attempting sync');
    try {
      return await ref.read(syncUserProfileProvider(currentUser.id).future);
    } catch (e) {
      debugPrint('DEBUG: Sync failed: $e');
      // Return a minimal profile from auth metadata as last resort
      return UserProfile(
        id: currentUser.id,
        email: currentUser.email ?? '',
        fullName: currentUser.userMetadata?['full_name'] as String? ?? 'User',
        schoolName: currentUser.userMetadata?['school_name'] as String?,
        avatarUrl: currentUser.userMetadata?['avatar_url'] as String?,
      );
    }
  } catch (e, st) {
    debugPrint('DEBUG: userProfileProvider error: $e\n$st');
    rethrow;
  }
});

/// Returns true if the current user profile does not exist locally or is missing
/// critical fields (full name or school association). Use this to prompt the
/// user to complete their profile details.
final needsProfileSetupProvider = FutureProvider<bool>((ref) async {
  final client = Supabase.instance.client;
  final user = client.auth.currentUser;
  if (user == null) return false; // no auth → no setup prompt here

  final db = DatabaseService.instance;
  final database = await db.database;
  final rows = await database.query('user_profiles', where: 'id = ?', whereArgs: [user.id], limit: 1);
  if (rows.isEmpty) return true; // no local profile
  final row = rows.first;
  final fullName = (row['full_name'] as String?)?.trim();
  final schoolId = row['school_id'] as String?;
  if (fullName == null || fullName.isEmpty) return true;
  if (schoolId == null || schoolId.isEmpty) return true;
  return false;
});

/// Saves or updates the local profile with provided details, creating a school
/// if necessary via DatabaseService.ensureAdminExists(). This is an offline-first
/// operation; syncing to server should be handled separately.
final profileSetupControllerProvider = StateNotifierProvider<ProfileSetupController, AsyncValue<void>>((ref) {
  return ProfileSetupController(ref);
});

class ProfileSetupController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ProfileSetupController(this.ref) : super(const AsyncValue.data(null));

  Future<void> save({required String fullName, required String schoolName}) async {
    state = const AsyncValue.loading();
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) throw Exception('Not authenticated');

      // Ensure admin and school exist locally with provided defaults
      await DatabaseService.instance.ensureAdminExists(
        user.id,
        defaults: {
          'email': user.email ?? '${user.id}@local',
          'full_name': fullName,
          'school_name': schoolName,
        },
      );

      // Refresh cached providers
      ref.invalidate(userProfileProvider);
      ref.invalidate(needsProfileSetupProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Provider to sync user profile from Supabase
final syncUserProfileProvider = FutureProvider.family<UserProfile, String>((ref, userId) async {
  final supabase = Supabase.instance.client;
  final db = DatabaseService.instance;
  final database = await db.database;

  try {
    debugPrint('DEBUG: Syncing profile from Supabase for user $userId');
    // Fetch from Supabase user_profiles table with timeout
    final response = await supabase
        .from('user_profiles')
        // Use LEFT JOIN to avoid filtering out users without school yet
        .select('id,email,full_name,role,avatar_url,school_id,is_banned,created_at, schools(name)')
        .eq('id', userId)
        .maybeSingle()
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('DEBUG: Supabase query timed out');
            throw TimeoutException('Profile fetch timed out');
          },
        );

    if (response != null) {
      debugPrint('DEBUG: Supabase profile found for $userId');
      // Extract school name from joined data
      final schoolName = response['schools'] is Map
          ? (response['schools'] as Map)['name'] as String?
          : null;

      final profileData = {
        'id': response['id'],
        'email': response['email'] ?? supabase.auth.currentUser?.email ?? '',
        'full_name': response['full_name'] ?? 'User',
        'school_name': schoolName,
        'avatar_url': response['avatar_url'],
        'role': response['role'] ?? 'school_admin',
        'school_id': response['school_id'],
        'is_banned': (response['is_banned'] is bool 
            ? (response['is_banned'] as bool ? 1 : 0)
            : (response['is_banned'] as int? ?? 0)),
        'last_synced_at': DateTime.now().toIso8601String(),
        'created_at': response['created_at'] is int
            ? response['created_at']
            : DateTime.now().millisecondsSinceEpoch,
      };

      // Ensure local schools table has this school to satisfy FK constraints
      final schoolId = profileData['school_id'] as String?;
      if (schoolId != null && schoolId.isNotEmpty) {
        final existingSchool = await database.query(
          'schools',
          where: 'id = ?',
          whereArgs: [schoolId],
          limit: 1,
        );
        if (existingSchool.isEmpty) {
          debugPrint('DEBUG: Fetching full school record for $schoolId from Supabase');
          try {
            final schoolResp = await supabase
                .from('schools')
                .select('id,name,subscription_tier,max_students,is_suspended,created_at')
                .eq('id', schoolId)
                .maybeSingle()
                .timeout(const Duration(seconds: 5));
            
            if (schoolResp != null) {
              debugPrint('DEBUG: Synced school $schoolId from Supabase');
              await database.insert(
                'schools',
                {
                  'id': schoolResp['id'],
                  'name': schoolResp['name'] ?? 'School',
                  'subscription_tier': schoolResp['subscription_tier'] ?? 'free',
                  'max_students': schoolResp['max_students'] ?? 50,
                  'is_suspended': (schoolResp['is_suspended'] is bool)
                      ? (schoolResp['is_suspended'] as bool ? 1 : 0)
                      : (schoolResp['is_suspended'] as int? ?? 0),
                  'created_at': schoolResp['created_at'] is int
                      ? schoolResp['created_at']
                      : DateTime.now().millisecondsSinceEpoch,
                },
                conflictAlgorithm: ConflictAlgorithm.replace,
              );
            }
          } catch (e) {
            debugPrint('DEBUG: Could not fetch school $schoolId: $e, using fallback');
            await database.insert(
              'schools',
              {
                'id': schoolId,
                'name': schoolName ?? 'School',
                'subscription_tier': 'free',
                'max_students': 50,
                'is_suspended': 0,
                'created_at': DateTime.now().millisecondsSinceEpoch,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      }

      // Store/update in local database
      await database.insert(
        'user_profiles',
        profileData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final profile = UserProfile.fromMap(profileData);
      debugPrint('DEBUG: Stored profile locally with schoolId=${profile.schoolId}');
      return profile;
    }
    debugPrint('DEBUG: Supabase returned null (no profile row) for $userId');
  } catch (e) {
    debugPrint('DEBUG: Error during Supabase profile sync: $e');
    // If sync fails, try to get from local cache
    final localProfile = await database.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    if (localProfile.isNotEmpty) {
      debugPrint('DEBUG: Using cached local profile for $userId');
      return UserProfile.fromMap(localProfile.first);
    }
  }

  // Fallback: create minimal profile from Supabase auth metadata
  final currentUser = supabase.auth.currentUser;
  if (currentUser != null) {
    debugPrint('DEBUG: Creating fallback profile from auth metadata for ${currentUser.id}');
    final fallbackData = {
      'id': currentUser.id,
      'email': currentUser.email ?? '',
      'full_name': currentUser.userMetadata?['full_name'] as String? ?? 'User',
      'school_name': currentUser.userMetadata?['school_name'] as String?,
      'avatar_url': currentUser.userMetadata?['avatar_url'] as String?,
      'role': 'school_admin',
      'school_id': null,
      'is_banned': 0,
      'last_synced_at': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };

    // Store fallback data
    await database.insert(
      'user_profiles',
      fallbackData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    debugPrint('DEBUG: Fallback profile stored locally (no remote profile)');
    return UserProfile.fromMap(fallbackData);
  }

  throw Exception('Unable to load or sync user profile');
});

/// Fetch current school details for the logged-in user (via profile.schoolId)
final currentSchoolProvider = FutureProvider<School?>((ref) async {
  final profile = await ref.watch(userProfileProvider.future);
  
  // 1. Guard Clauses
  if (profile == null || profile.schoolId == null) return null;

  final db = DatabaseService.instance;
  final database = await db.database;

  // 2. Try Local SQLite First (Fast & Offline Friendly)
  final localSchool = await database.query(
    'schools',
    where: 'id = ?',
    whereArgs: [profile.schoolId],
    limit: 1,
  );

  if (localSchool.isNotEmpty) {
    debugPrint('DEBUG: Found local school');
    return School.fromMap(localSchool.first);
  }

  // 3. Fallback: Fetch from Supabase (Only if not in SQLite)
  try {
    debugPrint('DEBUG: Fetching school from Supabase');
    final supabase = Supabase.instance.client;
    final resp = await supabase
        .from('schools')
        .select('id,name,subscription_tier,max_students,is_suspended')
        .eq('id', profile.schoolId!) // <--- Fixed interpolation
        .maybeSingle();

    if (resp != null) {
      // OPTIONAL: Save to SQLite here so next time it's cached
      return School.fromMap(resp);
    }
  } catch (e) {
    debugPrint('DEBUG: currentSchoolProvider error: $e');
  }
  
  return null;
});

/// Notifier for manual profile refresh
final profileRefreshProvider = StateNotifierProvider<ProfileRefreshNotifier, AsyncValue<void>>((ref) {
  return ProfileRefreshNotifier(ref);
});

class ProfileRefreshNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ProfileRefreshNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final supabase = Supabase.instance.client;
      final currentUser = supabase.auth.currentUser;
      
      if (currentUser != null) {
        // ignore: unused_result
        await ref.refresh(syncUserProfileProvider(currentUser.id).future);
        ref.invalidate(userProfileProvider);
      }
      
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
