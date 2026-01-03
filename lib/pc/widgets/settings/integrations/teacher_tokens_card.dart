import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class TeacherTokensCard extends StatelessWidget {
  const TeacherTokensCard({super.key});

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
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Teacher Access Tokens", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text("Manage temporary access for attendance and campaign tools.", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {}, // Open Generator Dialog
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Generate Token"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Table Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _col("TOKEN ID / NAME", 4),
                _col("PERMISSION\nTYPE", 3),
                _col("EXPIRES AT", 3),
                _col("STATUS", 2),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // Rows
          const _TokenRow(
            name: "Ms. Johnson - Fall",
            id: "tk_live_...4829",
            type: "Attendance",
            typeColor: Color(0xFF4F46E5), // Indigo
            expiry: "Dec 15, 2023",
            status: "Active",
            statusColor: AppColors.successGreen,
            icon: Icons.vpn_key,
          ),
          const Divider(height: 1, color: AppColors.divider),
          
          const _TokenRow(
            name: "Fundraiser Team",
            id: "tk_live_...9921",
            type: "Campaign Mgr",
            typeColor: Color(0xFF9333EA), // Purple
            expiry: "Nov 30, 2023",
            status: "Used (12)",
            statusColor: Colors.amber,
            icon: Icons.campaign,
          ),
          const Divider(height: 1, color: AppColors.divider),

          const _TokenRow(
            name: "Temp Staff",
            id: "tk_test_...1162",
            type: "Read Only",
            typeColor: AppColors.textWhite38,
            expiry: "Oct 01, 2023",
            status: "Expired",
            statusColor: AppColors.errorRed,
            icon: Icons.lock_clock,
          ),

          // Footer
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Showing 3 of 15 tokens", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                SizedBox(width: 16),
                // Simple Pagination
                Icon(Icons.chevron_left, color: AppColors.textWhite38),
                SizedBox(width: 8),
                Icon(Icons.chevron_right, color: AppColors.textWhite),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _col(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textWhite38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  final String name;
  final String id;
  final String type;
  final Color typeColor;
  final String expiry;
  final String status;
  final Color statusColor;
  final IconData icon;

  const _TokenRow({
    required this.name, required this.id, required this.type, required this.typeColor,
    required this.expiry, required this.status, required this.statusColor, required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 1. Name & ID
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.backgroundBlack, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, size: 16, color: typeColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(id, style: const TextStyle(color: AppColors.textWhite38, fontFamily: 'monospace', fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          
          // 2. Type Badge
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: typeColor.withAlpha(77)),
                  ),
                  child: Text(type, style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // 3. Expiry
          Expanded(
            flex: 3,
            child: Text(expiry, style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
          ),

          // 4. Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(status, style: const TextStyle(color: AppColors.textWhite, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}