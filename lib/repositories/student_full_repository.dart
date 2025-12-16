import 'dart:async';

import '../models/student_full.dart';
import '../services/database_service.dart';
// package:collection is available if advanced list/grouping utilities are needed later.

/// Repository that wraps database hydration, adds computed indicators
/// and exposes a stream for UI layers.
class StudentFullRepository {
  StudentFullRepository({DatabaseService? db}) : _db = db ?? DatabaseService.instance;

  final DatabaseService _db;
  List<StudentFull>? _cache;
  final StreamController<List<StudentFull>> _controller = StreamController.broadcast();

  Stream<List<StudentFull>> get stream => _controller.stream;

  Future<List<StudentFull>> refresh({bool includeInactive = false}) async {
    // Use DatabaseService's hydration as the source of truth and then
    // compute additional derived fields for each StudentFull entry.
    final list = await _db.refreshStudentFullCache(includeInactive: includeInactive);
    _cache = list.map((s) => _withIndicators(s)).toList();
    _controller.add(_cache!);
    return _cache!;
  }

  Future<List<StudentFull>> all({bool includeInactive = false}) async {
    if (_cache == null) return await refresh(includeInactive: includeInactive);
    if (!includeInactive) return _cache!.where((s) => s.student.isActive).toList();
    return _cache!;
  }

  Future<StudentFull?> byId(String id) async {
    final r = await all();
    for (final s in r) {
      if (s.student.id == id) return s;
    }
    return null;
  }

  Map<String, Object?> computeIndicators(StudentFull s) {
    // Basic indicators: previousDebt, currentCycleStatus
    final now = DateTime.now();
    final billingType = s.student.billingType ?? 'monthly';
    DateTime cycleStart;
    DateTime cycleEnd;
    String cycleKey;
    if (billingType == 'monthly') {
      cycleStart = DateTime(now.year, now.month, 1);
      cycleEnd = DateTime(now.year, now.month + 1, 0);
      cycleKey = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    } else if (billingType == 'yearly') {
      cycleStart = DateTime(now.year, 1, 1);
      cycleEnd = DateTime(now.year, 12, 31);
      cycleKey = now.year.toString();
    } else {
      // fallback to monthly for terms that don't have term mapping
      cycleStart = DateTime(now.year, now.month, 1);
      cycleEnd = DateTime(now.year, now.month + 1, 0);
      cycleKey = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    }

    // previous debt = sum(bills before cycleStart) - sum(payments before cycleStart)
    double pastBills = 0.0;
    double pastPayments = 0.0;
    // Collect bill IDs that are truly in the past (entire cycle before current cycle)
    final pastBillIds = <String>{};
    for (final b in s.bills) {
      if (b.cycleEnd != null && b.cycleEnd!.isBefore(cycleStart)) {
        pastBills += b.totalAmount;
        pastBillIds.add(b.id);
      } else if (b.cycleEnd == null && b.createdAt != null && b.createdAt!.isBefore(cycleStart)) {
        pastBills += b.totalAmount;
        pastBillIds.add(b.id);
      }
    }
    // Sum payments that were applied to those past bills (regardless of payment date)
    for (final p in s.payments) {
      if (p.billId != null && pastBillIds.contains(p.billId)) pastPayments += p.amount;
    }
    final previousDebt = (pastBills - pastPayments).clamp(0.0, double.infinity);

    // current cycle bills
    final currentBills = s.bills.where((b) {
      if (b.monthYear != null) return b.monthYear == cycleKey;
      if (b.cycleStart != null && b.cycleEnd != null) {
        return !(b.cycleEnd!.isBefore(cycleStart) || b.cycleStart!.isAfter(cycleEnd));
      }
      return false;
    }).toList();

    String cycleStatus = 'missing';
    if (currentBills.isEmpty) {
      cycleStatus = 'missing';
    } else {
      final total = currentBills.fold<double>(0.0, (p, b) => p + b.totalAmount);
      final paid = currentBills.fold<double>(0.0, (p, b) => p + b.paidAmount);
      if (paid <= 0) {
        cycleStatus = 'unpaid';
      // ignore: curly_braces_in_flow_control_structures
      } else if (paid >= total) cycleStatus = 'paid';
      // ignore: curly_braces_in_flow_control_structures
      else cycleStatus = 'partial';
    }

    return {
      'cycleKey': cycleKey,
      'cycleStart': cycleStart.toIso8601String(),
      'cycleEnd': cycleEnd.toIso8601String(),
      'previousDebt': previousDebt,
      'currentCycleStatus': cycleStatus,
      'currentBillsCount': currentBills.length,
    };
  }

  StudentFull _withIndicators(StudentFull s) {
    // Currently computeIndicators(s) returns a map of computed values;
    // we don't mutate `StudentFull` (immutable), but it can be returned
    // alongside the StudentFull for UI purposes. For now we keep this
    // method to show where indicator enrichment would happen.
    computeIndicators(s);
    return s;
  }
}
