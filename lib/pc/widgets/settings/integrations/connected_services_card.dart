import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class ConnectedServicesCard extends StatelessWidget {
  const ConnectedServicesCard({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text("Connected Services", style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
              Icon(Icons.extension, color: Colors.orange[800], size: 18),
            ],
          ),
          const SizedBox(height: 24),

          const Text("ACCOUNTING SOFTWARE", style: TextStyle(color: AppColors.textWhite38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          
          const _ServiceRow(
            name: "QuickBooks\nOnline",
            isConnected: true,
            icon: "QB",
            color: Color(0xFF2CA01C), // QB Green
          ),
          const SizedBox(height: 16),
          const _ServiceRow(
            name: "Xero",
            isConnected: false,
            icon: "X",
            color: Color(0xFF13B5EA), // Xero Blue
          ),

          const SizedBox(height: 24),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 24),

          const Text("COMMUNICATION", style: TextStyle(color: AppColors.textWhite38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
          const SizedBox(height: 16),
          const _ServiceRow(
            name: "Mailgun",
            isConnected: true, // Special state "Configure"
            isConfigurable: true,
            desc: "Email delivery service",
            icon: "M",
            color: Color(0xFFFD5D5D), // Mailgun Red/Orange
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final String name;
  final bool isConnected;
  final bool isConfigurable;
  final String icon;
  final Color color;
  final String? desc;

  const _ServiceRow({
    required this.name,
    required this.isConnected,
    this.isConfigurable = false,
    required this.icon,
    required this.color,
    this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundBlack,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
            child: Text(icon, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.textWhite, fontSize: 13, fontWeight: FontWeight.bold, height: 1.1)),
                if (isConnected && !isConfigurable) 
                  const Text("● Connected", style: TextStyle(color: AppColors.successGreen, fontSize: 11))
                else if (desc != null)
                  Text(desc!, style: const TextStyle(color: AppColors.textWhite38, fontSize: 11))
                else
                  const Text("Not connected", style: TextStyle(color: AppColors.textWhite38, fontSize: 11)),
              ],
            ),
          ),
          if (isConfigurable)
            TextButton(onPressed: (){}, child: const Text("Configure", style: TextStyle(fontSize: 12)))
          else if (isConnected)
            TextButton(onPressed: (){}, child: const Text("Disconnect", style: TextStyle(color: AppColors.textWhite54, fontSize: 12)))
          else
            TextButton(onPressed: (){}, child: const Text("Connect", style: TextStyle(color: AppColors.primaryBlue, fontSize: 12))),
        ],
      ),
    );
  }
}