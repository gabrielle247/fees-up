// ignore_for_file: unused_field

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fees_up/data/constants/app_colors.dart';

// =============================================================================
// 1. LOCAL STRINGS & CONSTANTS (Strictly No UI String Literals)
// =============================================================================
class _ViewStrings {
  static const String pageTitle = "Student Profile";
  
  // Status Labels
  static const String statusActive = "ACTIVE";
  static const String statusArrears = "ARREARS";
  static const String statusSuspended = "SUSPENDED";
  
  // Tabs
  static const String tabOverview = "Overview";
  static const String tabFinance = "Finance History";
  static const String tabAcademic = "Academic";

  // Actions
  static const String actCall = "Call";
  static const String actWhatsApp = "WhatsApp";
  static const String actPay = "Pay Fees";
  static const String actEdit = "Edit";

  // Section Headers
  static const String secIdentity = "Identity & Class";
  static const String secGuardian = "Guardian / Payer";
  static const String secSubjects = "Registered Subjects";
  static const String secFeeStatus = "Fee Status";

  // Labels
  static const String lblAdmNum = "Adm No.";
  static const String lblDob = "DOB";
  static const String lblGender = "Gender";
  static const String lblType = "Type";
  static const String lblPhone = "Phone";
  static const String lblEmail = "Email";
  static const String lblRelation = "Relation";
  
  // Finance
  static const String lblOwed = "Outstanding Balance";
  static const String lblPaid = "Paid YTD";
  static const String currency = "\$";

  // Fallbacks
  static const String noSubjects = "No subjects registered";
  static const String loading = "Loading student profile...";
  static const String error = "Could not load student.";
}

// =============================================================================
// 2. SCREEN IMPLEMENTATION
// =============================================================================
class ViewStudentScreen extends StatefulWidget {
  final String? studentId;

  const ViewStudentScreen({super.key, this.studentId});

  @override
  State<ViewStudentScreen> createState() => _ViewStudentScreenState();
}

