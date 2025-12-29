import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';

// --- DIRECT IMPORTS OF YOUR EXISTING DIALOGS ---
// We use them exactly as they are. No changes needed to them.
import '../dashboard/payment_dialog.dart';
import '../dashboard/expense_dialog.dart';
import '../dashboard/student_dialog.dart';
import '../dashboard/campaign_dialog.dart';

/// Global flag to track if the active form has unsaved data.
/// You will wire this up inside your individual dialogs later.
final formDirtyProvider = StateProvider<bool>((ref) => false);

enum TransactionType {
  // Current Modules
  payment,
  expense,
  student,
  campaign,
  // Future / Professional Modules
  payroll,
  assets,
  bulkImport,
  auditLog
}

class UniversalTransactionDialog extends ConsumerStatefulWidget {
  final String schoolId;
  final TransactionType initialType;

  const UniversalTransactionDialog({
    super.key, 
    required this.schoolId, 
    this.initialType = TransactionType.payment
  });

  @override
  ConsumerState<UniversalTransactionDialog> createState() => _UniversalTransactionDialogState();
}

class _UniversalTransactionDialogState extends ConsumerState<UniversalTransactionDialog> {
  late TransactionType _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  /// -----------------------------------------------------------------------
  /// SWITCHING LOGIC (The "Safety Lock")
  /// -----------------------------------------------------------------------
  void _handleTypeSwitch(TransactionType newType) {
    if (_selectedType == newType) return;

    // 1. Future Feature Guard
    if (_isFutureFeature(newType)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("This Professional Module is coming in v2.0"),
          backgroundColor: AppColors.surfaceLightGrey,
          behavior: SnackBarBehavior.floating,
          width: 400,
        ),
      );
      return;
    }

    // 2. Dirty Check (Prevents accidental data loss)
    final isDirty = ref.read(formDirtyProvider);
    if (isDirty) {
      _showDiscardConfirmation(newType);
    } else {
      _performSwitch(newType);
    }
  }

  bool _isFutureFeature(TransactionType type) {
    return type == TransactionType.payroll || 
           type == TransactionType.assets || 
           type == TransactionType.bulkImport || 
           type == TransactionType.auditLog;
  }

  void _performSwitch(TransactionType newType) {
    setState(() {
      _selectedType = newType;
    });
    // Reset the dirty flag so the new screen starts clean
    ref.read(formDirtyProvider.notifier).state = false;
  }

  void _showDiscardConfirmation(TransactionType newType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceGrey,
        title: const Text("Unsaved Changes", style: TextStyle(color: AppColors.textWhite)),
        content: const Text(
          "You have entered data in the current form.\nSwitching will discard it.", 
          style: TextStyle(color: AppColors.textWhite70)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), // Stay
            child: const Text("Stay Here", style: TextStyle(color: AppColors.textWhite54)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // Close alert
              _performSwitch(newType); // Proceed with switch
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            child: const Text("Discard & Switch", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// -----------------------------------------------------------------------
  /// UI BUILD
  /// -----------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      // The Master Container
      child: Container(
        width: 1300, // Wide enough to fit sidebar + your 700px dialogs
        height: 850,
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack, // The "Hub" background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              offset: const Offset(0, 20),
            )
          ],
        ),
        child: Row(
          children: [
            // --- LEFT: NAVIGATION SIDEBAR ---
            Container(
              width: 260,
              decoration: const BoxDecoration(
                color: Color(0xFF0F1115), // Darker sidebar
                borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                border: Border(right: BorderSide(color: AppColors.divider)),
              ),
              child: Column(
                children: [
                  _buildSidebarHeader(),
                  const Divider(color: AppColors.divider),
                  const SizedBox(height: 16),
                  
                  // Active Modules
                  _buildSectionTitle("QUICK ENTRY"),
                  _buildNavItem(TransactionType.payment, "Record Payment", Icons.attach_money, AppColors.successGreen),
                  _buildNavItem(TransactionType.expense, "Add Expense", Icons.receipt_long, AppColors.errorRed),
                  
                  const SizedBox(height: 16),
                  _buildSectionTitle("MANAGEMENT"),
                  _buildNavItem(TransactionType.student, "New Student", Icons.school, AppColors.primaryBlue),
                  _buildNavItem(TransactionType.campaign, "Campaigns", Icons.campaign, AppColors.accentPurple),

                  const SizedBox(height: 16),
                  // Future Modules (Visual Placeholders)
                  _buildSectionTitle("PROFESSIONAL SUITE"),
                  _buildNavItem(TransactionType.payroll, "Run Payroll", Icons.payments_outlined, AppColors.textWhite38),
                  _buildNavItem(TransactionType.assets, "Asset Registry", Icons.inventory_2_outlined, AppColors.textWhite38),
                  _buildNavItem(TransactionType.bulkImport, "Bulk Import", Icons.upload_file, AppColors.textWhite38),
                  _buildNavItem(TransactionType.auditLog, "Audit Logs", Icons.history_edu, AppColors.textWhite38),

                  const Spacer(),
                  _buildCloseButton(),
                ],
              ),
            ),

            // --- RIGHT: CONTENT AREA (Your Dialogs Load Here) ---
            Expanded(
              child: Container(
                color: Colors.black.withValues(alpha: 0.2), // Slight dim for contrast
                child: Center(
                  // We use KeyedSubtree to ensure the old widget is fully disposed ("shut down")
                  // when switching types.
                  child: KeyedSubtree(
                    key: ValueKey(_selectedType),
                    child: _buildSelectedLayout(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// -----------------------------------------------------------------------
  /// THE SWITCHER
  /// Loads your existing dialog widgets directly.
  /// -----------------------------------------------------------------------
  Widget _buildSelectedLayout() {
    // Note: Since your widgets return 'Dialog', they will render with their 
    // own internal shadows/borders. This is fine; they will look like 
    // "Cards" floating inside the Hub.
    switch (_selectedType) {
      case TransactionType.payment:
        return PaymentDialog(schoolId: widget.schoolId);
      case TransactionType.expense:
        return ExpenseDialog(schoolId: widget.schoolId);
      case TransactionType.student:
        return StudentDialog(schoolId: widget.schoolId);
      case TransactionType.campaign:
        return CampaignDialog(schoolId: widget.schoolId);
      default:
        return const SizedBox();
    }
  }

  // --- WIDGET HELPERS ---

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey, 
              borderRadius: BorderRadius.circular(8)
            ),
            child: const Icon(Icons.hub, color: AppColors.textWhite, size: 20),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Transaction Hub", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14)),
              Text("Central Entry Point", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title, 
          style: const TextStyle(
            color: AppColors.textWhite38, 
            fontSize: 10, 
            fontWeight: FontWeight.bold, 
            letterSpacing: 1.0
          )
        ),
      ),
    );
  }

  Widget _buildNavItem(TransactionType type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    final isFuture = _isFutureFeature(type);
    
    return GestureDetector(
      onTap: () => _handleTypeSwitch(type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceGrey : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppColors.divider) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon, 
              size: 18, 
              color: isFuture ? AppColors.textWhite38 : (isSelected ? color : AppColors.textWhite54)
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isFuture ? AppColors.textWhite38 : (isSelected ? AppColors.textWhite : AppColors.textWhite54),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            if (isFuture) ...[
              const Spacer(),
              const Icon(Icons.lock_outline, size: 14, color: AppColors.textWhite38),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close, color: AppColors.textWhite54),
        label: const Text("Close Hub", style: TextStyle(color: AppColors.textWhite54)),
      ),
    );
  }
}