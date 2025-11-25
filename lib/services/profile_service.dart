// lib/services/profile_service.dart

import 'dart:io';
import 'package:fees_up/utils/convert_to_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const String _profileTable = 'admin_profile';
  static const String _profileBucket = 'avatars';

  /// -------------------------------------------------------
  /// UPDATE PROFILE (NO MORE receiveNotifications)
  /// -------------------------------------------------------
  Future<void> updateProfile({
    required String fullName,
    required String schoolName,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    await _supabase
        .from(_profileTable)
        .update({
          'full_name': fullName,
          'school_name': schoolName,
          'avatar_url': avatarUrl, // always store real Supabase URL
        })
        .eq('id', userId);
  }

  /// -------------------------------------------------------
  /// UPLOAD AVATAR (SAFE + ALWAYS JPG + ALWAYS EXISTS)
  /// -------------------------------------------------------
  Future<String?> uploadAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 300,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedFile == null) return null;

    final userId = _supabase.auth.currentUser!.id;
    final fileName = '$userId.png';

    // Convert everything to PNG
    final original = File(pickedFile.path);
    final pngBytes = await convertToPng(original); // <— ALWAYS PNG

    // Upload
    await _supabase.storage
        .from(_profileBucket)
        .uploadBinary(
          fileName,
          pngBytes,
          fileOptions: const FileOptions(upsert: true, cacheControl: '3600'),
        );

    // Get actual URL (always PNG now)
    final url = _supabase.storage.from(_profileBucket).getPublicUrl(fileName);

    return url;
  }
}
