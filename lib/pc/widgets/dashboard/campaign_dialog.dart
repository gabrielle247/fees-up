import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/providers/campaign_provider.dart';
import '../../../data/models/fundraiser_models.dart';

class CampaignDialog extends ConsumerStatefulWidget {
  final String schoolId;
  const CampaignDialog({super.key, required this.schoolId});

  @override
  ConsumerState<CampaignDialog> createState() => _CampaignDialogState();
}

class _CampaignDialogState extends ConsumerState<CampaignDialog> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _goalController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedType = 'Infrastructure';
  bool _forceCreateMode = false; // Toggle to override the "Active Campaign" warning

  @override
  void dispose() {
    _nameController.dispose();
    _goalController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- ACTIONS ---

  Future<void> _submitCreate() async {
    if (!_formKey.currentState!.validate()) return;

    // Trigger the provider to create the campaign
    final success = await ref.read(campaignControllerProvider.notifier).createCampaign(
      schoolId: widget.schoolId,
      name: _nameController.text.trim(),
      goal: double.tryParse(_goalController.text.trim()) ?? 0.0,
      description: _descController.text.trim(),
      type: _selectedType,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Campaign Launched Successfully"), 
          backgroundColor: AppColors.successGreen
        ),
      );
    }
  }

  Future<void> _closeExisting(String id) async {
    final success = await ref.read(campaignControllerProvider.notifier).closeCampaign(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Campaign Closed."), 
          backgroundColor: AppColors.primaryBlue
        ),
      );
      // Logic: The provider stream will update automatically, 
      // removing the active campaign and showing the form.
    }
  }

  // --- MAIN BUILD ---

  @override
  Widget build(BuildContext context) {
    final activeCampaignAsync = ref.watch(activeCampaignProvider(widget.schoolId));
    final controllerState = ref.watch(campaignControllerProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 700,
        height: 800,
        decoration: BoxDecoration(
          color: AppColors.backgroundBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5), 
              blurRadius: 20, 
              offset: const Offset(0, 10)
            )
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: AppColors.divider),

            Expanded(
              child: activeCampaignAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                error: (e, _) => Center(child: Text("Error: $e", style: const TextStyle(color: AppColors.errorRed))),
                data: (existingCampaign) {
                  // If we have an active campaign AND we haven't forced "Create Mode"
                  if (existingCampaign != null && !_forceCreateMode) {
                    return _buildActiveCampaignWarning(existingCampaign, controllerState.isLoading);
                  }
                  // Otherwise show the form
                  return _buildCreateForm(controllerState.isLoading, existingCampaign != null);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.2), 
              borderRadius: BorderRadius.circular(8)
            ),
            child: const Icon(Icons.campaign, color: AppColors.accentPurple),
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Campaign Manager", 
                style: TextStyle(color: AppColors.textWhite, fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Fundraising & Projects", 
                style: TextStyle(color: AppColors.textWhite54, fontSize: 13)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveCampaignWarning(Campaign campaign, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.3)),
            ),
            child: const Column(
              children: [
                Icon(Icons.warning_amber_rounded, size: 48, color: AppColors.warningOrange),
                SizedBox(height: 16),
                Text(
                  "Active Campaign Detected",
                  style: TextStyle(color: AppColors.warningOrange, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  "We recommend closing the current campaign before starting a new one to prevent data distortion.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textWhite70, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Current Campaign Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceGrey,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("RUNNING NOW", style: TextStyle(color: AppColors.textWhite54, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(campaign.name, style: const TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Goal: \$${NumberFormat().format(campaign.goalAmount)} • Type: ${campaign.type}", 
                        style: const TextStyle(color: AppColors.primaryBlueLight)),
                    ],
                  ),
                ),
                if (!isLoading)
                  ElevatedButton.icon(
                    onPressed: () => _closeExisting(campaign.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.errorRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                    icon: const Icon(Icons.archive, size: 18),
                    label: const Text("Close This Campaign"),
                  ),
              ],
            ),
          ),

          const Spacer(),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Back", style: TextStyle(color: AppColors.textWhite70)),
              ),
              const SizedBox(width: 16),
              // THE "SCHOOL'S CONCERN" OPTION
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _forceCreateMode = true;
                  });
                },
                icon: const Icon(Icons.add_circle_outline, color: AppColors.warningOrange, size: 18),
                label: const Text("Start Concurrent Campaign (Advanced)", style: TextStyle(color: AppColors.warningOrange)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm(bool isLoading, bool isConcurrent) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("START NEW CAMPAIGN", style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                if (isConcurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.warningOrange.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
                    child: const Text("CONCURRENT MODE", style: TextStyle(color: AppColors.warningOrange, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
              ],
            ),
            const SizedBox(height: 24),

            _buildLabel("Campaign Name"),
            _buildTextField(
              controller: _nameController,
              hint: "e.g. New Science Block 2025",
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Goal Amount"),
                      _buildTextField(
                        controller: _goalController,
                        hint: "0.00",
                        prefix: "\$ ",
                        inputType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Required";
                          if (double.tryParse(v) == null) return "Invalid";
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("Type"),
                      _buildDropdown(
                        value: _selectedType,
                        items: ["Infrastructure", "Event", "Charity", "Sports", "General"],
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel("Description / Purpose"),
            _buildTextField(
              controller: _descController,
              hint: "Describe the purpose of this fundraising...",
              maxLines: 4,
            ),

            const Spacer(),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    if (_forceCreateMode) {
                      setState(() => _forceCreateMode = false); // Go back to warning
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text("Cancel", style: TextStyle(color: AppColors.textWhite70)),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _submitCreate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.rocket_launch, size: 18),
                  label: Text(isLoading ? "Launching..." : "Launch Campaign", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- UI HELPERS ---
  
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller, maxLines: maxLines, keyboardType: inputType,
      validator: validator,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        filled: true, fillColor: AppColors.surfaceGrey, hintText: hint,
        hintStyle: TextStyle(color: AppColors.textWhite.withValues(alpha: 0.3)),
        prefixText: prefix, prefixStyle: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryBlue)),
      ),
    );
  }

  Widget _buildDropdown({
    required String value, required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey, borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.surfaceGrey,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textWhite54),
          isExpanded: true, style: const TextStyle(color: AppColors.textWhite),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}