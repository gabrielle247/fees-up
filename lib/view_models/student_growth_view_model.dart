import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import '../services/local_storage_service.dart';

class StudentGrowthViewModel extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  bool _isLoading = true;
  
  // KPI Stats
  int _totalStudents = 0;
  int _activeStudents = 0;
  int _inactiveStudents = 0;
  int _newThisMonth = 0;

  // Chart Data
  List<FlSpot> _growthSpots = [];
  List<String> _monthLabels = [];
  double _maxY = 10; // For chart scaling

  // Getters
  bool get isLoading => _isLoading;
  int get totalStudents => _totalStudents;
  int get activeStudents => _activeStudents;
  int get inactiveStudents => _inactiveStudents;
  int get newThisMonth => _newThisMonth;
  List<FlSpot> get growthSpots => _growthSpots;
  List<String> get monthLabels => _monthLabels;
  double get maxY => _maxY;

  Future<void> loadGrowthData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final students = await _storage.getAllStudents();
      _processData(students);
    } catch (e) {
      debugPrint("Error loading growth data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _processData(List<Student> students) {
    final now = DateTime.now();
    
    // 1. Basic Counts
    _totalStudents = students.length;
    _activeStudents = students.where((s) => s.isActive).length;
    _inactiveStudents = students.where((s) => !s.isActive).length;
    _newThisMonth = students.where((s) => 
      s.registrationDate.year == now.year && 
      s.registrationDate.month == now.month
    ).length;

    // 2. Chart Logic (Last 6 Months Cumulative)
    _growthSpots = [];
    _monthLabels = [];
    double maxCount = 0;

    for (int i = 5; i >= 0; i--) {
      // Calculate the "End Date" for this bucket
      // e.g., If now is Nov, bucket 0 is June. We want count of students registered BEFORE July 1st.
      final targetMonth = DateTime(now.year, now.month - i, 1);
      final endOfTargetMonth = DateTime(targetMonth.year, targetMonth.month + 1, 1); // First day of next month

      // Count students registered before this cutoff
      final count = students.where((s) => 
        s.registrationDate.isBefore(endOfTargetMonth)
      ).length.toDouble();

      if (count > maxCount) maxCount = count;

      // Add Spot (X = index 0-5, Y = count)
      _growthSpots.add(FlSpot((5 - i).toDouble(), count));
      
      // Add Label
      _monthLabels.add(DateFormat('MMM').format(targetMonth));
    }

    // Add nice headroom for the chart
    _maxY = maxCount == 0 ? 10 : maxCount * 1.2;
  }
}