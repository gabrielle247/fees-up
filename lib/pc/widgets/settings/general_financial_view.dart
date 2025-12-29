import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import 'billing_config_card.dart';
import 'organization_card.dart';

class GeneralFinancialView extends ConsumerWidget {
  const GeneralFinancialView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We would typically watch a settingsProvider here to load initial data
    
    return Column(
      children: [
        // WARNING BANNER (Policy Requirement)
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warningOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warningOrange, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Changes to Financial Settings are applied immediately to the server. There is no Undo functionality. Ensure you have authorization.",
                  style: TextStyle(color: AppColors.warningOrange, fontSize: 13),
                ),
              ),
            ],
          ),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: Billing Configuration
            const Expanded(
              flex: 3,
              child: BillingConfigCard(),
            ),
            const SizedBox(width: 24),
            
            // RIGHT: Organization & Integrations
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  const OrganizationCard(),
                  const SizedBox(height: 24),
                  _buildSchoolLogoCard(),
                  const SizedBox(height: 24),
                  _buildIntegrationsCard(),
                ],
              ),
            ),
          ],
        ),
        
        // FOOTER TERMS (Policy Requirement)
        const Padding(
          padding: EdgeInsets.only(top: 32, bottom: 16),
          child: Text(
            "By saving, you agree to the Greyway.Co Data Integrity Policy. Fees Up is not responsible for data loss due to misconfiguration.",
            style: TextStyle(color: AppColors.textWhite38, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildSchoolLogoCard() {
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
          const Text("School Logo", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlack,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textWhite54, style: BorderStyle.solid),
                  ),
                  child: const Icon(Icons.camera_alt, color: AppColors.textWhite54),
                ),
                const SizedBox(height: 12),
                const Text("Upload new logo", style: TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntegrationsCard() {
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
              const Text("Integrations", style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold)),
              Icon(Icons.extension, color: Colors.orange[700], size: 20),
            ],
          ),
          const SizedBox(height: 16),
          const Text("TEACHER ACCESS TOKEN", style: TextStyle(color: AppColors.textWhite38, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundBlack,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.divider),
                  ),
                  alignment: Alignment.centerLeft,
                  child: const Text("sk_live_8372...9283", style: TextStyle(color: AppColors.textWhite54, fontFamily: 'monospace')),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.copy, size: 16, color: AppColors.textWhite70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}