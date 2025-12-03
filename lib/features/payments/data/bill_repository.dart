import 'package:fees_up/core/services/database_service.dart';
import 'bill_model.dart';

class BillRepository {
  final DatabaseService _dbService = DatabaseService();

  // ---------------------------------------------------------------------------
  // CREATE
  // ---------------------------------------------------------------------------
  Future<void> createBill(Bill bill) async {
    // We intentionally allow multiple bills for a student (e.g. Tuition + Levy),
    // but the Service layer should check for duplicates before calling this.
    await _dbService.insert('bills', bill.toMap());
  }

  // ---------------------------------------------------------------------------
  // READ (Waterfall Logic Helpers)
  // ---------------------------------------------------------------------------

  /// Get ONLY unpaid or partial bills, sorted by OLDEST first.
  /// This is the key to "Waterfall Billing".
  Future<List<Bill>> getUnpaidBills(String studentId) async {
    final db = await _dbService.database;
    
    final result = await db.rawQuery('''
      SELECT * FROM bills 
      WHERE student_id = ? 
      AND paid_amount < total_amount
      ORDER BY billing_cycle_start ASC
    ''', [studentId]);

    return result.map((map) => Bill.fromMap(map)).toList();
  }

  /// Get the very last bill generated for a student.
  /// Used to determine when the NEXT bill should be.
  Future<Bill?> getLastBill(String studentId) async {
    final db = await _dbService.database;
    
    final result = await db.query(
      'bills',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'billing_cycle_start DESC',
      limit: 1,
    );

    if (result.isNotEmpty) {
      return Bill.fromMap(result.first);
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // UPDATE
  // ---------------------------------------------------------------------------
  Future<void> updateBill(Bill bill) async {
    await _dbService.update(
      'bills',
      bill.toMap(),
      'id = ?',
      [bill.id],
    );
  }
}