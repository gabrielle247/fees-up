// lib/view_models/edit_admin_profile_view_model.dart (FINAL V1.0.0)

import 'package:flutter/material.dart';
import '../models/admin_profile.dart'; 
import '../services/profile_service.dart'; 
import '../services/local_storage_service.dart'; 
import '../services/smart_sync_manager.dart'; 

class EditAdminProfileViewModel extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  final LocalStorageService _localStorage = LocalStorageService();
  final SmartSyncManager _smartSync = SmartSyncManager();

  // --- STATE ---
  AdminProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;

  // --- GETTERS ---
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String get currentFullName => _profile?.fullName ?? '';
  String get currentSchoolName => _profile?.schoolName ?? '';
  String? get currentAvatarUrl => _profile?.avatarUrl;
  
  String get initials => 
      (_profile?.schoolName.isNotEmpty == true) 
      ? _profile!.schoolName.substring(0, 1).toUpperCase() 
      : '?';

  // --- PRIVATE MUTATORS ---
  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }
  
  // --- ACTIONS ---

  // Orchestrates initial data fetch
  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _profile = await _localStorage.getAdminProfile();
      
      // Initial Sync Check 
      if (_profile == null || _profile!.fullName.isEmpty) {
          await _smartSync.initialLoadSync(); 
          _profile = await _localStorage.getAdminProfile(); 
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Orchestrates text update -> server push -> local save
  Future<bool> saveTextChanges({
    required String newFullName,
    required String newSchoolName,
    required String? newAvatarUrl,
  }) async {
    if (_isSaving || _profile == null) return false;
    _setSaving(true);

    try {
      // 1. Update Supabase profile on the server 
      await _profileService.updateProfile(
        fullName: newFullName,
        schoolName: newSchoolName,
        avatarUrl: newAvatarUrl,
        // 🛑 REMOVED: No 'receiveNotifications' argument passed
      );

      // 2. Create updated local profile model (local cache)
      final updatedProfile = _profile!.copyWith(
        fullName: newFullName,
        schoolName: newSchoolName,
        avatarUrl: newAvatarUrl,
        // 🛑 REMOVED: No 'receiveNotifications' argument passed
      );

      // 3. Save to local SQLite cache
      await _localStorage.saveAdminProfile(updatedProfile);
      
      // 4. Update VM state
      _profile = updatedProfile;
      return true;
    } catch (e) {
      debugPrint("Failed to save changes: $e");
      return false;
    } finally {
      _setSaving(false);
    }
  }

  // Orchestrates image upload -> profile update (on server) -> local save
  Future<bool> uploadAndSaveAvatar() async {
    if (_isSaving || _profile == null) return false;
    _setSaving(true);
    
    try {
      // 1. Upload new image to Supabase Storage and get the new public URL
      final newUrl = await _profileService.uploadAvatar();

      if (newUrl == null) {
        return false;
      }

      // 2. Push profile update (includes existing name/school and the new URL) to server
      await _profileService.updateProfile(
        fullName: currentFullName,
        schoolName: currentSchoolName,
        avatarUrl: newUrl,
        // 🛑 REMOVED: No 'receiveNotifications' argument passed
      );

      // 3. Create and save updated local profile model
      final updatedProfile = _profile!.copyWith(
        avatarUrl: newUrl,
      );
      await _localStorage.saveAdminProfile(updatedProfile);

      // 4. Update VM state
      _profile = updatedProfile;
      return true;
    } catch (e) {
      debugPrint("Failed to upload image or update profile: $e");
      return false;
    } finally {
      _setSaving(false);
    }
  }
}