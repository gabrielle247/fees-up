import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// -----------------------------------------------------------------------------
// IMPORTS
// -----------------------------------------------------------------------------
import 'package:fees_up/data/constants/app_colors.dart';

class FeeStructuresScreen extends StatefulWidget {
  const FeeStructuresScreen({super.key});

  @override
  State<FeeStructuresScreen> createState() => _FeeStructuresScreenState();
}

class _FeeStructuresScreenState extends State<FeeStructuresScreen> {
  // ---------------------------------------------------------------------------
  // MOCK DATA
  // ---------------------------------------------------------------------------
  final List<String> _categories = ['Tuition', 'Boarding', 'Transport', 'Levy'];

  List<Map<String, dynamic>> _fees = [
    {
      'id': '1',
      'name': 'Form 1 Tuition',
      'category': 'Tuition',
      'amount': 450.00,
      'currency': 'USD',
      'recurrence': 'Termly',
      'target_grade': 'Form 1',
      'is_active': true,
      'students_count': 45, // Number of students this applies to
    },
    {
      'id': '2',
      'name': 'Exam Levy',
      'category': 'Levy',
      'amount': 25.00,
      'currency': 'USD',
      'recurrence': 'Termly',
      'target_grade': 'All',
      'is_active': true,
      'students_count': 1240,
    },
    {
      'id': '3',
      'name': 'School Bus (Zone A)',
      'category': 'Transport',
      'amount': 80.00,
      'currency': 'USD',
      'recurrence': 'Monthly',
      'target_grade': 'All',
      'is_active': false,
      'students_count': 0,
    },
  ];

