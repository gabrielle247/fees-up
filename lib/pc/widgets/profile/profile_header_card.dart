import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/providers/dashboard_provider.dart';

class ProfileHeaderCard extends ConsumerWidget {
  const ProfileHeaderCard({super.key});

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

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
            child: dashboardAsync.when(
              data: (data) => _buildProfileContent(context, data.userName, data.schoolName),
              loading: () => _buildProfileContent(context, "Loading...", ""),
              error: (err, stack) => _buildProfileContent(context, "Error", ""),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, String userName, String schoolName) {
    final initials = _getInitials(userName);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar Group
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(color: AppColors.surfaceGrey, shape: BoxShape.circle),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName.isEmpty ? "User" : userName,
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.verified, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        schoolName.isNotEmpty 
                            ? "Administrator  •  $schoolName"
                            : "Administrator  •  School Portal",
                        style: const TextStyle(color: AppColors.textWhite70, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Public profile coming soon')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textWhite,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                child: const Text("View Public Profile"),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile saved'), backgroundColor: AppColors.successGreen),
                  );
                },
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
    );
  }
}