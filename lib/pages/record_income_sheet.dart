import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../services/database_service.dart';

class RecordIncomeSheet extends StatefulWidget {
  const RecordIncomeSheet({super.key});

  @override
  State<RecordIncomeSheet> createState() => _RecordIncomeSheetState();
}

class _RecordIncomeSheetState extends State<RecordIncomeSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _payerCtrl = TextEditingController(); // For external donors

  // State
  String _selectedCategory = 'tuition';
  DateTime _selectedDate = DateTime.now();
  String? _selectedStudentId;
  String? _selectedStudentName;
  bool _isSaving = false;

  // Search State
  final _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Reset category when tab changes
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setState(() => _selectedCategory = 'tuition'); // Default for Student
      } else {
        setState(() => _selectedCategory = 'fundraiser'); // Default for Other
      }
    });
  }

  // --- Logic ---

  Future<void> _searchStudents(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);

    final db = await DatabaseService.instance.database;
    final results = await db.query(
      'students',
      where: 'full_name LIKE ?',
      whereArgs: ['%$query%'],
      limit: 5,
    );

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  Future<void> _saveRecord() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    // Validation based on Tab
    if (_tabController.index == 0 && _selectedStudentId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a student")));
      return;
    }
    if (_tabController.index == 1 && _payerCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Payer Name / Source")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final db = await DatabaseService.instance.database;

      // Determine Payer Name (Student Name or Manual Input)
      final finalPayerName = _tabController.index == 0
          ? _selectedStudentName
          : _payerCtrl.text.trim();

      await db.insert('payments', {
        'id': const Uuid().v4(),
        'school_id': 'local_school_id', // Replace with real ID from provider
        'student_id': _selectedStudentId, // Null if "Other Revenue"
        'amount': amount,
        'category': _selectedCategory,
        'date_paid': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'method': 'Cash', // You can add a dropdown for this later
        'payer_name': finalPayerName,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        // Optionally link to bill_id if you want to auto-settle a bill here
      });

      // If it was a student payment, update their ledger totals locally
      if (_selectedStudentId != null) {
        // Logic to update paid_total += amount would go here
      }

      if (mounted) {
        Navigator.pop(context, true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Income Recorded Successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff121b22);
    const cardColor = Color(0xff1c2a35);
    const blueColor = Color(0xff2962ff);

    // FIX: Wrap everything in a Material widget to satisfy TabBar requirements
    return Material(
      color: bgColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            const Text(
              "Record Income",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // TABS
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: blueColor,
                labelColor: blueColor,
                unselectedLabelColor: Colors.grey,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Student Payment"),
                  Tab(text: "Other Revenue"),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AMOUNT INPUT (Big & Center)
            Center(
              child: SizedBox(
                width: 200,
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    prefixText: "\$",
                    prefixStyle: TextStyle(color: Colors.white54, fontSize: 40),
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // TAB VIEWS
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // TAB 1: STUDENT PAYMENT
                  _buildStudentTab(cardColor),

                  // TAB 2: OTHER REVENUE
                  _buildOtherTab(cardColor),
                ],
              ),
            ),

            // DATE & SAVE
            const SizedBox(height: 10),
            // We wrap this row in a SafeArea or ensure padding to avoid keyboard overlap issues
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  // Date Picker Button
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) setState(() => _selectedDate = d);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      DateFormat('EEE, MMM d').format(_selectedDate),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveRecord,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Confirm Payment",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentTab(Color cardColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search Student...",
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey),
              ),
              onChanged: _searchStudents,
            ),
          ),

          if (_selectedStudentId != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(50),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withAlpha(100)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Text(
                    _selectedStudentName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedStudentId = null;
                        _selectedStudentName = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],

          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searchResults.isNotEmpty && _selectedStudentId == null)
            ..._searchResults.map(
              (s) => ListTile(
                title: Text(
                  s['full_name'],
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  s['grade'] ?? 'No Grade',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  setState(() {
                    _selectedStudentId = s['id'];
                    _selectedStudentName = s['full_name'];
                    _searchResults = [];
                    _searchCtrl.clear();
                  });
                },
              ),
            ),

          const SizedBox(height: 20),
          _Label("PAYMENT TYPE"),
          Wrap(
            spacing: 10,
            children: ['tuition', 'uniform', 'transport', 'exam_fee'].map((
              cat,
            ) {
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat.toUpperCase()),
                selected: isSelected,
                onSelected: (v) => setState(() => _selectedCategory = cat),
                selectedColor: const Color(0xff2962ff),
                backgroundColor: cardColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherTab(Color cardColor) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label("SOURCE / PAYER"),
          TextField(
            controller: _payerCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: cardColor,
              hintText: "e.g. Rotary Club, Bake Sale, Anonymous",
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _Label("REVENUE CATEGORY"),
          Wrap(
            spacing: 10,
            children: ['fundraiser', 'donation', 'grant', 'other'].map((cat) {
              final isSelected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text(cat.toUpperCase()),
                selected: isSelected,
                onSelected: (v) => setState(() => _selectedCategory = cat),
                selectedColor: Colors.orange,
                backgroundColor: cardColor,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                ),
                side: BorderSide.none,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          _Label("DESCRIPTION / NOTES"),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: cardColor,
              hintText: "Add details...",
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
