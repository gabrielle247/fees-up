// lib/models/dashboard_summary.dart

class DashboardSummary {
  final int activeStudents;
  final int inactiveStudents;
  final double totalFeesBilled;
  final double totalFeesOwed;
  final double totalFeesPaid;

  DashboardSummary({
    required this.activeStudents,
    this.inactiveStudents = 0,
    this.totalFeesBilled = 0.0,
    this.totalFeesOwed = 0.0,
    this.totalFeesPaid = 0.0,
  });

  factory DashboardSummary.initial() => DashboardSummary(activeStudents: 0);
}