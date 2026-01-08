import 'package:fees_up/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.surfaceGrey,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textGrey,
        currentIndex: _getCurrentIndex(context),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.trending_up), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Configs'),
        ],
        onTap: (index) => _navigateTo(context, index),
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('dashboard')) return 0;
    if (location.contains('students')) return 1;
    if (location.contains('finance')) return 2;
    if (location.contains('configs')) return 3;
    return 0;
  }

  void _navigateTo(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.goNamed('dashboard');
        break;
      case 1:
        context.goNamed('students');
        break;
      case 2:
        context.goNamed('finance');
        break;
      case 3:
        context.goNamed('configs');
        break;
    }
  }
}
