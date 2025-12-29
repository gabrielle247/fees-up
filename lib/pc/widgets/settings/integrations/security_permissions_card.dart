import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class SecurityPermissionsCard extends StatefulWidget {
  const SecurityPermissionsCard({super.key});

  @override
  State<SecurityPermissionsCard> createState() => _SecurityPermissionsCardState();
}

class _SecurityPermissionsCardState extends State<SecurityPermissionsCard> {
  bool _whitelist = false;
  bool _readAttend = false;
  bool _writeAttend = false;
  bool _readCamp = true;
  bool _readFin = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack, // Darker contrast
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Security & Permissions", style: TextStyle(color: AppColors.textWhite, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text("Global settings for external access.", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
          
          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 24),

          // IP Whitelist
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Require IP Whitelisting", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text("Only allow access tokens to be used from known school IP addresses.", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
                ],
              ),
              Switch(
                value: _whitelist, 
                onChanged: (v) => setState(() => _whitelist = v),
                activeColor: AppColors.primaryBlue,
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Text("Default Token Permissions", style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Permissions Grid
          Row(
            children: [
              Expanded(child: _permTile("Attendance Read", "Allow viewing student attendance.", _readAttend, (v) => setState(() => _readAttend = v!))),
              const SizedBox(width: 16),
              Expanded(child: _permTile("Attendance Write", "Allow marking attendance.", _writeAttend, (v) => setState(() => _writeAttend = v!))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _permTile("Campaign Read", "Allow viewing campaign stats.", _readCamp, (v) => setState(() => _readCamp = v!))),
              const SizedBox(width: 16),
              Expanded(child: _permTile("Financial Read", "Allow viewing basic financial summaries.", _readFin, (v) => setState(() => _readFin = v!))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _permTile(String label, String sub, bool value, Function(bool?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: value ? AppColors.primaryBlue : AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20, height: 20,
            child: Checkbox(
              value: value, 
              onChanged: onChanged,
              activeColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.textWhite54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(sub, style: const TextStyle(color: AppColors.textWhite54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}