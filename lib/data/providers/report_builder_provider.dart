import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// --- STATE MODEL ---
class ReportBuilderState {
  final String category;
  final DateTimeRange dateRange;
  final String gradeFilter;
  final String exportFormat; // 'PDF' or 'Excel/CSV'

  ReportBuilderState({
    required this.category,
    required this.dateRange,
    required this.gradeFilter,
    required this.exportFormat,
  });

  ReportBuilderState copyWith({
    String? category,
    DateTimeRange? dateRange,
    String? gradeFilter,
    String? exportFormat,
  }) {
    return ReportBuilderState(
      category: category ?? this.category,
      dateRange: dateRange ?? this.dateRange,
      gradeFilter: gradeFilter ?? this.gradeFilter,
      exportFormat: exportFormat ?? this.exportFormat,
    );
  }
}

// --- NOTIFIER ---
class ReportBuilderNotifier extends StateNotifier<ReportBuilderState> {
  ReportBuilderNotifier() : super(ReportBuilderState(
    category: 'Tuition & Fee Collection',
    dateRange: DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)), 
      end: DateTime.now()
    ),
    gradeFilter: 'All Grades',
    exportFormat: 'PDF',
  ));

  void setCategory(String value) => state = state.copyWith(category: value);
  void setDateRange(DateTimeRange value) => state = state.copyWith(dateRange: value);
  void setGradeFilter(String value) => state = state.copyWith(gradeFilter: value);
  void setExportFormat(String value) => state = state.copyWith(exportFormat: value);
}

// --- PROVIDER ---
final reportBuilderProvider = StateNotifierProvider<ReportBuilderNotifier, ReportBuilderState>((ref) {
  return ReportBuilderNotifier();
});

// --- HELPER TO GET SUMMARY TEXT ---
// Used in the right-side summary panel of your UI
final reportSummaryProvider = Provider.autoDispose<Map<String, String>>((ref) {
  final state = ref.watch(reportBuilderProvider);
  final dateFormat = DateFormat('MMM d, yyyy');

  return {
    'Type': state.category,
    'Period': "${dateFormat.format(state.dateRange.start)} - ${dateFormat.format(state.dateRange.end)}",
    'Scope': state.gradeFilter,
    'Format': state.exportFormat == 'PDF' ? 'PDF Document' : 'Excel / CSV',
  };
});