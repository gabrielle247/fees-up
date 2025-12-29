import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ApiConfigCard extends StatelessWidget {
  const ApiConfigCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("API Configuration", style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          const Text("Base URL", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(6)),
                ),
                child: const Text("GET", style: TextStyle(color: AppColors.textWhite70, fontSize: 12, fontFamily: 'monospace')),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.backgroundBlack,
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                  ),
                  child: const Text("https://api.schooladmin.io/v1/", style: TextStyle(color: AppColors.textWhite, fontSize: 13, fontFamily: 'monospace')),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Text("Webhook Secret", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundBlack,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("•••••••••••••••••••••", style: TextStyle(color: AppColors.textWhite54, letterSpacing: 2)),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, size: 16, color: AppColors.textWhite54),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            "View API Documentation ↗", 
            style: TextStyle(color: AppColors.primaryBlue, fontSize: 12),
          ),
        ],
      ),
    );
  }
}