import 'package:flutter/foundation.dart';
import '../models/notification_item.dart';
import '../services/local_storage_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;

  // --- GETTERS ---
  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasNotifications => _notifications.isNotEmpty;

  // --- ACTIONS ---

  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Run the Analysis Engine first (Generate new insights based on latest data)
      await _storage.generateSmartInsights();
      
      // 2. Fetch results
      _notifications = await _storage.getNotifications();
    } catch (e) {
      debugPrint("Error loading notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Quick refresh without re-running the heavy analysis engine
  Future<void> refresh() async {
    _notifications = await _storage.getNotifications();
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    // Optimistic update for UI speed
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final item = _notifications[index];
      // Assuming copyWith exists on your model
      _notifications[index] = item.copyWith(isRead: true); 
      notifyListeners();
    }
    
    // Persist to DB + Queue for Sync
    await _storage.markNotificationAsRead(id);
  }

  // 🛑 RENAMED to match LocalStorageService and UI calls
  Future<void> markAllAsRead() async {
    // Optimistic update
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    // Persist
    await _storage.markAllAsRead();
  }

  Future<void> delete(String id) async {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
    await _storage.deleteNotification(id);
  }
}