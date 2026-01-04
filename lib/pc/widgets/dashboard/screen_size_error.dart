import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Screen Size Error Fragment - Displays when screen is too small for PC view
/// Complies with Law of Fragments: Reusable error state widget
class ScreenSizeError extends StatelessWidget {
  const ScreenSizeError({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.desktop_windows,
            size: 64,
            color: AppColors.errorRed,
          ),
          SizedBox(height: 24),
          Text(
            "Window Size Too Small",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "This application requires a minimum resolution of 1024px width.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textWhite70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
