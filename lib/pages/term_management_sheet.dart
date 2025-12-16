import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';

class TermManagementSheet extends StatefulWidget {
  final Map<String, dynamic>? existingTerm; // If null, we are in "Add Mode"

  const TermManagementSheet({super.key, this.existingTerm});

  @override
  State<TermManagementSheet> createState() => _TermManagementSheetState();
}

class _TermManagementSheetState extends State<TermManagementSheet> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(); // e.g. "2025"
  final _numberCtrl = TextEditingController(); // e.g. "1", "2", "3"

  // Dates
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 90)); // Default ~3 months

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.existingTerm != null) {
      final t = widget.existingTerm!;
      _nameCtrl.text = t['name'] ?? '';
      _yearCtrl.text = (t['academic_year'] ?? DateTime.now().year).toString();
      _numberCtrl.text = (t['term_number'] ?? 1).toString();
      
      // Note: Dates would ideally be parsed from t['term_dates'] here if needed
    } else {
      // Defaults for new term
      _nameCtrl.text = "Term ${((DateTime.now().month / 4).ceil())}";
      _yearCtrl.text = DateTime.now().year.toString();
      _numberCtrl.text = "1";
    }
  }

  // --- Logic ---

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xff3498db),
              surface: Color(0xff1c2a35),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Auto-adjust end date if it becomes before start
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 90));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveTerm() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final db = DatabaseService.instance;
      
      // Prepare map for 'term_dates' JSON column
      final termNum = int.tryParse(_numberCtrl.text) ?? 1;
      
      await db.createTerm(
        id: widget.existingTerm?['id'], // If ID exists, it replaces (updates)
        name: _nameCtrl.text.trim(),
        academicYear: int.tryParse(_yearCtrl.text) ?? DateTime.now().year,
        termNumber: termNum,
        termDates: {
          termNum: {
            'start': _startDate,
            'end': _endDate
          }
        },
        // REMOVED: academic_year: null (This was causing the error)
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingTerm != null;
    
    // Custom Styles from your design
    const bgColor = Color(0xff121b22);
    const cardColor = Color(0xff1c2a35);
    const blueColor = Color(0xff2962ff); 
    
    final inputDecoration = BoxDecoration(
      color: const Color(0xff121b22), 
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withAlpha(20)),
    );

    return Container(
      color: bgColor,
      height: MediaQuery.of(context).size.height * 0.85, 
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(color: Colors.grey.withAlpha(100), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? "Edit Academic Term" : "New Academic Term",
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Billing Configuration",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),

          // --- FORM CARD ---
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(10)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Term Name
                      _Label("Term Name"),
                      Container(
                        decoration: inputDecoration,
                        child: TextFormField(
                          controller: _nameCtrl,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(
                            hintText: "e.g. Autumn Term",
                            hintStyle: TextStyle(color: Colors.white24),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          validator: (v) => v!.isEmpty ? "Required" : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Row: Year & Number
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Label("Academic Year"),
                                Container(
                                  decoration: inputDecoration,
                                  child: TextFormField(
                                    controller: _yearCtrl,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    decoration: const InputDecoration(
                                      hintText: "2025",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(16),
                                      suffixIcon: Icon(Icons.calendar_today, size: 16, color: Colors.white24),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Label("Number"),
                                Container(
                                  decoration: inputDecoration,
                                  child: TextFormField(
                                    controller: _numberCtrl,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    decoration: const InputDecoration(
                                      hintText: "1",
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 24),

                      // Dates Header
                      const Row(
                        children: [
                          Icon(Icons.date_range, color: Colors.white54, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "TERM DATES",
                            style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          // Start Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Label("START DATE"),
                                GestureDetector(
                                  onTap: () => _pickDate(isStart: true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    decoration: inputDecoration,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(_startDate),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const Icon(Icons.event, color: Colors.white54, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // End Date
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Label("END DATE"),
                                GestureDetector(
                                  onTap: () => _pickDate(isStart: false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    decoration: inputDecoration,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat('dd/MM/yyyy').format(_endDate),
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        const Icon(Icons.event_busy, color: Colors.white54, size: 18),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // --- SAVE BUTTON ---
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveTerm,
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: blueColor.withAlpha(100),
              ),
              icon: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Icon(Icons.save),
              label: Text(
                _isSaving ? "SAVING..." : (isEditing ? "UPDATE TERM" : "CREATE TERM"),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0),
              ),
            ),
          ),
          
          if (isEditing) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            )
          ] else 
            const SizedBox(height: 40), 
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
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}