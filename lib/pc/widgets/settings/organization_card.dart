import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../data/providers/dashboard_provider.dart';
import '../../../data/services/database_service.dart';

class OrganizationCard extends ConsumerStatefulWidget {
  const OrganizationCard({super.key});

  @override
  ConsumerState<OrganizationCard> createState() => _OrganizationCardState();
}

class _OrganizationCardState extends ConsumerState<OrganizationCard> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _logoController = TextEditingController();

  bool _hydrated = false;
  bool _saving = false;
  Map<String, dynamic>? _schoolData;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => _loadingCard(),
      error: (err, _) => _errorCard('Error loading school: $err'),
      data: (dashboard) {
        if (dashboard.schoolId.isEmpty) {
          return _errorCard('No school context');
        }

        if (!_hydrated) {
          _loadSchoolData(dashboard.schoolId);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Organization",
                  style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6)),
                child:
                    const Icon(Icons.business, color: Colors.purple, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text("Public details.",
              style: TextStyle(color: AppColors.textWhite54, fontSize: 12)),
          const SizedBox(height: 24),
          _buildInput("School Name", _nameController),
          const SizedBox(height: 16),
          _buildInput("Address", _addressController, maxLines: 3),
          const SizedBox(height: 16),
          _buildInput("Contact Email", _emailController),
          const SizedBox(height: 16),
          _buildInput("Logo URL", _logoController,
              helper: "Public image link for invoices and dashboards."),
          const SizedBox(height: 16),
          if (_logoController.text.isNotEmpty) _buildLogoPreview(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _hydrated && _schoolData != null
                    ? () => _loadSchoolData(schoolId, force: true)
                    : null,
                child: const Text('Reset'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _saving ? null : () => _onSave(context, schoolId),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadSchoolData(String schoolId, {bool force = false}) async {
    if (_hydrated && !force) return;

    try {
      final db = DatabaseService();
      final results = await db.db.getAll(
        'SELECT * FROM schools WHERE id = ?',
        [schoolId],
      );

      if (results.isEmpty) {
        if (mounted) setState(() => _hydrated = true);
        return;
      }

      final school = results.first;
      _schoolData = school;

      // Parse address/email from JSON if stored there, otherwise use separate columns if they exist
      String address = school['address'] as String? ?? '';
      String email = school['contact_email'] as String? ?? '';
      String logoUrl = school['logo_url'] as String? ?? '';

      // Check if there's a contact_info JSON field
      final contactInfoRaw = school['contact_info'] as String? ?? '';
      if (contactInfoRaw.isNotEmpty) {
        try {
          final contactInfo =
              jsonDecode(contactInfoRaw) as Map<String, dynamic>;
          address = contactInfo['address'] as String? ?? '';
          email = contactInfo['email'] as String? ?? '';
          logoUrl = contactInfo['logo'] as String? ?? logoUrl;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _nameController.text = school['name'] as String? ?? '';
          _addressController.text = address;
          _emailController.text = email;
          _logoController.text = logoUrl;
          _hydrated = true;
        });
      }
    } catch (e) {
      debugPrint('⚠️ Error loading school data: $e');
      if (mounted) setState(() => _hydrated = true);
    }
  }

  Future<void> _onSave(BuildContext context, String schoolId) async {
    setState(() => _saving = true);

    try {
      final db = DatabaseService();

      // Store contact info as JSON in a text field
      final contactInfo = jsonEncode({
        'address': _addressController.text.trim(),
        'email': _emailController.text.trim(),
        'logo': _logoController.text.trim(),
      });

      // Check if contact_info column exists, if not just update name
      try {
        await db.db.execute(
          '''UPDATE schools 
             SET name = ?, contact_info = ?, logo_url = ?
             WHERE id = ?''',
          [
            _nameController.text.trim(),
            contactInfo,
            _logoController.text.trim(),
            schoolId,
          ],
        );
      } catch (_) {
        // contact_info column doesn't exist, just update name
        await db.db.execute(
          'UPDATE schools SET name = ? WHERE id = ?',
          [_nameController.text.trim(), schoolId],
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization details updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildLogoPreview() {
    final logoUrl = _logoController.text.trim();
    if (logoUrl.isEmpty) return const SizedBox.shrink();

    // Check if it's a Supabase storage path (filename without full URL)
    String displayUrl = logoUrl;
    if (!logoUrl.startsWith('http')) {
      // Assume it's a Supabase avatars bucket path
      // Format: https://<supabase-url>/storage/v1/object/public/avatars/<filename>
      displayUrl =
          'https://fzopzlktsvmgskrqpgma.supabase.co/storage/v1/object/public/avatars/$logoUrl';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Logo Preview",
            style: TextStyle(color: AppColors.textWhite70, fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.backgroundBlack,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.divider),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              displayUrl,
              width: 120,
              height: 120,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_not_supported,
                            color: AppColors.warningOrange),
                        SizedBox(height: 4),
                        Text("Image not found",
                            style: TextStyle(
                                color: AppColors.textWhite38, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(String label, TextEditingController controller,
      {int maxLines = 1, String? helper}) {
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
            fillColor: AppColors.backgroundBlack,
            contentPadding: const EdgeInsets.all(16),
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

  Widget _loadingCard() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _errorCard(String message) {
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
