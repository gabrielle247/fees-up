import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/admin_provider.dart';

/// ============================================================================
/// ADMIN OPERATIONS EXAMPLE WIDGET
/// ============================================================================
/// Shows how to use the AdminService for school admin operations including:
/// - Generating teacher access codes
/// - Creating attendance sessions
/// - Marking bulk attendance
/// - Managing campaigns
/// ============================================================================

class AdminOperationsExample extends ConsumerWidget {
  const AdminOperationsExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final context_ = ref.watch(adminContextProvider);
    final accessCodes = ref.watch(accessCodesProvider);
    final dashboard = ref.watch(schoolDashboardProvider);
    final campaigns = ref.watch(schoolCampaignsProvider);
    final sessions = ref.watch(attendanceSessionsProvider);

    if (!context_.isInitialized) {
      return const Scaffold(
        body: Center(child: Text('Admin context not initialized')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Operations')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Generate Teacher Access Code
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '1. Generate Teacher Access Code',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create a one-time access code for a teacher to delegate attendance marking or campaign creation.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _generateAccessCode(context, ref),
                      child: const Text('Generate Access Code'),
                    ),
                    const SizedBox(height: 16),
                    if (accessCodes.when(
                      data: (codes) => codes.isNotEmpty,
                      loading: () => false,
                      error: (_, _) => false,
                    ))
                      accessCodes.when(
                        data: (codes) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Active Codes:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...codes.map((code) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Code: ${code['access_code']}',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text('Type: ${code['permission_type']}'),
                                        Text(
                                            'Expires: ${code['expires_at']}'),
                                      ],
                                    ),
                                  ),
                                )),
                          ],
                        ),
                        loading: () =>
                            const CircularProgressIndicator(),
                        error: (error, _) => Text('Error: $error'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 2: Attendance Session Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '2. Attendance Session Management',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Create and manage attendance sessions with teacher approval.',
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _createAttendanceSession(context, ref),
                      child: const Text('Create Attendance Session'),
                    ),
                    const SizedBox(height: 16),
                    sessions.when(
                      data: (sessionsList) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Sessions: ${sessionsList.length}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...sessionsList.map((session) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Session: ${session['id']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12)),
                                      Text(
                                          'Class: ${session['class_id']}'),
                                      Text(
                                          'Date: ${session['session_date']}'),
                                      Text(
                                          'Confirmed: ${session['is_confirmed_by_teacher'] == 1 ? 'Yes' : 'No'}',
                                          style: TextStyle(
                                            color: session['is_confirmed_by_teacher'] == 1
                                                ? Colors.green
                                                : Colors.orange,
                                          )),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 3: School Dashboard
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '3. School Dashboard',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    dashboard.when(
                      data: (data) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DashboardMetric('Students', data['studentCount']?.toString() ?? '0'),
                          _DashboardMetric('Total Revenue', 'Ksh ${data['totalRevenue']?.toStringAsFixed(2) ?? '0'}'),
                          _DashboardMetric('Outstanding Bills', 'Ksh ${data['outstandingBills']?.toStringAsFixed(2) ?? '0'}'),
                          _DashboardMetric('Active Campaigns', data['activeCampaigns']?.toString() ?? '0'),
                          _DashboardMetric('Pending Sessions', data['pendingAttendanceSessions']?.toString() ?? '0'),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 4: Campaigns
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '4. Campaigns',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _createCampaign(context, ref),
                      child: const Text('Create Campaign'),
                    ),
                    const SizedBox(height: 16),
                    campaigns.when(
                      data: (campaignList) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Campaigns: ${campaignList.length}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ...campaignList.map((campaign) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('${campaign['title']}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          'Goal: Ksh ${campaign['goal_amount']}'),
                                      Text('Status: ${campaign['status']}'),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (error, _) => Text('Error: $error'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generateAccessCode(BuildContext context, WidgetRef ref) {
    final adminService = ref.read(adminServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Show dialog to select teacher and permission type
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Access Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Teacher ID',
                hintText: 'e.g., TCH-abc123',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButton<String>(
              items: const [
                DropdownMenuItem(value: 'attendance', child: Text('Attendance Only')),
                DropdownMenuItem(value: 'campaigns', child: Text('Campaigns Only')),
                DropdownMenuItem(value: 'both', child: Text('Both')),
              ],
              onChanged: (value) {},
              hint: const Text('Permission Type'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final code = await adminService.generateTeacherAccessCode(
                  teacherId: 'TCH-demo',
                  permissionType: 'both',
                  expiresIn: const Duration(hours: 2),
                );
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Code Generated: $code')),
                );
                Navigator.pop(ctx);
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  void _createAttendanceSession(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Creating attendance session...')),
    );
  }

  void _createCampaign(BuildContext context, WidgetRef ref) {
    final adminService = ref.read(adminServiceProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Campaign'),
        content: const TextField(
          decoration: InputDecoration(
            labelText: 'Campaign Title',
            hintText: 'e.g., Sports Equipment Fund',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final id = await adminService.createCampaign(
                  title: 'Demo Campaign',
                  goalAmount: 5000,
                );
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Campaign Created: $id')),
                );
                Navigator.pop(ctx);
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  final String label;
  final String value;

  const _DashboardMetric(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
