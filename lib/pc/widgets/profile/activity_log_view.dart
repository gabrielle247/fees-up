import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ActivityLogView extends StatelessWidget {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Recent Activity", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
              OutlinedButton.icon(
                onPressed: (){}, 
                icon: const Icon(Icons.download, size: 14),
                label: const Text("Export Log", style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Audit log of actions performed by your account.", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
          const SizedBox(height: 32),

          // Log Items
          _buildLogItem(
            action: "Updated Billing Settings",
            detail: "Changed late fee percentage from 1.2% to 1.5%",
            time: "2 hours ago",
            icon: Icons.edit_note,
            iconColor: AppColors.primaryBlue,
          ),
          _buildTimelineConnector(),
          
          _buildLogItem(
            action: "User Login",
            detail: "Successful login from Chrome on Windows 11 (IP: 192.168.1.42)",
            time: "Today, 09:41 AM",
            icon: Icons.login,
            iconColor: AppColors.successGreen,
          ),
          _buildTimelineConnector(),

          _buildLogItem(
            action: "Exported Data",
            detail: "Downloaded 'Student_List_Oct.csv'",
            time: "Yesterday, 4:20 PM",
            icon: Icons.cloud_download,
            iconColor: Colors.orange,
          ),
          _buildTimelineConnector(),

          _buildLogItem(
            action: "Password Changed",
            detail: "Security update via Profile Settings",
            time: "Oct 28, 2023",
            icon: Icons.lock_reset,
            iconColor: AppColors.textWhite,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineConnector() {
    return Container(
      width: 1,
      height: 24,
      margin: const EdgeInsets.only(left: 20), // Align with circle center (12 padding + 8 radius)
      color: AppColors.divider,
    );
  }

  Widget _buildLogItem({
    required String action, 
    required String detail, 
    required String time, 
    required IconData icon, 
    required Color iconColor
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.divider),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(action, style: const TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(time, style: const TextStyle(color: AppColors.textWhite38, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(color: AppColors.textWhite54, fontSize: 13, height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }
}