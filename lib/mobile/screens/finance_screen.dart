import 'package:fees_up/constants/app_colors.dart';
import 'package:flutter/material.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        title: const Text('Finance'),
      ),
      body: const Center(
        child: Text(
          'Finance Screen - Placeholder',
          style: TextStyle(color: AppColors.textWhite),
        ),
      ),
    );
  }
}
