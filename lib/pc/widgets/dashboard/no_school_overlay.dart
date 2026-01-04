import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// No School Overlay Fragment - Displays when school setup is incomplete
/// Complies with Law of Fragments: Isolated overlay logic
class NoSchoolOverlay extends StatelessWidget {
  final bool isConnected;
  final VoidCallback onCreateSchool;

  const NoSchoolOverlay({
    super.key,
    required this.isConnected,
    required this.onCreateSchool,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: AppColors.overlayDark,
        child: Center(
          child: Container(
            width: 500,
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isConnected ? Icons.domain_add : Icons.cloud_off,
                  size: 64,
                  color:
                      isConnected ? AppColors.primaryBlue : AppColors.iconGrey,
                ),
                const SizedBox(height: 24),
                Text(
                  isConnected ? "Welcome to Fees Up!" : "Syncing Data...",
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  isConnected
                      ? "It looks like you haven't set up a school yet. Create one now to access the dashboard."
                      : "We are waiting for your school data to download. Please check your internet connection.",
                  style: const TextStyle(
                    color: AppColors.textWhite70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (isConnected)
                  ElevatedButton(
                    onPressed: onCreateSchool,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.textWhite,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 20,
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text("Create School Profile"),
                  )
                else
                  const Column(
                    children: [
                      CircularProgressIndicator(color: AppColors.textWhite),
                      SizedBox(height: 16),
                      Text(
                        "Waiting for sync...",
                        style: TextStyle(color: AppColors.textWhite38),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