  String _selectedCategoryFilter = 'All';

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------
  void _openAddFeeModal({Map<String, dynamic>? existingFee}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceDarkGrey,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _FeeEditor(
          fee: existingFee,
          categories: _categories,
          onSave: (newFee) {
            setState(() {
              if (existingFee != null) {
                final index = _fees.indexWhere((f) => f['id'] == existingFee['id']);
                _fees[index] = newFee;
              } else {
                _fees.insert(0, newFee);
              }
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _confirmInvoicing(Map<String, dynamic> fee) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDarkGrey,
        title: const Text('Generate Invoices?', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will create pending invoices for ${fee['students_count']} students in ${fee['target_grade']}.',
              style: const TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 12),
            _DetailRow(label: 'Fee:', value: fee['name']),
            _DetailRow(label: 'Amount:', value: '\$${fee['amount']}'),
            _DetailRow(label: 'Total Value:', value: '\$${(fee['amount'] * fee['students_count']).toStringAsFixed(2)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            onPressed: () {
              // TODO: Implement Bulk Insert
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Successfully generated invoices for ${fee['name']}'),
                ),
              );
            },
            child: const Text('Confirm & Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // UI BUILDER
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final displayFees = _selectedCategoryFilter == 'All'
        ? _fees
        : _fees.where((f) => f['category'] == _selectedCategoryFilter).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundBlack,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundBlack,
        title: const Text('Fee Catalog', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textGrey),
            onPressed: () => _showFilterDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddFeeModal(),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Fee', style: TextStyle(color: Colors.white)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: displayFees.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 12),
        itemBuilder: (ctx, i) => _buildFeeCard(displayFees[i]),
      ),
    );
  }

  Widget _buildFeeCard(Map<String, dynamic> fee) {
    final bool isActive = fee['is_active'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDarkGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isActive ? AppColors.primaryBlue : AppColors.textGrey,
            width: 4,
          ),
        ),
      ),
      child: Column(
        children: [
          // HEADER
          ListTile(
            onTap: () => _openAddFeeModal(existingFee: fee),
            title: Text(
              fee['name'],
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Row(
                children: [
                  _Tag(label: fee['category'], color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  _Tag(label: fee['target_grade'], color: Colors.teal),
                ],
              ),
            ),
            trailing: Text(
              '\$${fee['amount'].toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          
          const Divider(color: AppColors.surfaceLightGrey, height: 1),

          // ACTIONS ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _openAddFeeModal(existingFee: fee),
                    icon: const Icon(Icons.edit, size: 16, color: AppColors.textGrey),
                    label: const Text('Edit', style: TextStyle(color: AppColors.textGrey)),
                  ),
                ),
                Container(width: 1, height: 20, color: AppColors.surfaceLightGrey),
                Expanded(
                  child: TextButton.icon(
                    onPressed: isActive ? () => _confirmInvoicing(fee) : null,
                    icon: Icon(Icons.send, size: 16, color: isActive ? AppColors.primaryBlue : Colors.grey),
                    label: Text(
                      'Invoice Class',
                      style: TextStyle(
                        color: isActive ? AppColors.primaryBlue : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        backgroundColor: AppColors.surfaceDarkGrey,
        title: const Text('Filter by Category', style: TextStyle(color: Colors.white)),
        children: [
          SimpleDialogOption(
            onPressed: () {
              setState(() => _selectedCategoryFilter = 'All');
              Navigator.pop(ctx);
            },
            child: const Text('All', style: TextStyle(color: Colors.white)),
          ),
          ..._categories.map((cat) => SimpleDialogOption(
                onPressed: () {
                  setState(() => _selectedCategoryFilter = cat);
                  Navigator.pop(ctx);
                },
                child: Text(cat, style: const TextStyle(color: Colors.white)),
              )),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGETS
// -----------------------------------------------------------------------------

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(100), width: 0.5),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textGrey)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// EDITOR MODAL (Simplified for brevity, same as before but cleaner)
// -----------------------------------------------------------------------------
class _FeeEditor extends StatefulWidget {
  final Map<String, dynamic>? fee;
  final List<String> categories;
  final Function(Map<String, dynamic>) onSave;

  const _FeeEditor({this.fee, required this.categories, required this.onSave});

  @override
  State<_FeeEditor> createState() => _FeeEditorState();
}

class _FeeEditorState extends State<_FeeEditor> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Tuition';
  String _recurrence = 'Termly';
  String _targetGrade = 'All'; 
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.fee != null) {
      _nameController.text = widget.fee!['name'];
      _amountController.text = widget.fee!['amount'].toString();
      _selectedCategory = widget.fee!['category'];
      _recurrence = widget.fee!['recurrence'];
      _targetGrade = widget.fee!['target_grade'];
      _isActive = widget.fee!['is_active'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.fee == null ? 'New Fee Structure' : 'Edit Fee Structure',
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(labelText: 'Fee Name', labelStyle: TextStyle(color: AppColors.textGrey)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Amount (\$)', labelStyle: TextStyle(color: AppColors.textGrey)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  dropdownColor: AppColors.surfaceDarkGrey,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: AppColors.textGrey)),
                  items: widget.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _targetGrade,
                  dropdownColor: AppColors.surfaceDarkGrey,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(labelText: 'Target', labelStyle: TextStyle(color: AppColors.textGrey)),
                  items: ['All', 'Form 1', 'Form 2', 'Form 3', 'Form 4'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) => setState(() => _targetGrade = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Active', style: TextStyle(color: Colors.white)),
            value: _isActive,
            activeColor: AppColors.primaryBlue,
            onChanged: (val) => setState(() => _isActive = val),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              onPressed: () {
                if (_nameController.text.isEmpty || _amountController.text.isEmpty) return;
                
                final newFee = {
                  'id': widget.fee?['id'] ?? DateTime.now().toIso8601String(),
                  'name': _nameController.text,
                  'category': _selectedCategory,
                  'amount': double.tryParse(_amountController.text) ?? 0.0,
                  'currency': 'USD',
                  'recurrence': _recurrence,
                  'target_grade': _targetGrade,
                  'is_active': _isActive,
                  'students_count': 100, // Mock count
                };
                widget.onSave(newFee);
              },
              child: const Text('Save Fee Structure', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}