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
          // Blue Gradient Banner
          Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              gradient: LinearGradient(
                colors: [const Color(0xFF1E3A8A), AppColors.primaryBlue.withValues(alpha: 0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          // Profile Details Layer
          Positioned(
            left: 32,
            bottom: 24,
            right: 32,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Avatar Group
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: AppColors.surfaceGrey, shape: BoxShape.circle),
                      child: const CircleAvatar(
                        radius: 42,
                        backgroundColor: AppColors.textWhite,
                        // backgroundImage: NetworkImage(...) 
                        child: Text("JD", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      ),
                    ),
                    Positioned(
                      bottom: 4, right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.primaryBlue, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                      ),
                    )
                  ],
                ),
                const SizedBox(width: 20),
                
                // Info Text
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Jane Doe", style: TextStyle(color: AppColors.textWhite, fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.verified, size: 16, color: AppColors.primaryBlue),
                            SizedBox(width: 6),
                            Text("Finance Administrator  •  School Admin Portal", style: TextStyle(color: AppColors.textWhite70, fontSize: 13)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textWhite,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        child: const Text("View Public Profile"),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {}, // Save Logic
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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