class _ViewStudentScreenState extends State<ViewStudentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  
  // Mock Student Data Object (Replacing with real model later)
  Map<String, dynamic>? _student;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    // Simulate Network Delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      setState(() {
        // PLACEBO DATA: In production, fetch by widget.studentId
        _student = {
          "id": widget.studentId ?? "123",
          "firstName": "Nyasha",
          "lastName": "Gabriel",
          "admissionNumber": "2024-0899",
          "status": "ACTIVE",
          "dob": "2006-03-08",
          "gender": "Male",
          "studentType": "Day Scholar",
          "guardianName": "Tawananyasha Kuudzadombo",
          "guardianPhone": "+263 77 123 4567",
          "guardianRelationship": "Father",
          "feesOwed": 150.00,
          "feesPaid": 450.00,
          // JSON String mimicking DB storage
          "subjects": '["Mathematics", "Computer Science", "Physics", "Economics", "Business Enterprise"]', 
        };
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text(_ViewStrings.pageTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_student == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(_ViewStrings.pageTitle)),
        body: const Center(child: Text(_ViewStrings.error)),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240.0,
              floating: false,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () {
                    // Navigate to Edit
                  },
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildIdCardHeader(context),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primaryBlue,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: _ViewStrings.tabOverview),
                  Tab(text: _ViewStrings.tabFinance),
                  Tab(text: _ViewStrings.tabAcademic),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(context),
            _buildFinanceTab(context),
            _buildAcademicTab(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Go to Pay route
        },
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text(_ViewStrings.actPay, style: TextStyle(color: Colors.white)),
      ),
    );
  }

  // ===========================================================================
  // CREATIVE HEADER: THE "DIGITAL ID CARD"
  // ===========================================================================
  Widget _buildIdCardHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Background Gradient Mesh
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFFE2E8F0), const Color(0xFFF8FAFC)],
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 80, 24, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar / Photo
                Hero(
                  tag: 'student_avatar_${_student!['id']}',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(50),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "${_student!['firstName'][0]}${_student!['lastName'][0]}",
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 20),

                // Text Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.successGreen.withAlpha(100)),
                        ),
                        child: Text(
                          _student!['status'] ?? _ViewStrings.statusActive,
                          style: const TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${_student!['firstName']} ${_student!['lastName']}",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_ViewStrings.lblAdmNum}: ${_student!['admissionNumber']}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'JetBrains Mono', // Developer aesthetic
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: OVERVIEW
  // ===========================================================================
  Widget _buildOverviewTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions Row
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context, 
                  Icons.call_outlined, 
                  _ViewStrings.actCall, 
                  () => _launchUrl("tel:${_student!['guardianPhone']}"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context, 
                  Icons.message_outlined, 
                  _ViewStrings.actWhatsApp, 
                  () => {}, // Todo: Implement WA link
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Identity Card
          _buildInfoCard(context, _ViewStrings.secIdentity, [
            _InfoRow(_ViewStrings.lblDob, _student!['dob']),
            _InfoRow(_ViewStrings.lblGender, _student!['gender']),
            _InfoRow(_ViewStrings.lblType, _student!['studentType']),
          ]),

          const SizedBox(height: 16),

          // Guardian Card
          _buildInfoCard(context, _ViewStrings.secGuardian, [
            _InfoRow(_ViewStrings.lblRelation, _student!['guardianRelationship']),
            _InfoRow("Name", _student!['guardianName']),
            _InfoRow(_ViewStrings.lblPhone, _student!['guardianPhone']),
          ]),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 2: FINANCE
  // ===========================================================================
  Widget _buildFinanceTab(BuildContext context) {
    final owed = _student!['feesOwed'] as double;
    final paid = _student!['feesPaid'] as double;
    final total = owed + paid;
    final progress = total == 0 ? 0.0 : paid / total;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Financial Health Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_ViewStrings.lblOwed, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      "${_ViewStrings.currency}${owed.toStringAsFixed(2)}",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: owed > 0 ? AppColors.errorRed : AppColors.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.errorRed.withAlpha(50),
                  color: AppColors.successGreen,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(6),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${(progress * 100).toInt()}% Paid", style: Theme.of(context).textTheme.bodySmall),
                    Text("Total: ${_ViewStrings.currency}${total.toStringAsFixed(2)}", style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Ledger Placeholder (Using generic placeholders for visuals)
          _buildTransactionTile(context, "Tuition Fee - Term 1", "- \$150.00", true),
          _buildTransactionTile(context, "Payment (Cash)", "+ \$50.00", false),
          _buildTransactionTile(context, "Payment (Ecocash)", "+ \$100.00", false),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 3: ACADEMIC
  // ===========================================================================
  Widget _buildAcademicTab(BuildContext context) {
    // Parse JSON Subjects
    List<dynamic> subjects = [];
    try {
      if (_student!['subjects'] != null) {
        subjects = jsonDecode(_student!['subjects']);
      }
    } catch (e) {
      subjects = ["Error parsing subjects"];
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _ViewStrings.secSubjects,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 12,
            children: subjects.isEmpty
                ? [const Text(_ViewStrings.noSubjects)]
                : subjects.map((subj) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primaryBlue.withAlpha(50)),
                      ),
                      child: Text(
                        subj.toString(),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================
  
  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final theme = Theme.of(context);
    final btnColor = color ?? theme.textTheme.bodyLarge?.color;
    
    return Material(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(icon, color: btnColor),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.bold, color: btnColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withAlpha(50)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 16),
          ...rows.map((row) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    row.label,
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                ),
                Expanded(
                  child: Text(
                    row.value ?? "-",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(BuildContext context, String title, String amount, bool isDebit) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: isDebit ? AppColors.errorRed.withAlpha(30) : AppColors.successGreen.withAlpha(30),
        child: Icon(
          isDebit ? Icons.arrow_outward : Icons.arrow_downward,
          color: isDebit ? AppColors.errorRed : AppColors.successGreen,
          size: 18,
        ),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDebit ? AppColors.errorRed : AppColors.successGreen,
        ),
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    // Placeholder for url_launcher logic
    // if (await canLaunchUrl(Uri.parse(urlString))) ...
  }
}

// Helper Class for Info Rows
class _InfoRow {
  final String label;
  final String? value;
  _InfoRow(this.label, this.value);
}