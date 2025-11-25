import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/finance.dart';
import '../services/local_storage_service.dart';

class RevenueViewModel extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  bool _isLoading = true;
  List<Payment> _allPayments = [];
  
  // Stats
  double _totalAllTime = 0.0;
  double _thisMonth = 0.0;
  double _lastMonth = 0.0;
  double _growthPercent = 0.0;

  // Chart Data: List of values for the last 6 months
  // Index 0 = Oldest month, Index 5 = Current Month
  List<double> _last6MonthsData = [0, 0, 0, 0, 0, 0];
  List<String> _last6MonthsLabels = [];

  // Getters
  bool get isLoading => _isLoading;
  double get totalAllTime => _totalAllTime;
  double get thisMonth => _thisMonth;
  double get growthPercent => _growthPercent;
  List<double> get chartData => _last6MonthsData;
  List<String> get chartLabels => _last6MonthsLabels;

  Future<void> loadRevenueData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPayments = await _storage.getAllPayments();
      _calculateMetrics();
    } catch (e) {
      debugPrint("Error loading revenue: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateMetrics() {
    final now = DateTime.now();
    _totalAllTime = 0.0;
    _thisMonth = 0.0;
    _lastMonth = 0.0;
    
    // Reset Chart Data
    _last6MonthsData = [0, 0, 0, 0, 0, 0];
    _last6MonthsLabels = [];

    // Generate Labels (e.g., "Jun", "Jul", "Aug"...)
    for (int i = 5; i >= 0; i--) {
      final d = DateTime(now.year, now.month - i, 1);
      _last6MonthsLabels.add(DateFormat('MMM').format(d));
    }

    for (var p in _allPayments) {
      _totalAllTime += p.amount;

      // Check This Month
      if (p.datePaid.year == now.year && p.datePaid.month == now.month) {
        _thisMonth += p.amount;
      }

      // Check Last Month
      final lastMonthDate = DateTime(now.year, now.month - 1, 1);
      if (p.datePaid.year == lastMonthDate.year && p.datePaid.month == lastMonthDate.month) {
        _lastMonth += p.amount;
      }

      // Populate Chart Buckets (Last 6 months)
      for (int i = 0; i < 6; i++) {
        // Index 5 is current month (offset 0), Index 0 is 5 months ago
        final offset = 5 - i; 
        final targetDate = DateTime(now.year, now.month - offset, 1);
        
        if (p.datePaid.year == targetDate.year && p.datePaid.month == targetDate.month) {
          _last6MonthsData[i] += p.amount;
        }
      }
    }

    // Calculate Growth %
    if (_lastMonth > 0) {
      _growthPercent = ((_thisMonth - _lastMonth) / _lastMonth) * 100;
    } else if (_thisMonth > 0) {
      _growthPercent = 100.0; // Infinite growth if previous was 0
    } else {
      _growthPercent = 0.0;
    }
  }
}