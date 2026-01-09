import 'package:fees_up/constants/app_colors.dart';
import 'package:fees_up/data/providers/dashboard_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RevenueReportsScreen extends ConsumerWidget {
  const RevenueReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reusing the totalCashCollectedProvider for now as a base
    final totalRevenueAsync = ref.watch(totalCashCollectedProvider);
    final growthAsync = ref.watch(revenueGrowthProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceGrey,
        title: const Text('Revenue Reports',
            style: TextStyle(color: AppColors.textWhite)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total Revenue Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue,
                    AppColors.primaryBlue.withValues(alpha: 0.6)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Lifetime Revenue",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  totalRevenueAsync.when(
                    data: (amount) => Text(
                      "\$${(amount / 100).toStringAsFixed(2)}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                    loading: () =>
                        const CircularProgressIndicator(color: Colors.white),
                    error: (e, s) => const Text("\$0.00",
                        style: TextStyle(color: Colors.white, fontSize: 32)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Growth Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    "Growth",
                    growthAsync.when(
                      data: (g) =>
                          "${g >= 0 ? '+' : ''}${g.toStringAsFixed(1)}%",
                      loading: () => "...",
                      error: (_, __) => "0%",
                    ),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          Text(title,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
        ],
      ),
    );
  }
}
