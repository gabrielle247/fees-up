import 'package:fees_up/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppShell({required this.navigationShell, super.key});

  void _onTabSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surfaceDarkGrey,
          border: Border(
            top: BorderSide(color: AppColors.surfaceLightGrey, width: 0.5),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: GNav(
              backgroundColor: AppColors.surfaceDarkGrey,
              tabBackgroundColor: AppColors.surfaceLightGrey,
              color: AppColors.textGrey,
              activeColor: AppColors.textWhite,
              gap: 8,
              tabBorderRadius: 12,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              selectedIndex: navigationShell.currentIndex,
              onTabChange: _onTabSelected,
              tabs: const [
                GButton(
                  icon: Icons.dashboard_outlined,
                  text: 'Dashboard',
                ),
                GButton(
                  icon: Icons.people_outline,
                  text: 'Students',
                ),
                GButton(
                  icon: Icons.account_balance_wallet_outlined,
                  text: 'Finance',
                ),
                GButton(
                  icon: Icons.settings_outlined,
                  text: 'Configs',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
