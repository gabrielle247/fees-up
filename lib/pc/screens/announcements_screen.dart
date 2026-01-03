/// -----------------------------------------------------------------
/// GREYWAY.CO / BATCH TECH - CONFIDENTIAL
/// -----------------------------------------------------------------
/// Author:  Nyasha Gabriel
/// Date:    2025-12-31
/// -----------------------------------------------------------------
library;

// ------------------------------------------
// NOTE: I want to comment on top of file
// ------------------------------------------

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/announcements/broadcast_kpi_cards.dart';
import '../widgets/announcements/broadcast_list.dart';

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
                _BroadcastsHeader(),
                Divider(height: 1, color: AppColors.divider),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        BroadcastKpiCards(),
                        SizedBox(height: 24),
                        BroadcastList(),
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

class _BroadcastsHeader extends StatelessWidget {
  const _BroadcastsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: AppColors.backgroundBlack,
      child: Row(
        children: [
          const Icon(Icons.campaign, color: AppColors.primaryBlue, size: 28),
          const SizedBox(width: 12),
          const Text("School Broadcasts", style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold)),
          const Spacer(),
          // Placeholder for search or other header actions
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.search, color: AppColors.textWhite54),
          ),
        ],
      ),
    );
  }
}