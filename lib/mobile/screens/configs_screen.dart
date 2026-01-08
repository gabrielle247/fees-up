import 'package:fees_up/constants/app_colors.dart';
import 'package:flutter/material.dart';
class ConfigsScreen extends StatelessWidget {
  const ConfigsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        title: const Text('Configs'),
      ),
      body: const Center(
        child: Text(
          'Configs Screen - Placeholder',
          style: TextStyle(color: AppColors.textWhite),
        ),
      ),
    );
  }
}
