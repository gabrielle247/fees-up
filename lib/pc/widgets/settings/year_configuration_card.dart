import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../../data/providers/year_configuration_provider.dart';

class YearConfigurationCard extends ConsumerStatefulWidget {
  final String yearId;
  const YearConfigurationCard({super.key, required this.yearId});

  @override
  ConsumerState<YearConfigurationCard> createState() =>
      _YearConfigurationCardState();
}

class _YearConfigurationCardState extends ConsumerState<YearConfigurationCard> {
  final _labelController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _hydrated = false;
  bool _saving = false;
  bool _active = false;
  List<Map<String, dynamic>> _terms = [];
  List<Map<String, dynamic>> _months = [];
  Map<String, dynamic>? _yearData;
  final Set<String> _removedTermIds = {};
  bool _modified = false;

  @override
  void initState() {
    super.initState();
    // Track changes to text fields
    _labelController.addListener(_onContentChanged);
    _startDateController.addListener(_onContentChanged);
    _endDateController.addListener(_onContentChanged);
    _descriptionController.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    if (_hydrated) {
      setState(() => _modified = true);
    }
  }

  @override
  void dispose() {
    _labelController.removeListener(_onContentChanged);
    _startDateController.removeListener(_onContentChanged);
    _endDateController.removeListener(_onContentChanged);
    _descriptionController.removeListener(_onContentChanged);
    _labelController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => _loadingCard(),
      error: (err, _) => _errorCard('Dashboard error: $err'),
      data: (dashboard) {
        if (dashboard.schoolId.isEmpty) {
          return _errorCard('No school context');
        }

        // Load year data from repository via provider
        final yearDataAsync = ref.watch(
          loadYearProvider((widget.yearId, dashboard.schoolId)),
        );

        return yearDataAsync.when(
          loading: () => _loadingCard(),
          error: (err, _) => _errorCard('Failed to load year: $err'),
          data: (yearData) {
            if (yearData == null) {
              return _errorCard('Year not found');
            }

            // Hydrate form fields if needed
            if (!_hydrated) {
              _hydrateFromData(yearData);
            }

            return _buildContent(context, dashboard.schoolId);
          },
        );
      },
    );
  }

  /// Populate form fields from loaded year data
  void _hydrateFromData(Map<String, dynamic> yearData) {
    final year = yearData['year'] as Map<String, dynamic>;
    final terms = yearData['terms'] as List<dynamic>;
    final months = yearData['months'] as List<dynamic>;

    _labelController.text = year['year_label'] as String? ?? '';
    _startDateController.text = year['start_date'] as String? ?? '';
    _endDateController.text = year['end_date'] as String? ?? '';
    _active = (year['active'] as int? ?? 0) == 1;

    final desc = year['description'] as String? ?? '';
    _descriptionController.text =
        (desc.isNotEmpty && terms.isEmpty) ? desc : '';

    _terms = terms
        .map((t) => {
              'id': t['id'],
              'name': (t['name'] ?? '').toString(),
              'start_date': (t['start_date'] ?? '').toString(),
              'end_date': (t['end_date'] ?? '').toString(),
            })
        .toList();

    _months = months
        .map((m) => {
              'id': m['id'],
              'name': (m['name'] ?? '').toString(),
              'month_index': m['month_index'],
              'start_date': (m['start_date'] ?? '').toString(),
              'end_date': (m['end_date'] ?? '').toString(),
              'is_billable': m['is_billable'] as bool? ?? false,
              'term_id': m['term_id'],
            })
        .toList();

    _yearData = year;
    _removedTermIds.clear();
    _modified = false;
    _hydrated = true;
  }

  Widget _buildContent(BuildContext context, String schoolId) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryBlue, width: 1.5),
      ),
      child: Column(
        children: [
          // 1. Config Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Configure: ${widget.yearId}",
                        style: const TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text("Editing details, terms, and billing settings.",
                        style: TextStyle(
                            color: AppColors.textWhite54, fontSize: 13)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _active
                        ? AppColors.successGreen
                        : AppColors.textWhite54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(_active ? "Active" : "Inactive",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          // 2. Form Body
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Label & Dates
                Row(
                  children: [
                    Expanded(child: _buildInput("Label", _labelController)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildDateInput(
                            "Start Date", _startDateController,
                            isStartDate: true, schoolId: schoolId)),
                    const SizedBox(width: 24),
                    Expanded(
                        child: _buildDateInput("End Date", _endDateController,
                            isStartDate: false, schoolId: schoolId)),
                  ],
                ),
                const SizedBox(height: 24),

                // Row 2: Description & Active Toggle
                Row(
                  children: [
                    Expanded(
                      child: _buildInput("Description", _descriptionController,
                          helper:
                              "Brief description for administrative reference."),
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Active Year",
                            style: TextStyle(
                                color: AppColors.textWhite70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Switch(
                          value: _active,
                          onChanged: (v) => setState(() {
                            _active = v;
                            _modified = true;
                          }),
                          activeThumbColor: AppColors.successGreen,
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 40),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 32),

                // 3. Terms Management Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.date_range,
                            color: AppColors.textWhite70, size: 20),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Terms Management",
                                style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                "Define academic terms (Semesters/Trimesters) for this year.",
                                style: TextStyle(
                                    color: AppColors.textWhite54,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: _addTerm,
                      icon: const Icon(Icons.add, size: 14),
                      label: const Text("Add Term"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textWhite,
                        side: const BorderSide(color: AppColors.divider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Dynamic Terms
                if (_terms.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text(
                        'No terms defined. Click "Add Term" to create one.',
                        style: TextStyle(
                            color: AppColors.textWhite54, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._terms.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final term = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: idx < _terms.length - 1 ? 16 : 0),
                      child: _buildTermRow(idx, term),
                    );
                  }),

                const SizedBox(height: 32),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 24),

                // 4. Months & Billability
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.calendar_month,
                            color: AppColors.textWhite70, size: 20),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Months & Billability",
                                style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                "Toggle which months are billable for this year.",
                                style: TextStyle(
                                    color: AppColors.textWhite54,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: _months.isEmpty
                          ? null
                          : () {
                              setState(() {
                                final shouldEnable = _months
                                    .any((m) => m['is_billable'] == false);
                                for (final m in _months) {
                                  m['is_billable'] = shouldEnable;
                                }
                              });
                            },
                      child: const Text('Toggle All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                if (_months.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceGrey.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text(
                        'No months found for this year.',
                        style: TextStyle(
                            color: AppColors.textWhite54, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ..._months.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final month = entry.value;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: idx < _months.length - 1 ? 12 : 0),
                      child: _buildMonthRow(month),
                    );
                  }),

                const SizedBox(height: 32),

                // Unsaved changes warning
                if (_modified)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.warningOrange.withValues(alpha: 0.15),
                      border:
                          Border.all(color: AppColors.warningOrange, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_outlined,
                            color: AppColors.warningOrange, size: 18),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You have unsaved changes. Click "Save Changes" to persist them.',
                            style: TextStyle(
                              color: AppColors.warningOrange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Save/Reset Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _hydrated && _yearData != null
                          ? () {
                              // Reset form to loaded state
                              if (_yearData != null) {
                                _hydrateFromData({
                                  'year': _yearData!,
                                  'terms': _terms,
                                  'months': _months,
                                });
                              }
                            }
                          : null,
                      child: const Text('Reset'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed:
                          _saving ? null : () => _onSave(context, schoolId),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save Changes'),
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

  void _addTerm() {
    setState(() {
      _terms.add({
        'id': null, // Will be generated by repository
        'name': 'Term ${_terms.length + 1}',
        'start_date': '',
        'end_date': '',
      });
      _modified = true;
    });
  }

  void _removeTerm(int index) {
    setState(() {
      final removed = _terms.removeAt(index);
      final removedId = removed['id']?.toString();
      if (removedId != null && removedId.isNotEmpty) {
        _removedTermIds.add(removedId);
        for (final m in _months) {
          if (m['term_id']?.toString() == removedId) {
            m['term_id'] = null;
          }
        }
      }
    });
  }

  void _updateTerm(int index, String field, String value) {
    setState(() {
      _terms[index][field] = value;
      _modified = true;
    });
  }

  void _toggleMonthBillable(dynamic monthId, bool value) {
    setState(() {
      for (final m in _months) {
        if (m['id'] == monthId) {
          m['is_billable'] = value;
          _modified = true;
          break;
        }
      }
    });
  }

  void _setMonthTerm(dynamic monthId, String? termId) {
    setState(() {
      for (final m in _months) {
        if (m['id'] == monthId) {
          m['term_id'] = termId;
          _modified = true;
          break;
        }
      }
    });
  }

  Future<void> _onSave(BuildContext context, String schoolId) async {
    setState(() => _saving = true);

    try {
      // Use the repository provider to save
      await ref.read(saveYearProvider.notifier).saveYear(
            yearId: widget.yearId,
            schoolId: schoolId,
            yearLabel: _labelController.text.trim(),
            startDate: _startDateController.text.trim(),
            endDate: _endDateController.text.trim(),
            description: _descriptionController.text.trim(),
            active: _active,
            terms: _terms,
            removedTermIds: _removedTermIds.toList(),
            months: _months,
          );

      _removedTermIds.clear();

      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ School year updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _modified = false;
        });
      }
    }
  }

  Widget _buildInput(String label, TextEditingController controller,
      {IconData? icon, String? helper, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceGrey,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: icon != null
                ? Icon(icon, color: AppColors.textWhite54, size: 18)
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper,
              style:
                  const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
        ]
      ],
    );
  }

  Widget _buildTermRow(int index, Map<String, dynamic> term) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
              flex: 4,
              child: _buildSubInput("Term Name", term['name'] ?? '',
                  onChanged: (v) => _updateTerm(index, 'name', v))),
          const SizedBox(width: 16),
          Expanded(
              flex: 3,
              child: _buildSubInput("Start Date", term['start_date'] ?? '',
                  icon: Icons.calendar_today,
                  onChanged: (v) => _updateTerm(index, 'start_date', v))),
          const SizedBox(width: 16),
          Expanded(
              flex: 3,
              child: _buildSubInput("End Date", term['end_date'] ?? '',
                  icon: Icons.calendar_today,
                  onChanged: (v) => _updateTerm(index, 'end_date', v))),
          const SizedBox(width: 16),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IconButton(
              onPressed: () => _removeTerm(index),
              icon: const Icon(Icons.delete_outline,
                  color: AppColors.textWhite54),
              tooltip: "Remove Term",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRow(Map<String, dynamic> month) {
    final bool billable = month['is_billable'] as bool? ?? false;
    final name = (month['name'] ?? '').toString();
    final range = _formatRange(
      (month['start_date'] ?? '').toString(),
      (month['end_date'] ?? '').toString(),
    );
    final rawTermId = (month['term_id']?.toString().isNotEmpty ?? false)
        ? month['term_id'].toString()
        : null;

    // Ensure the selected term exists in the list, otherwise use null
    final selectedTermId =
        rawTermId != null && _terms.any((t) => t['id']?.toString() == rawTermId)
            ? rawTermId
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: AppColors.textWhite,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(height: 2),
                Text(range,
                    style: const TextStyle(
                        color: AppColors.textWhite54, fontSize: 11)),
                if (_terms.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Text('Term',
                          style: TextStyle(
                              color: AppColors.textWhite54, fontSize: 12)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundBlack,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: selectedTermId,
                            dropdownColor: AppColors.surfaceGrey,
                            icon: const Icon(Icons.keyboard_arrow_down,
                                size: 14, color: AppColors.textWhite54),
                            style: const TextStyle(
                                color: AppColors.textWhite, fontSize: 12),
                            items: [
                              const DropdownMenuItem<String?>(
                                  value: null, child: Text('Unassigned')),
                              ..._terms.map(
                                (t) => DropdownMenuItem<String?>(
                                  value: t['id']?.toString(),
                                  child: Text((t['name'] ?? '').toString()),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                _setMonthTerm(month['id'], val?.trim()),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: billable,
            onChanged: (v) => _toggleMonthBillable(month['id'], v),
            activeThumbColor: AppColors.primaryBlue,
          ),
          const SizedBox(width: 8),
          Text(
            billable ? 'Billable' : 'Not billable',
            style: TextStyle(
              color: billable ? AppColors.textWhite : AppColors.textWhite54,
              fontSize: 12,
              fontWeight: billable ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubInput(String label, String value,
      {IconData? icon, required ValueChanged<String> onChanged}) {
    final controller = TextEditingController(text: value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textWhite38, fontSize: 11)),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: TextFormField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.backgroundBlack,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              suffixIcon: icon != null
                  ? Icon(icon, color: AppColors.textWhite38, size: 16)
                  : null,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.divider)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.divider)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.textWhite38)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput(String label, TextEditingController controller,
      {required bool isStartDate, required String schoolId}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceGrey,
            contentPadding: const EdgeInsets.all(16),
            suffixIcon: GestureDetector(
              onTap: () => _pickDate(isStartDate, controller),
              child: const Icon(Icons.calendar_today,
                  color: AppColors.textWhite54, size: 18),
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primaryBlue)),
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate(
      bool isStartDate, TextEditingController controller) async {
    try {
      final now = DateTime.now();
      final initialDate = controller.text.isNotEmpty
          ? DateTime.tryParse(controller.text) ?? now
          : now;

      final picked = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBlue,
              surface: AppColors.surfaceGrey,
            ),
          ),
          child: child!,
        ),
      );

      if (picked == null) return;

      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      setState(() {
        if (isStartDate) {
          _startDateController.text = formatted;
          final endDate = _endDateController.text.isNotEmpty
              ? DateTime.tryParse(_endDateController.text)
              : null;
          if (endDate != null && picked.isAfter(endDate)) {
            final newEndDate = DateTime(picked.year, 12, 31);
            _endDateController.text =
                DateFormat('yyyy-MM-dd').format(newEndDate);
            _regenerateMonthDates();
          }
        } else {
          final startDate = _startDateController.text.isNotEmpty
              ? DateTime.tryParse(_startDateController.text)
              : null;
          if (startDate != null && picked.isBefore(startDate)) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('End date cannot be before start date')),
            );
            return;
          }
          _endDateController.text = formatted;
          _regenerateMonthDates();
        }
      });
    } catch (e) {
      debugPrint('⚠️ Error picking date: $e');
    }
  }

  void _regenerateMonthDates() {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
      return;
    }

    try {
      final start = DateTime.tryParse(_startDateController.text);
      final end = DateTime.tryParse(_endDateController.text);

      if (start == null || end == null || start.isAfter(end)) return;

      setState(() {
        for (int i = 0; i < _months.length; i++) {
          final month = _months[i];
          final monthIndex = month['month_index'] as int? ?? (i + 1);

          final monthStart = DateTime(start.year, monthIndex, 1);
          final monthEnd = DateTime(start.year, monthIndex + 1, 0);

          if (monthStart.isBefore(end) && monthEnd.isAfter(start)) {
            month['start_date'] = DateFormat('yyyy-MM-dd')
                .format(monthStart.isBefore(start) ? start : monthStart);
            month['end_date'] = DateFormat('yyyy-MM-dd')
                .format(monthEnd.isAfter(end) ? end : monthEnd);
          }
        }
      });
    } catch (e) {
      debugPrint('⚠️ Error regenerating month dates: $e');
    }
  }

  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  String _formatRange(String start, String end) {
    if (start.isEmpty && end.isEmpty) return '';
    if (start.isEmpty) return end;
    if (end.isEmpty) return start;
    return '$start → $end';
  }

  Widget _errorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
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
