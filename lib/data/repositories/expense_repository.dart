import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:fees_up/data/services/database_service.dart'; // Adjust path
import 'package:fees_up/data/models/finance_models.dart'; // Adjust path

final expenseRepositoryProvider = Provider((ref) => ExpenseRepository());

class ExpenseRepository {
  final _db = DatabaseService();

  /// Watch expenses for the specific school (Live Stream)
  Stream<List<Expense>> watchRecentExpenses(String schoolId) {
    return _db.db.watch(
      'SELECT * FROM expenses WHERE school_id = ? ORDER BY incurred_at DESC LIMIT 20',
      parameters: [schoolId],
    ).map((rows) => rows.map((row) => Expense.fromRow(row)).toList());
  }

  /// Insert a new expense locally (PowerSync syncs it up)
  Future<void> createExpense({
    required String schoolId,
    required String title,
    required double amount,
    required DateTime incurredAt,
    String? category,
    String? recipient,
    String? notes,
    String? paymentMethod,
  }) async {
    // Since schema lacks 'payment_method', we append it to description
    String finalDescription = notes ?? "";
    if (paymentMethod != null && paymentMethod.isNotEmpty) {
      finalDescription += "\n[Method: $paymentMethod]";
    }

    final newExpense = Expense(
      id: const Uuid().v4(), // Generate ID client-side
      schoolId: schoolId,
      title: title,
      amount: amount,
      incurredAt: incurredAt,
      category: category,
      recipient: recipient,
      description: finalDescription.trim().isEmpty ? null : finalDescription.trim(),
    );

    await _db.insert('expenses', newExpense.toMap());
  }
}