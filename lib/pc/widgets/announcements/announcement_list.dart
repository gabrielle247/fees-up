import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class AnnouncementList extends StatelessWidget {
  const AnnouncementList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          // Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterTab("All", true),
                _buildFilterTab("Financial", false),
                _buildFilterTab("Academic", false),
                _buildFilterTab("System", false),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: (){}, 
                  icon: const Icon(Icons.done_all, size: 16),
                  label: const Text("Mark all read"),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textWhite, side: const BorderSide(color: AppColors.divider)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: (){}, 
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("New Announcement"),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // List Items
          _buildItem(
            title: "Overdue Fees Alert", 
            badge: "Urgent", badgeColor: AppColors.errorRed,
            body: "12 Students have overdue tuition fees exceeding \$500 for the Fall Semester.",
            time: "Today, 09:00 AM",
            icon: Icons.warning_amber, iconColor: AppColors.errorRed,
            isNew: true
          ),
          const Divider(height: 1, color: AppColors.divider),
          
          _buildItem(
            title: "Donation Received", 
            badge: "Financial", badgeColor: AppColors.successGreen,
            body: "New donation of \$5,000.00 received from the Alumni Association via Wire Transfer.",
            time: "Yesterday, 4:15 PM",
            icon: Icons.attach_money, iconColor: AppColors.successGreen,
          ),
          const Divider(height: 1, color: AppColors.divider),

          _buildItem(
            title: "System Maintenance", 
            badge: "System", badgeColor: const Color(0xFF9333EA),
            body: "Scheduled maintenance will occur this Saturday at 10:00 PM EST.",
            time: "Oct 22, 2023",
            icon: Icons.dns, iconColor: const Color(0xFF9333EA),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.backgroundBlack : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(color: isActive ? AppColors.textWhite : AppColors.textWhite70, fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildItem({
    required String title, required String badge, required Color badgeColor,
    required String body, required String time, required IconData icon, required Color iconColor,
    bool isNew = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: isNew ? AppColors.backgroundBlack.withValues(alpha: 0.3) : null,
      child: Row(
        children: [
          // Left Border indicator for new items
          if (isNew) Container(width: 3, height: 40, color: AppColors.errorRed, margin: const EdgeInsets.only(right: 16)),
          
          CircleAvatar(
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(badge, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    if (isNew) ...[
                      const SizedBox(width: 8),
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle)),
                    ]
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(color: AppColors.textWhite38, fontSize: 12)),
          const SizedBox(width: 16),
          const Icon(Icons.more_horiz, color: AppColors.textWhite38),
        ],
      ),
    );
  }
}