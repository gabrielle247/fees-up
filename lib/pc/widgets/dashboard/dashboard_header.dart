import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Dashboard Header Fragment - Shows overview title and school name
/// Complies with Law of Fragments: Small, reusable header widget
class DashboardHeader extends StatelessWidget {
  final String schoolName;

  const DashboardHeader({
    super.key,
    required this.schoolName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Overview",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textWhite,
          ),
        ),
        Text(
          "Status for $schoolName",
          style: const TextStyle(color: AppColors.textWhite54),
        ),
      ],
    );
  }
}
