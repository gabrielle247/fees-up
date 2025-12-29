import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/announcements/announcement_kpi_cards.dart';
import '../widgets/announcements/announcement_list.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          DashboardSidebar(),
          Expanded(
            child: Column(
              children: [
                // Header (Can customize specifically if needed, but reusing keeps consistency)
                _AnnouncementsHeader(),
                Divider(height: 1, color: AppColors.divider),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        AnnouncementKpiCards(),
                        SizedBox(height: 24),
                        AnnouncementList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementsHeader extends StatelessWidget {
  const _AnnouncementsHeader();

  @override
  Widget build(BuildContext context) {
    // Similar to other headers but with specific title
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.backgroundBlack,
      child: const Row(
        children: [
          Text("Announcements", style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          Spacer(),
          // ... Standard search/profile widgets ...
          // Keeping it brief here as we already have the Header code
        ],
      ),
    );
  }
}