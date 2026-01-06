import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/providers/dashboard_provider.dart';
import '../../../../data/providers/invoices_provider.dart';
import '../../../../data/services/database_service.dart';

class InvoicesTable extends ConsumerStatefulWidget {
  const InvoicesTable({super.key});

  @override
  ConsumerState<InvoicesTable> createState() => _InvoicesTableState();
}

class _InvoicesTableState extends ConsumerState<InvoicesTable> {
  // Filters & Search
  String _searchQuery = '';
  String _statusFilter = 'All';
  DateTime? _startDate;
  DateTime? _endDate;

  // State
  String _sortColumn = 'created_at';
  bool _sortAscending = false;

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (dashboardData) {
        final schoolId = dashboardData.schoolId;
        final invoicesAsync = ref.watch(invoicesProvider(schoolId));

        return Column(
          children: [
            // --- FILTER BAR ---
            _buildFilterBar(schoolId),
            const SizedBox(height: 16),

            // --- DATA TABLE ---
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  // Header Row
                  _buildTableHeader(),
                  const Divider(height: 1, color: AppColors.divider),

                  // Data Rows
                  invoicesAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primaryBlue)),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                          child: Text('Error loading invoices: $error',
                              style:
                                  const TextStyle(color: AppColors.errorRed))),
                    ),
                    data: (invoices) {
                      // Apply filters safely
                      final filtered = _applyFilters(invoices);

                      if (filtered.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                              child: Text('No invoices match your filters',
                                  style:
                                      TextStyle(color: AppColors.textWhite54))),
                        );
                      }

                      return Column(
                        children: _buildInvoiceRows(filtered),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Apply search and filters to invoices safely
  List<Map<String, dynamic>> _applyFilters(
      List<Map<String, dynamic>> invoices) {
    // --- FIX START: Create a Mutable Copy ---
    // This breaks the link to the read-only ResultSet so we can sort/filter
    var filtered = List<Map<String, dynamic>>.from(invoices);
    // --- FIX END ---

    // 1. Status filter
    if (_statusFilter != 'All') {
      filtered = filtered.where((inv) {
        final isPaidVal = inv['is_paid'];
        // Handle boolean or int (0/1) from DB
        final isPaid = isPaidVal == 1 || isPaidVal == true;

        if (_statusFilter == 'Paid') return isPaid;
        if (_statusFilter == 'Unpaid') return !isPaid;
        return true;
      }).toList();
    }

    // 2. Date range filter
    if (_startDate != null || _endDate != null) {
      filtered = filtered.where((inv) {
        final createdStr = inv['created_at']?.toString();
        if (createdStr == null) return false;
        final date = DateTime.tryParse(createdStr);
        if (date == null) return false;

        // Use strict boundaries for dates
        if (_startDate != null && date.isBefore(_startDate!)) return false;
        if (_endDate != null && date.isAfter(_endDate!)) return false;
        return true;
      }).toList();
    }

    // 3. Search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((inv) {
        final title = (inv['title']?.toString() ?? '').toLowerCase();
        final studentId = (inv['student_id']?.toString() ?? '').toLowerCase();
        return title.contains(query) || studentId.contains(query);
      }).toList();
    }

    // 4. Sort
    filtered.sort((a, b) {
      var aVal = a[_sortColumn];
      var bVal = b[_sortColumn];

      // Null handling for sort
      if (aVal == null && bVal == null) return 0;
      if (aVal == null) return 1;
      if (bVal == null) return -1;

      int result = 0;
      // Compare as strings or numbers safely
      if (aVal is num && bVal is num) {
        result = aVal.compareTo(bVal);
      } else {
        result = aVal.toString().compareTo(bVal.toString());
      }

      return _sortAscending ? result : -result;
    });

    return filtered;
  }

  Widget _buildFilterBar(String schoolId) {
    return Row(
      children: [
        // --- Search Bar ---
        Expanded(
          child: SizedBox(
            height: 44,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: AppColors.surfaceGrey,
                hintText: "Search...",
                hintStyle:
                    const TextStyle(color: AppColors.textWhite38, fontSize: 13),
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textWhite38, size: 18),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primaryBlue),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Status Dropdown
        _buildStatusDropdown(),
        const SizedBox(width: 12),

        // Date Range Picker
        _buildDateRangeButton(),
        const SizedBox(width: 12),

        // Clear Filters Button (Only shows when active)
        if (_searchQuery.isNotEmpty ||
            _statusFilter != 'All' ||
            _startDate != null ||
            _endDate != null)
          GestureDetector(
            onTap: () {
              setState(() {
                _searchQuery = '';
                _statusFilter = 'All';
                _startDate = null;
                _endDate = null;
              });
            },
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.errorRed.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.errorRed),
              ),
              child: const Row(
                children: [
                  Icon(Icons.clear, color: AppColors.errorRed, size: 16),
                  SizedBox(width: 8),
                  Text("Clear",
                      style:
                          TextStyle(color: AppColors.errorRed, fontSize: 13)),
                ],
              ),
            ),
          )
        else
          const SizedBox(),
        const SizedBox(width: 12),

        // Export Button
        GestureDetector(
          onTap: () => _exportToCSV(schoolId),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.download, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text("Export CSV",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    final statuses = ['All', 'Paid', 'Unpaid'];

    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _statusFilter = value),
      itemBuilder: (context) => statuses
          .map((status) => PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    if (_statusFilter == status)
                      const Icon(Icons.check,
                          color: AppColors.primaryBlue, size: 16)
                    else
                      const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(status),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Text("Status: $_statusFilter",
                style:
                    const TextStyle(color: AppColors.textWhite, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textWhite54, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeButton() {
    final hasDateFilter = _startDate != null || _endDate != null;
    final dateLabel = hasDateFilter
        ? '${DateFormat('MM/dd').format(_startDate!)} - ${DateFormat('MM/dd').format(_endDate!)}'
        : 'Select Date';

    return GestureDetector(
      onTap: () async {
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: hasDateFilter
              ? DateTimeRange(start: _startDate!, end: _endDate!)
              : null,
        );

        if (picked != null) {
          setState(() {
            _startDate = picked.start;
            _endDate = picked.end;
          });
        }
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasDateFilter ? AppColors.primaryBlue : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: hasDateFilter
                    ? AppColors.primaryBlue
                    : AppColors.textWhite54,
                size: 16),
            const SizedBox(width: 8),
            Text(dateLabel,
                style: TextStyle(
                    color: hasDateFilter
                        ? AppColors.primaryBlue
                        : AppColors.textWhite,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildSortableCol("INVOICE", 'title', 2),
          _buildSortableCol("STUDENT", 'student_id', 2),
          _buildSortableCol("AMOUNT", 'total_amount', 1),
          _buildSortableCol("DUE DATE", 'billing_cycle_end', 2),
          _buildSortableCol("STATUS", 'is_paid', 1),
          _col("ACTIONS", 1, align: TextAlign.end),
        ],
      ),
    );
  }

  Widget _buildSortableCol(String text, String column, int flex) {
    final isActive = _sortColumn == column;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (_sortColumn == column) {
              _sortAscending = !_sortAscending;
            } else {
              _sortColumn = column;
              _sortAscending = false;
            }
          });
        },
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                  color:
                      isActive ? AppColors.primaryBlue : AppColors.textWhite38,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8),
            ),
            if (isActive)
              Icon(
                _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: AppColors.primaryBlue,
                size: 12,
              )
          ],
        ),
      ),
    );
  }

  Widget _col(String text, int flex, {TextAlign align = TextAlign.start}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
            color: AppColors.textWhite38,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8),
      ),
    );
  }

  List<Widget> _buildInvoiceRows(List<Map<String, dynamic>> invoices) {
    return invoices.map((invoice) {
      return Column(
        children: [
          _buildInvoiceRowFromMap(invoice),
          const Divider(height: 1, color: AppColors.divider),
        ],
      );
    }).toList();
  }

  Widget _buildInvoiceRowFromMap(Map<String, dynamic> invoice) {
    final title = invoice['title']?.toString() ?? 'Invoice';
    final studentId = invoice['student_id']?.toString() ?? 'Unknown';
    // Safer double parsing
    final totalAmount =
        double.tryParse(invoice['total_amount']?.toString() ?? '0') ?? 0.0;
    final dueDateStr = invoice['billing_cycle_end']?.toString() ?? '';

    // Check for boolean or 0/1 integer
    final isPaidVal = invoice['is_paid'];
    final isPaid = isPaidVal == 1 || isPaidVal == true;

    final invoiceId = invoice['id']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Invoice Title
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                  color: AppColors.textWhite, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Student ID
          Expanded(
            flex: 2,
            child: Text(
              studentId,
              style: const TextStyle(color: AppColors.textWhite70),
            ),
          ),
          // Amount
          Expanded(
            flex: 1,
            child: Text(
              '\$${totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                  color: AppColors.textWhite, fontWeight: FontWeight.bold),
            ),
          ),
          // Due Date
          Expanded(
            flex: 2,
            child: Text(
              dueDateStr.isNotEmpty
                  ? DateFormat('MM/dd/yyyy')
                      .format(DateTime.tryParse(dueDateStr) ?? DateTime.now())
                  : 'N/A',
              style: TextStyle(
                color: isPaid ? AppColors.textWhite70 : AppColors.errorRed,
              ),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid
                    ? AppColors.successGreen.withAlpha(51)
                    : AppColors.warningOrange.withAlpha(51),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isPaid ? 'Paid' : 'Unpaid',
                style: TextStyle(
                  color:
                      isPaid ? AppColors.successGreen : AppColors.warningOrange,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility,
                      size: 18, color: AppColors.textWhite54),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Viewing invoice: $invoiceId'),
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert,
                      size: 18, color: AppColors.textWhite54),
                  onPressed: () => _showInvoiceActions(context, invoice),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showInvoiceActions(BuildContext context, Map<String, dynamic> invoice) {
    final invoiceId = invoice['id']?.toString() ?? '';
    final isPaidVal = invoice['is_paid'];
    final isPaid = isPaidVal == 1 || isPaidVal == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceGrey,
        title: const Text('Invoice Actions',
            style: TextStyle(color: AppColors.textWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('View Details',
                  style: TextStyle(color: AppColors.textWhite)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Viewing invoice: $invoiceId'),
                    backgroundColor: AppColors.primaryBlue,
                  ),
                );
              },
            ),
            if (!isPaid)
              ListTile(
                title: const Text('Mark as Paid',
                    style: TextStyle(color: AppColors.successGreen)),
                onTap: () {
                  Navigator.pop(context);
                  _markInvoiceAsPaid(invoiceId);
                },
              ),
            ListTile(
              title: const Text('Delete',
                  style: TextStyle(color: AppColors.errorRed)),
              onTap: () {
                Navigator.pop(context);
                _deleteInvoice(invoiceId);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markInvoiceAsPaid(String invoiceId) async {
    try {
      final db = DatabaseService();
      await db.update('bills', invoiceId, {
        'is_paid': 1,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice marked as paid'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteInvoice(String invoiceId) async {
    try {
      final db = DatabaseService();
      await db.delete('bills', invoiceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invoice deleted'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _exportToCSV(String schoolId) async {
    try {
      final db = DatabaseService();
      final invoices = await db.select(
        'SELECT * FROM bills WHERE school_id = ? ORDER BY created_at DESC',
        [schoolId],
      );

      if (invoices.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No invoices to export'),
              backgroundColor: AppColors.warningOrange,
            ),
          );
        }
        return;
      }
      // Placeholder for actual CSV logic
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exporting CSV...'),
            backgroundColor: AppColors.primaryBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }
}
