import 'package:fees_up/constants/app_colors.dart';
import 'package:flutter/material.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        title: const Text('Students'),
      ),
      body: const Center(
        child: Text(
          'Students Screen - Placeholder',
          style: TextStyle(color: AppColors.textWhite),
        ),
      ),
    );
  }
}
