import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/services/database_service.dart';
import '../../../data/providers/dashboard_provider.dart';

class AuditTrailView extends ConsumerStatefulWidget {
  const AuditTrailView({super.key});

  @override
  ConsumerState<AuditTrailView> createState() => _AuditTrailViewState();
}

class _AuditTrailViewState extends ConsumerState<AuditTrailView> {
  final _db = DatabaseService();
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedAction = 'All Actions';

  final List<String> _actionFilters = [
    'All Actions',
    'Invoice Created',
    'Payment Recorded',
    'Config Updated',
    'Bill Status Changed',
  ];

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => _buildLoading(),
      error: (err, _) => _buildError('Failed to load school: $err'),
      data: (dashboard) {
        if (dashboard.schoolId.isEmpty) {
          return _buildError('No school context');
        }
        return _buildContent(context, dashboard.schoolId);
      },
    );
  }

  Widget _buildContent(BuildContext context, String schoolId) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Audit Trail',
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.history, color: Colors.amber, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Read-only log of billing system changes',
            style: TextStyle(color: AppColors.textWhite54, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Filters
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  label: _selectedAction,
                  items: _actionFilters,
                  onChanged: (value) =>
                      setState(() => _selectedAction = value ?? 'All Actions'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: _buildDateFilterButton(
                  label: _startDate == null
                      ? 'From Date'
                      : DateFormat('MMM d').format(_startDate!),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _startDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 150,
                child: _buildDateFilterButton(
                  label: _endDate == null
                      ? 'To Date'
                      : DateFormat('MMM d').format(_endDate!),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: _startDate ??
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _endDate = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _selectedAction = 'All Actions';
                  });
                },
                child: const Text('Clear',
                    style: TextStyle(color: AppColors.primaryBlue)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Audit Log Table
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchAuditLog(schoolId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading audit log: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  );
                }

                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No audit log entries found',
                      style: TextStyle(color: AppColors.textWhite54),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: logs.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: AppColors.divider),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return _buildAuditLogRow(log);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditLogRow(Map<String, dynamic> log) {
    final action = log['action'] ?? 'Unknown';
    final description = log['description'] ?? '';
    final changedBy = log['changed_by'] ?? 'System';
    final timestamp = log['created_at'] ?? '';
    final details = log['details'] ?? '';

    Color actionColor = AppColors.textWhite54;
    IconData actionIcon = Icons.info_outline;

    if (action.contains('Created')) {
      actionColor = AppColors.successGreen;
      actionIcon = Icons.add_circle_outline;
    } else if (action.contains('Updated') || action.contains('Changed')) {
      actionColor = AppColors.primaryBlue;
      actionIcon = Icons.edit_note;
    } else if (action.contains('Deleted')) {
      actionColor = AppColors.errorRed;
      actionIcon = Icons.delete_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(actionIcon, color: actionColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: TextStyle(
                    color: actionColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundBlack,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      details,
                      style: const TextStyle(
                        color: AppColors.textWhite54,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'by $changedBy',
                      style: const TextStyle(
                        color: AppColors.textWhite54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatTimestamp(timestamp),
                      style: const TextStyle(
                        color: AppColors.textWhite38,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textWhite54, size: 16),
          ],
        ),
      ),
      itemBuilder: (context) => items
          .map((item) => PopupMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  Widget _buildDateFilterButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textWhite,
                fontSize: 13,
              ),
            ),
            const Icon(Icons.calendar_today,
                color: AppColors.textWhite54, size: 16),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAuditLog(String schoolId) async {
    // Note: This query assumes a billing_audit_log table exists
    // For now, we'll return sample data structure
    // In production, this should be an RPC call to Supabase
    try {
      var query = 'SELECT * FROM billing_audit_log WHERE school_id = ?';
      var params = [schoolId];

      if (_selectedAction != 'All Actions') {
        query += ' AND action = ?';
        params.add(_selectedAction);
      }

      if (_startDate != null) {
        query += ' AND created_at >= ?';
        params.add(_startDate!.toIso8601String());
      }

      if (_endDate != null) {
        query += ' AND created_at <= ?';
        params.add(_endDate!.add(const Duration(days: 1)).toIso8601String());
      }

      query += ' ORDER BY created_at DESC LIMIT 500';

      final result = await _db.db.getAll(query, params);
      return result;
    } catch (e) {
      debugPrint('Error fetching audit log: $e');
      return [];
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('MMM d, HH:mm').format(dt);
    } catch (_) {
      return 'Unknown';
    }
  }

  Widget _buildLoading() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningOrange),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.warningOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.warningOrange),
            ),
          ),
        ],
      ),
    );
  }
}
