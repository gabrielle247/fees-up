import 'package:isar/isar.dart';
import '../models/finance.dart';
import '../models/people.dart';
import 'isar_service.dart';

class BillingEngine {
  final _isarService = IsarService();

  /// Generates invoice periods for a given school based on FeeStructures
  /// and active AcademicYear. Supports recurrence: monthly, termly, yearly.
  /// Only bills students enrolled during each period (enrollment timeline aware).
  /// Idempotent: skips invoices that already exist.
  Future<void> generateInvoicesForSchool(String schoolId) async {
    final isar = await _isarService.db;

    final year = await isar.academicYears
        .filter()
        .schoolIdEqualTo(schoolId)
        .isActiveEqualTo(true)
        .findFirst();
    if (year == null) return;

    final feeStructures =
        await isar.feeStructures.filter().schoolIdEqualTo(schoolId).findAll();

    final enrollments = await isar.enrollments
        .filter()
        .schoolIdEqualTo(schoolId)
        .isActiveEqualTo(true)
        .findAll();

    // For each fee structure, compute periods and create invoices for enrolled students
    for (final fs in feeStructures) {
      final periods = _computePeriods(fs, year);
      if (periods.isEmpty) continue;

      await isar.writeTxn(() async {
        for (final period in periods) {
          for (final en in enrollments) {
            // Activity check: skip if enrollment started after period ends
            final enrollmentStart = en.createdAt ?? year.startDate;
            if (enrollmentStart.isAfter(period.end)) continue;

            // Deduplication: skip if invoice already exists for this student+period
            final existingInvoice = await isar.invoices
                .filter()
                .studentIdEqualTo(en.studentId)
                .dueDateEqualTo(period.end)
                .findFirst();
            if (existingInvoice != null) continue;

            // Create invoice
            final invoice = Invoice()
              ..id =
                  '${fs.id}-${en.studentId}-${period.start.toIso8601String()}'
              ..schoolId = schoolId
              ..studentId = en.studentId
              ..invoiceNumber = _invoiceNumberFor(fs, en, period)
              ..termId = null
              ..dueDate = period.end
              ..status = 'DRAFT'
              ..snapshotGrade = en.snapshotGrade
              ..createdAt = DateTime.now();

            await isar.invoices.put(invoice);

            final item = InvoiceItem()
              ..id = '${invoice.id}-item'
              ..invoiceId = invoice.id
              ..feeStructureId = fs.id
              ..description = fs.name
              ..amount = fs.amount
              ..quantity = 1
              ..createdAt = DateTime.now();

            await isar.invoiceItems.put(item);
          }
        }
      });
    }
  }

  /// Compute billing periods based on recurrence and suspensions.
  /// Monthly: bills all months (or specified billableMonths) unless suspended.
  /// Termly: splits year into 3 equal terms, skips suspended periods.
  /// Yearly: single period for the entire academic year.
  List<_Period> _computePeriods(FeeStructure fs, AcademicYear year) {
    final periods = <_Period>[];
    final start = year.startDate;
    final end = year.endDate;

    if (fs.recurrence == 'yearly') {
      periods.add(_Period(start: start, end: end));
    } else if (fs.recurrence == 'monthly') {
      final months = fs.billableMonths.isEmpty
          ? _monthsInRange(start, end)
          : fs.billableMonths;
      for (final m in months) {
        final p = _monthWindow(m, start, end);
        if (p == null) continue;
        if (!_isSuspended(p, fs.suspensions)) {
          periods.add(p);
        }
      }
    } else if (fs.recurrence == 'termly') {
      // Split year into 3 equal terms by default; can be customized later
      final totalDays = end.difference(start).inDays;
      final termDays = (totalDays / 3).floor();
      var s = start;
      for (var i = 0; i < 3; i++) {
        final e = i == 2 ? end : s.add(Duration(days: termDays));
        final p = _Period(start: s, end: e);
        if (!_isSuspended(p, fs.suspensions)) {
          periods.add(p);
        }
        s = e;
      }
    }

    return periods;
  }

  String _invoiceNumberFor(FeeStructure fs, Enrollment en, _Period period) {
    final y = period.start.year;
    final m = period.start.month.toString().padLeft(2, '0');
    return 'INV-$y$m-${fs.id.substring(0, 6)}-${en.studentId.substring(0, 6)}';
  }

  List<int> _monthsInRange(DateTime start, DateTime end) {
    final months = <int>[];
    var cur = DateTime(start.year, start.month, 1);
    final last = DateTime(end.year, end.month, 1);
    while (cur.isBefore(last) || cur.isAtSameMomentAs(last)) {
      months.add(cur.month);
      cur = DateTime(cur.year, cur.month + 1, 1);
    }
    return months;
  }

  _Period? _monthWindow(int month, DateTime start, DateTime end) {
    final y = start.year;
    final mStart = DateTime(y, month, 1);
    final mEnd = DateTime(y, month + 1, 0);
    if (mStart.isBefore(start)) return null;
    if (mEnd.isAfter(end)) return null;
    return _Period(start: mStart, end: mEnd);
  }

  bool _isSuspended(_Period p, List<SuspensionWindow> windows) {
    for (final w in windows) {
      final overlap = !(p.end.isBefore(w.start) || p.start.isAfter(w.end));
      if (overlap) return true;
    }
    return false;
  }
}

class _Period {
  final DateTime start;
  final DateTime end;
  _Period({required this.start, required this.end});
}
