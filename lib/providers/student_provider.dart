// lib/providers/student_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/student_full.dart';

// This provider streams the real list of students from your local database
final studentListStreamProvider = StreamProvider.autoDispose<List<StudentFull>>((ref) {
  final db = DatabaseService.instance;
  
  // 1. Force a refresh so the stream emits the latest data immediately
  db.refreshStudentFullCache(includeInactive: true);
  
  // 2. Return the stream of hydrated student data
  return db.studentFullStream;
});