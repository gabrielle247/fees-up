import 'package:flutter/material.dart';
import 'integrations/teacher_tokens_card.dart';
import 'integrations/security_permissions_card.dart';
import 'integrations/connected_services_card.dart';
import 'integrations/api_config_card.dart';

class IntegrationsSettingsView extends StatelessWidget {
  const IntegrationsSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- LEFT COLUMN (Tokens & Security) ---
        Expanded(
          flex: 3,
          child: Column(
            children: [
              TeacherTokensCard(),
              SizedBox(height: 24),
              SecurityPermissionsCard(),
            ],
          ),
        ),
        
        SizedBox(width: 24),

        // --- RIGHT COLUMN (Services & API) ---
        Expanded(
          flex: 2,
          child: Column(
            children: [
              ConnectedServicesCard(),
              SizedBox(height: 24),
              ApiConfigCard(),
            ],
          ),
        ),
      ],
    );
  }
}