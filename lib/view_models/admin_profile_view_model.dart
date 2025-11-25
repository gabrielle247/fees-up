import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/admin_profile.dart';
import '../services/local_storage_service.dart';

class AdminProfileViewModel extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  // --- STATE ---
  AdminProfile? _profile;
  int _totalStudentsEver = 0;
  double _lifetimeRevenue = 0.0;
  bool _isLoading = false;

  // --- GETTERS ---
  bool get isLoading => _isLoading;

  String get adminName => _profile?.fullName ?? "Administrator";
  String get schoolName => _profile?.schoolName ?? "Loading School...";

  // Exposes the avatar URL directly
  String? get avatarUrl => _profile?.avatarUrl;

  // 🛑 FIX: Add the getter the UI is expecting to resolve the error.
  String? get currentAvatarUrl => avatarUrl;

  String get totalStudentsStr => "$_totalStudentsEver";

  String get lifetimeRevenueStr {
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    ).format(_lifetimeRevenue);
  }

  // --- ACTIONS: loadProfileData ---
  Future<void> loadProfileData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Fetch Admin Profile (from local SQLite DB which caches Supabase data)
      final profile = await _storage.getAdminProfile();

      // 2. Fetch Lifetime Stats from local SQLite DB
      final students = await _storage.getAllStudents();
      final payments = await _storage.getAllPayments();

      // 3. Update State variables
      _profile = profile;
      _totalStudentsEver = students.length;
      // Calculates the sum of ALL payments ever made
      _lifetimeRevenue = payments.fold(0.0, (sum, item) => sum + item.amount);
    } catch (e) {
      debugPrint("Error loading admin profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- ACTIONS: wipeSystemData ---
  Future<void> wipeSystemData() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Wipes all data (students, bills, payments, notifications, and JSON files)
      await _storage.wipeAllData();

      // Reload the data to show zeros/defaults on the screen immediately
      await loadProfileData();
    } catch (e) {
      debugPrint("Error wiping data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
