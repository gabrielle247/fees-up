import 'package:fees_up/pc/widgets/settings/integrations_settings_view.dart';
import 'package:fees_up/pc/widgets/settings/notifications_settings_view.dart';
import 'package:fees_up/pc/widgets/settings/school_year_settings_view.dart';
import 'package:fees_up/pc/widgets/settings/users_permissions_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/sidebar.dart';
import '../widgets/settings/settings_header.dart';
import '../widgets/settings/general_financial_view.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedTabIndex = 0;
  
  // The tabs exactly as required for future expansion
  final List<String> _tabs = [
    "General & Financial",
    "School Year",
    "Users & Permissions",
    "Notifications",
    "Integrations"
  ];

  void _handleSearchNavigation(int tabIndex) {
    setState(() {
      _selectedTabIndex = tabIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      body: Row(
        children: [
          const DashboardSidebar(),
          Expanded(
            child: Column(
              children: [
                // 1. Header with wired search callback
                SettingsHeader(onSearchNavigation: _handleSearchNavigation),
                
                // 2. Inner Navigation Bar
                Container(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.divider)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final isSelected = _selectedTabIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = index),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                          margin: const EdgeInsets.only(right: 32),
                          decoration: BoxDecoration(
                            border: isSelected 
                              ? const Border(bottom: BorderSide(color: AppColors.primaryBlue, width: 2))
                              : null,
                          ),
                          child: Text(
                            _tabs[index],
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryBlue : AppColors.textWhite54,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                // 3. Body Content (Switched based on tab)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedTabIndex) {
      case 0:
        return const GeneralFinancialView();
      case 1:
        return const SchoolYearSettingsView();
      case 2:
        return const UsersPermissionsView();
      case 3:
        return const NotificationsSettingsView();
      case 4:
        return const IntegrationsSettingsView();
      default:
        return const SizedBox();
    }
  }
}