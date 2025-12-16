import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/billing_config.dart';
import '../services/database_service.dart';

class BillingSettingsPage extends ConsumerStatefulWidget {
  const BillingSettingsPage({super.key});

  @override
  ConsumerState<BillingSettingsPage> createState() => _BillingSettingsPageState();
}

class _BillingSettingsPageState extends ConsumerState<BillingSettingsPage> {
  // -- State --
  BillingConfig _config = BillingConfig(); 
  bool _isLoading = true;

  // -- Controllers --
  final _defaultFeeCtrl = TextEditingController();
  final _cycleCtrl = TextEditingController();
  final _lateFeeAmountCtrl = TextEditingController();
  final _graceDaysCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    // Fetch from SQLite
    final config = await DatabaseService.instance.getBillingConfig();
    
    if (mounted) {
      setState(() {
        _config = config;
        // Sync controllers
        _defaultFeeCtrl.text = _config.defaultFee.toStringAsFixed(2);
        _cycleCtrl.text = _config.cycleInterval.toString();
        _lateFeeAmountCtrl.text = _config.lateFeeAmount.toStringAsFixed(2);
        _graceDaysCtrl.text = _config.graceDays.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _defaultFeeCtrl.dispose();
    _cycleCtrl.dispose();
    _lateFeeAmountCtrl.dispose();
    _graceDaysCtrl.dispose();
    super.dispose();
  }

  // --- Actions ---

  Future<void> _saveConfiguration() async {
    setState(() => _isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You must be logged in to save billing settings.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final db = DatabaseService.instance;
    final profile = await db.getUserProfileById(user.id);
    final schoolId = profile != null ? (profile['school_id'] as String?) : null;
    if (schoolId == null || schoolId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Complete school setup before saving billing settings.')),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    // 1. Update Config Object from Controllers
    _config.defaultFee = double.tryParse(_defaultFeeCtrl.text) ?? 0.0;
    _config.cycleInterval = int.tryParse(_cycleCtrl.text) ?? 3;
    _config.lateFeeAmount = double.tryParse(_lateFeeAmountCtrl.text) ?? 0.0;
    _config.graceDays = int.tryParse(_graceDaysCtrl.text) ?? 5;

    try {
      // 2. Persist to DB
      await DatabaseService.instance.saveBillingConfig(_config, schoolId: schoolId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Configuration Saved Successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error saving: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addExpenseCategory(String category) {
    if (category.isNotEmpty && !_config.expenseCategories.contains(category)) {
      setState(() {
        // Because BillingConfig now initializes this as a mutable list, .add() works
        _config.expenseCategories.add(category);
      });
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xff1c2a35),
        title: const Text("New Category", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "e.g. Transport",
            hintStyle: TextStyle(color: Colors.white54),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _addExpenseCategory(ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTermDialog() async {
    final nameCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: DateTime.now().year.toString());
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 90));

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xff1c2a35),
          title: const Text("Add Academic Term", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Term Name", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "e.g. Term 1, First Term",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black.withAlpha(30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text("Academic Year", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 8),
                TextField(
                  controller: yearCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "e.g. 2025",
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.black.withAlpha(30),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.white.withAlpha(20)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Start Date", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: startDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2035),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xff3498db),
                                      surface: Color(0xff1c2a35),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  startDate = picked;
                                  if (endDate.isBefore(startDate)) {
                                    endDate = startDate.add(const Duration(days: 90));
                                  }
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withAlpha(20)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(startDate),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("End Date", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: endDate,
                                firstDate: startDate,
                                lastDate: DateTime(2035),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xff3498db),
                                      surface: Color(0xff1c2a35),
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() => endDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(30),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withAlpha(20)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('MMM dd, yyyy').format(endDate),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Icon(Icons.calendar_today, size: 16, color: Colors.white54),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final year = yearCtrl.text.trim();
                
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a term name")),
                  );
                  return;
                }
                
                if (year.isEmpty || int.tryParse(year) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a valid year")),
                  );
                  return;
                }

                if (endDate.isBefore(startDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("End date must be after start date")),
                  );
                  return;
                }

                // Create a unique ID for the term
                final termId = 'TERM-${DateTime.now().millisecondsSinceEpoch}';
                
                // Add to config
                setState(() {
                  _config.terms.add(TermConfig(
                    id: termId,
                    name: name,
                    year: year,
                    start: startDate,
                    end: endDate,
                  ));
                });
                
                Navigator.pop(ctx);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Term '$name' added successfully")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff3498db),
              ),
              child: const Text("Add Term"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Custom Theme Colors
    const cardColor = Color(0xff1c2a35);
    const bgColor = Color(0xff121b22);
    const blueAccent = Color(0xff3498db);

    final inputDecoration = BoxDecoration(
      color: Colors.black.withAlpha(50),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white.withAlpha(20)),
    );

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Billing Settings", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            Text("Financial Configuration", style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(title: "GENERAL PARAMETERS"),
            
            // --- GENERAL CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(10)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label("Billing Type"),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: inputDecoration,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _config.billingType,
                                  dropdownColor: cardColor,
                                  isExpanded: true,
                                  icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  items: ['Monthly', 'Term-based'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                  onChanged: (v) => setState(() => _config.billingType = v!),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Label("Cycle Interval"),
                            Container(
                              decoration: inputDecoration,
                              child: TextField(
                                controller: _cycleCtrl,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  suffixText: "MTHS",
                                  suffixStyle: TextStyle(fontSize: 10, color: Colors.white54),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _Label("Default Student Fee"),
                  Container(
                    decoration: inputDecoration,
                    child: TextField(
                      controller: _defaultFeeCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.attach_money, color: Colors.white54),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Applied automatically to new enrollments",
                    style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // --- TERMS SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const _SectionHeader(title: "ACADEMIC TERMS"),
                TextButton.icon(
                  onPressed: _showAddTermDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text("Add Term"),
                  style: TextButton.styleFrom(foregroundColor: blueAccent),
                )
              ],
            ),
            
            ..._config.terms.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final term = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withAlpha(10)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withAlpha(50)),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                index.toString().padLeft(2, '0'), 
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(term.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(term.year, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () {}, 
                          icon: const Icon(Icons.edit, size: 18, color: Colors.white54)
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _DateBox(label: "START DATE", date: term.start)),
                        const SizedBox(width: 12),
                        Expanded(child: _DateBox(label: "END DATE", date: term.end)),
                      ],
                    )
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            const _SectionHeader(title: "EXPENSE CATEGORIES"),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(10)),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 12,
                children: [
                  ..._config.expenseCategories.map((cat) => Chip(
                    label: Text(cat),
                    backgroundColor: blueAccent.withAlpha(40),
                    labelStyle: TextStyle(color: blueAccent.withAlpha(255), fontWeight: FontWeight.w600),
                    side: BorderSide(color: blueAccent.withAlpha(100)),
                    deleteIcon: Icon(Icons.close, size: 14, color: blueAccent.withAlpha(200)),
                    onDeleted: () => setState(() => _config.expenseCategories.remove(cat)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  )),
                  
                  ActionChip(
                    label: const Text("+ New Category"),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.white.withAlpha(50), style: BorderStyle.solid),
                    labelStyle: TextStyle(color: Colors.white.withAlpha(150)),
                    onPressed: _showAddCategoryDialog,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            const _SectionHeader(title: "LATE FEE POLICY"),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(10)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Auto-apply Late Fees", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text("Charge after grace period", style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12)),
                        ],
                      ),
                      Switch(
                        value: _config.autoLateFee, 
                        onChanged: (v) => setState(() => _config.autoLateFee = v),
                        activeThumbColor: blueAccent,
                        activeTrackColor: blueAccent.withAlpha(100),
                        inactiveTrackColor: Colors.grey.withAlpha(50),
                      ),
                    ],
                  ),
                  if (_config.autoLateFee) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label("Grace Days"),
                              Container(
                                decoration: inputDecoration,
                                child: TextField(
                                  controller: _graceDaysCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _Label("Fee Amount"),
                              Container(
                                decoration: inputDecoration,
                                child: TextField(
                                  controller: _lateFeeAmountCtrl,
                                  style: const TextStyle(color: Colors.white),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.attach_money, size: 16, color: Colors.white54),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveConfiguration,
                style: ElevatedButton.styleFrom(
                  backgroundColor: blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                ),
                icon: const Icon(Icons.save),
                label: const Text("Save Configuration", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.white.withAlpha(150))),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- Local Widgets ---

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withAlpha(150),
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
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
        style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final DateTime date;

  const _DateBox({required this.label, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM dd, yyyy').format(date),
            style: const TextStyle(color: Colors.white, fontFamily: 'Monospace', fontSize: 13),
          ),
        ],
      ),
    );
  }
}