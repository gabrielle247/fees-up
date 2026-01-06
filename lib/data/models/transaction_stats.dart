/// Transaction Statistics Data Model
class TransactionStats {
  final double totalIncome;
  final double totalExpenses;
  final double totalDonations;
  final int pendingCount;
  final double pendingAmount;
  final double netIncome;
  final int paymentsCount;
  final int expensesCount;
  final int donationsCount;

  TransactionStats({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalDonations,
    required this.pendingCount,
    required this.pendingAmount,
    required this.netIncome,
    required this.paymentsCount,
    required this.expensesCount,
    required this.donationsCount,
  });
}
