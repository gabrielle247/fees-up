import 'dart:io'; // Needed for Platform check
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/app_singleton.dart';

class LocalAuthService {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> authenticate() async {
    // 1. Singleton Check (Don't ask if already logged in)
    if (AppSingleton.instance.isAuthenticated) {
      return true;
    }

    // 🛑 LINUX BYPASS: Auto-approve on dev machine
    if (Platform.isLinux) {
      // print("🐧 Linux Detected: Security Bypassed for Development");
      AppSingleton.instance.isAuthenticated = true;
      return true;
    }

    // 2. Mobile/Production Logic
    try {
      final bool canCheck = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canCheck) {
        // No hardware on phone -> Allow or fallback to PIN
        AppSingleton.instance.isAuthenticated = true;
        return true;
      }

      final bool success = await _auth.authenticate(
        localizedReason: 'Verify identity to access Greyway',
        biometricOnly: false, // Allows PIN/Pattern on Android/iOS
      );

      if (success) {
        AppSingleton.instance.isAuthenticated = true;
      }

      return success;

    } on PlatformException catch (_) {
      return false;
    }
  }

  static void lockApp() {
    AppSingleton.instance.isAuthenticated = false;
  }
}