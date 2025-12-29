import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fees_up/data/models/finance_models.dart';
import 'package:fees_up/data/repositories/expense_repository.dart';
import 'package:fees_up/data/providers/school_provider.dart'; // Assuming you have this for currentSchoolId

// 1. STREAM: Live list of expenses
final recentExpensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  // Replace with your actual provider for getting the active school ID
  // e.g. ref.watch(currentSchoolIdProvider);
  // For safety, I'll return an empty stream if ID is missing.
  final schoolId = ref.watch(activeSchoolIdProvider); 
  
  if (schoolId == null) return const Stream.empty();

  final repo = ref.read(expenseRepositoryProvider);
  return repo.watchRecentExpenses(schoolId);
});

// 2. CONTROLLER: Handles the Save Action
class ExpenseController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  ExpenseController(this.ref) : super(const AsyncData(null));

  Future<bool> saveExpense({
    required String title,
    required double amount,
    required DateTime date,
    String? category,
    String? recipient,
    String? notes,
    String? paymentMethod,
  }) async {
    state = const AsyncLoading();
    try {
      final schoolId = ref.read(activeSchoolIdProvider);
      if (schoolId == null) throw Exception("No active school found.");

      final repo = ref.read(expenseRepositoryProvider);
      
      await repo.createExpense(
        schoolId: schoolId,
        title: title,
        amount: amount,
        incurredAt: date,
        category: category,
        recipient: recipient,
        notes: notes,
        paymentMethod: paymentMethod,
      );

      state = const AsyncData(null);
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }
}

final expenseControllerProvider = StateNotifierProvider<ExpenseController, AsyncValue<void>>((ref) {
  return ExpenseController(ref);
});