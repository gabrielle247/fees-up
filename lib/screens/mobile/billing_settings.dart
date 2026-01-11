import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';

// =============================================================================
// 1. LOCAL STRINGS & CONSTANTS (Strictly No UI String Literals)
// =============================================================================
class _ConfigStrings {
  static const String pageTitle = "Configurations";
  
  // Sections
  static const String secSchool = "School Management";
  static const String secApp = "Application Settings";
  static const String secData = "Data & Sync";
  static const String secAccount = "Account";

  // Items - School
  static const String itemProfile = "School Profile";
  static const String subProfile = "Edit details, logo, and contact info";
  static const String itemBilling = "Billing Configuration";
  static const String subBilling = "Fee cycles, penalties, and structures";
  static const String itemUsers = "User Management";
  static const String subUsers = "Manage admins and staff access";

  // Items - App
  static const String itemTheme = "Dark Mode";
  static const String itemNotifs = "Notifications";
  
  // Items - Data
  static const String itemSync = "Sync Status";
  static const String subSync = "Last synced: Just now";
  static const String itemExport = "Export Data";
  
  // Items - Account
  static const String itemPlan = "Subscription Plan";
  static const String subPlan = "Current: Pro Plan";
  static const String itemLogout = "Log Out";
  static const String itemHelp = "Help & Support";

  // Routes
  static const String routeBilling = "/billing";
  static const String routeProfile = "/create-school"; // Reusing create screen for edit
  static const String routePlans = "/plans";
  static const String routeLogin = "/login";
}

// =============================================================================
// 2. SCREEN IMPLEMENTATION
// =============================================================================
class ConfigsScreen extends StatefulWidget {
  const ConfigsScreen({super.key});

  @override
  State<ConfigsScreen> createState() => _ConfigsScreenState();
}

class _ConfigsScreenState extends State<ConfigsScreen> {
  // State
  bool _isDarkMode = true; // Mock state, normally from Riverpod/Provider
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(_ConfigStrings.pageTitle),
        centerTitle: true,
        automaticallyImplyLeading: false, // Root tab, no back button
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- School Identity Header ---
              _buildSchoolHeader(context),
              
              const SizedBox(height: 32),

              // ================= SECTION 1: SCHOOL MANAGEMENT =================
              _buildSectionHeader(context, _ConfigStrings.secSchool),
              _buildSettingsTile(
                context,
                icon: Icons.business_outlined,
                title: _ConfigStrings.itemProfile,
                subtitle: _ConfigStrings.subProfile,
                onTap: () => context.push(_ConfigStrings.routeProfile),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.receipt_long_outlined,
                title: _ConfigStrings.itemBilling,
                subtitle: _ConfigStrings.subBilling,
                onTap: () => context.push(_ConfigStrings.routeBilling),
              ),
              _buildSettingsTile(
                context,
                icon: Icons.people_outline,
                title: _ConfigStrings.itemUsers,
                subtitle: _ConfigStrings.subUsers,
                onTap: () {}, // Todo: Implement User Management
              ),

              const SizedBox(height: 24),

              // ================= SECTION 2: APP SETTINGS =================
              _buildSectionHeader(context, _ConfigStrings.secApp),
              
              // Dark Mode Switch
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceLightGrey : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.dark_mode_outlined, 
                    color: isDark ? Colors.white : Colors.black54
                  ),
                ),
                title: Text(
                  _ConfigStrings.itemTheme,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                value: _isDarkMode,
                activeThumbColor: AppColors.primaryBlue,
                onChanged: (val) {
                  setState(() => _isDarkMode = val);
                  // Todo: Trigger global theme change
                },
              ),
              
              const Divider(),
              
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceLightGrey : Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_outlined, 
                    color: isDark ? Colors.white : Colors.black54
                  ),
                ),
                title: Text(
                  _ConfigStrings.itemNotifs,
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                value: _pushNotifications,
                activeThumbColor: AppColors.primaryBlue,
                onChanged: (val) => setState(() => _pushNotifications = val),
              ),

              const SizedBox(height: 24),

              // ================= SECTION 3: DATA & SYNC =================
              _buildSectionHeader(context, _ConfigStrings.secData),
              _buildSettingsTile(
                context,
                icon: Icons.sync,
                title: _ConfigStrings.itemSync,
                subtitle: _ConfigStrings.subSync,
                trailing: const Icon(Icons.check_circle, color: AppColors.successGreen, size: 16),
                onTap: () {},
              ),
              _buildSettingsTile(
                context,
                icon: Icons.download_outlined,
                title: _ConfigStrings.itemExport,
                onTap: () {},
              ),

              const SizedBox(height: 24),

              // ================= SECTION 4: ACCOUNT =================
              _buildSectionHeader(context, _ConfigStrings.secAccount),
              _buildSettingsTile(
                context,
                icon: Icons.star_outline,
                title: _ConfigStrings.itemPlan,
                subtitle: _ConfigStrings.subPlan,
                iconColor: AppColors.primaryBlue,
                onTap: () => context.push(_ConfigStrings.routePlans),
              ),
               _buildSettingsTile(
                context,
                icon: Icons.help_outline,
                title: _ConfigStrings.itemHelp,
                onTap: () {},
              ),
              
              const SizedBox(height: 16),
              
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    // Clear Auth State & Go to Login
                    context.go(_ConfigStrings.routeLogin);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.errorRed),
                  label: const Text(
                    _ConfigStrings.itemLogout,
                    style: TextStyle(color: AppColors.errorRed, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.errorRed.withAlpha(20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              
              const SizedBox(height: 40), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================

  Widget _buildSchoolHeader(BuildContext context) {
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withAlpha(80),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: AppColors.primaryBlue, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Springfield Elementary", // Placebo School Name
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Admin Access",
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => context.push(_ConfigStrings.routeProfile),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppColors.textGrey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceLightGrey : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            color: iconColor ?? (isDark ? Colors.white : Colors.black54),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null 
            ? Text(subtitle, style: theme.textTheme.bodySmall) 
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right, size: 20, color: AppColors.textGrey),
      ),
    );
  }
}