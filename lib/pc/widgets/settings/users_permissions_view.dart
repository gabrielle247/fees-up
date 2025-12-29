import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/providers/users_provider.dart';
import 'add_user_dialog.dart';

class UsersPermissionsView extends ConsumerStatefulWidget {
  const UsersPermissionsView({super.key});

  @override
  ConsumerState<UsersPermissionsView> createState() => _UsersPermissionsViewState();
}

class _UsersPermissionsViewState extends ConsumerState<UsersPermissionsView> {
  // --- Local State for Filters ---
  String _searchQuery = "";
  String _selectedRole = "All Roles";
  String _selectedStatus = "All Status";

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(schoolUsersProvider);
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Column(
      children: [
        // 1. FILTER & ACTION BAR
        Row(
          children: [
            // Search Field
            Expanded(
              child: _buildSearchField(),
            ),
            const SizedBox(width: 16),
            
            // Role Dropdown
            _buildDropdown(
              value: _selectedRole,
              items: ["All Roles", "School Admin", "Teacher", "Student"],
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(width: 16),
            
            // Status Dropdown
            _buildDropdown(
              value: _selectedStatus,
              items: ["All Status", "Active", "Banned"],
              onChanged: (val) => setState(() => _selectedStatus = val!),
            ),
            const SizedBox(width: 16),
            
            // Export Button
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text("Export"),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textWhite,
                side: const BorderSide(color: AppColors.divider),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const SizedBox(width: 16),
            
            // Add User Button
            ElevatedButton.icon(
              onPressed: () {
                dashboardAsync.whenData((data) {
                  showDialog(
                    context: context,
                    builder: (_) => AddUserDialog(schoolId: data.schoolId),
                  );
                });
              },
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text("Add User"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 2. USERS TABLE
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              const Divider(height: 1, color: AppColors.divider),
              
              usersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(40), 
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(40), 
                  child: Text("Error: $e", style: const TextStyle(color: AppColors.errorRed)),
                ),
                data: (allUsers) {
                  // --- FILTER LOGIC ---
                  final filteredUsers = allUsers.where((user) {
                    final name = (user['full_name'] ?? '').toString().toLowerCase();
                    final email = (user['email'] ?? '').toString().toLowerCase();
                    final role = (user['role'] ?? '').toString().toLowerCase();
                    final isBanned = user['status'] == true; // SQL maps is_banned -> status

                    // 1. Search Filter
                    if (_searchQuery.isNotEmpty) {
                      if (!name.contains(_searchQuery.toLowerCase()) && 
                          !email.contains(_searchQuery.toLowerCase())) {
                        return false;
                      }
                    }

                    // 2. Role Filter
                    if (_selectedRole != "All Roles") {
                      // Map UI string to DB value
                      String requiredRole = _selectedRole.toLowerCase().replaceAll(" ", "_");
                      if (role != requiredRole) return false;
                    }

                    // 3. Status Filter
                    if (_selectedStatus != "All Status") {
                      if (_selectedStatus == "Active" && isBanned) return false;
                      if (_selectedStatus == "Banned" && !isBanned) return false;
                    }

                    return true;
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(40), 
                      child: Text("No users found matching filters.", style: TextStyle(color: AppColors.textWhite54)),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredUsers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (ctx, index) => _UserRow(user: filteredUsers[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSearchField() {
    return SizedBox(
      height: 44,
      child: TextField(
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(color: AppColors.textWhite),
        onChanged: (val) => setState(() => _searchQuery = val), // Updates State
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.backgroundBlack,
          hintText: "Search by name, email...",
          hintStyle: const TextStyle(color: AppColors.textWhite38, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: AppColors.textWhite38, size: 18),
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value, 
    required List<String> items, 
    required Function(String?) onChanged
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: AppColors.surfaceGrey,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54, size: 16),
          style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
          onChanged: onChanged,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _col("USER PROFILE", 3),
          _col("ROLE", 2),
          _col("ASSOCIATIONS", 2),
          _col("PERMISSIONS", 2),
          _col("STATUS", 2),
          _col("", 1), // Actions
        ],
      ),
    );
  }

  Widget _col(String text, int flex) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textWhite38, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
      ),
    );
  }
}

class _UserRow extends ConsumerWidget {
  final Map<String, dynamic> user;
  const _UserRow({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user['full_name'] ?? 'Unknown';
    final email = user['email'] ?? '';
    final role = user['role'] ?? 'student';
    final isBanned = user['status'] == true;
    final isActive = !isBanned;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 1. Profile
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _getRoleColor(role).withValues(alpha: 0.2),
                  child: Text(name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?", 
                    style: TextStyle(color: _getRoleColor(role), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.w500, fontSize: 13)),
                    Text(email, style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          
          // 2. Role Badge
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRoleColor(role).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _getRoleColor(role).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _formatRole(role),
                    style: TextStyle(color: _getRoleColor(role), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // 3. Associations
          const Expanded(
            flex: 2,
            child: Text("Global / 5 Classes", style: TextStyle(color: AppColors.textWhite70, fontSize: 12)),
          ),

          // 4. Permissions
          Expanded(
            flex: 2,
            child: Text(
              role == 'school_admin' ? "Full System Access" : "Limited (Academic)", 
              style: const TextStyle(color: AppColors.textWhite54, fontSize: 12)
            ),
          ),

          // 5. Status Toggle
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Switch(
                  value: isActive,
                  activeThumbColor: AppColors.primaryBlue,
                  activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: AppColors.surfaceLightGrey,
                  inactiveTrackColor: AppColors.surfaceDarkGrey,
                  onChanged: (val) async {
                    final dashboard = await ref.read(dashboardDataProvider.future);
                    await ref.read(usersRepositoryProvider).toggleStatus(
                      userId: user['id'],
                      schoolId: dashboard.schoolId,
                      ban: !val,
                    );
                    // ignore: unused_result
                    ref.refresh(schoolUsersProvider);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  isActive ? "Active" : "Banned",
                  style: TextStyle(color: isActive ? AppColors.successGreen : AppColors.errorRed, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // 6. Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {}, 
                  child: const Text("Edit", style: TextStyle(color: AppColors.primaryBlue, fontSize: 12))
                ),
                const Icon(Icons.more_vert, size: 16, color: AppColors.textWhite54),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'school_admin': return AppColors.errorRed; 
      case 'teacher': return AppColors.successGreen;
      case 'student': return AppColors.textGrey;
      default: return AppColors.primaryBlue;
    }
  }

  String _formatRole(String role) {
    return role.replaceAll('_', ' ').split(' ').map((str) => str.isNotEmpty ? str[0].toUpperCase() + str.substring(1) : str).join(' ');
  }
}