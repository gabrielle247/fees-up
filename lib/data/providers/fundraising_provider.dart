import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import 'dashboard_provider.dart';

class FundraisingData {
  final String campaignName;
  final double goalAmount;
  final double raisedAmount;
  final double percentage;

  FundraisingData({
    required this.campaignName,
    required this.goalAmount,
    required this.raisedAmount,
    required this.percentage,
  });
}

final fundraisingProvider = FutureProvider<FundraisingData?>((ref) async {
  final dashboardData = await ref.watch(dashboardDataProvider.future);
  final schoolId = dashboardData.schoolId;
  final db = DatabaseService().db;

  // 1. Get the ACTIVE campaign for this school
  // We explicitly look for status = 'active'
  final campaigns = await db.getAll(
    "SELECT * FROM campaigns WHERE school_id = ? AND status = 'active' ORDER BY created_at DESC LIMIT 1",
    [schoolId],
  );

  if (campaigns.isEmpty) return null; // No active campaign found

  final campaign = campaigns.first;
  final campaignId = campaign['id'];
  final goal = (campaign['goal_amount'] as num?)?.toDouble() ?? 100.0; 
  final name = campaign['name'] ?? 'Campaign';

  // 2. Sum donations for this specific campaign ID
  final donations = await db.getAll(
    "SELECT sum(amount) as total FROM campaign_donations WHERE campaign_id = ?",
    [campaignId],
  );

  final raised = (donations.first['total'] as num?)?.toDouble() ?? 0.0;

  // 3. Calculate Percentage (Safe division)
  double percent = 0.0;
  if (goal > 0) {
    percent = (raised / goal) * 100;
  }
  
  // Cap percentage visual at 100% (optional, but looks better on progress bars)
  // For the text value, we keep the real percentage.
  
  return FundraisingData(
    campaignName: name,
    goalAmount: goal,
    raisedAmount: raised,
    percentage: percent,
  );
});