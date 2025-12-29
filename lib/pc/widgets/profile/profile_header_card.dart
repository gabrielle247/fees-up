import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Stack(
        children: [
          // Banner Background
          Container(
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A), // Dark Blue Banner
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              gradient: LinearGradient(
                colors: [const Color(0xFF1E3A8A), AppColors.primaryBlue.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Profile Content
          Positioned(
            left: 24,
            bottom: 24,
            right: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar with Camera Icon
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: AppColors.surfaceGrey, shape: BoxShape.circle),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.textWhite,
                        // backgroundImage: NetworkImage('...'), // Add real image here
                        child: Text("JD", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 16),
                
                // Text Info
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Jane Doe", style: TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.verified, size: 14, color: AppColors.primaryBlue),
                            SizedBox(width: 4),
                            Text("Finance Administrator  •  School Admin Portal", style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textWhite,
                          side: const BorderSide(color: AppColors.divider),
                        ),
                        child: const Text("View Public Profile"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Save Changes"),
                      ),
                    ],
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