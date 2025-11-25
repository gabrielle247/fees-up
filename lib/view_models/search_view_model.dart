import 'package:flutter/foundation.dart';
import '../services/local_storage_service.dart';
import '../models/student.dart';

class SearchViewModel extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();

  // State
  List<Student> _allStudents = []; // The Master List
  List<Student> _filteredStudents = []; // The Display List
  bool _isLoading = false;
  String _query = "";

  // Getters
  List<Student> get results => _filteredStudents;
  bool get isLoading => _isLoading;
  bool get isQueryEmpty => _query.isEmpty;

  // 1. Load Data (Called when page opens)
  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allStudents = await _storage.getAllStudents();
      // Sort alphabetically by default
      _allStudents.sort((a, b) => a.studentName.compareTo(b.studentName));
      
      // ✅ FIX: Show ALL students by default
      _filteredStudents = List.from(_allStudents); 
      
    } catch (e) {
      debugPrint("Error loading search data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Search Logic (Called on keystroke)
  void onSearchChanged(String query) {
    _query = query;

    if (query.isEmpty) {
      // ✅ FIX: Revert to FULL list when search is cleared
      _filteredStudents = List.from(_allStudents);
      notifyListeners();
      return;
    }

    final lowerQuery = query.toLowerCase();

    _filteredStudents = _allStudents.where((student) {
      final nameMatch = student.studentName.toLowerCase().contains(lowerQuery);
      final idMatch = student.studentId.toLowerCase().contains(lowerQuery);
      return nameMatch || idMatch;
    }).toList();

    notifyListeners();
  }
}