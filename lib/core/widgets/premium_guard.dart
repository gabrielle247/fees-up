import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- MOCK PROVIDER ---
// Toggle this to 'true' to simulate a paid account, 'false' for free tier.
// We keep it true for now so you can work without disturbance.
final isPremiumProvider = Provider<bool>((ref) => true); 

class PremiumGuard extends ConsumerWidget {
  final Widget child;
  final String featureName;

  const PremiumGuard({
    super.key, 
    required this.child,
    this.featureName = "This Feature",
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);

    // If Premium, show the actual feature
    if (isPremium) {
      return child;
    }

    // If Limited, show the "Blank Canvas" / Upgrade Prompt
    return Stack(
      children: [
        // 1. Blurred/Disabled Child (Optional, or just hide it)
        Opacity(
          opacity: 0.1,
          child: AbsorbPointer(child: child),
        ),

        // 2. The Upgrade Overlay
        Center(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF151718),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.5*255) as int),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond_outlined, size: 48, color: Color(0xFFA855F7)), // Purple
                const SizedBox(height: 20),
                Text(
                  "Unlock $featureName",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  "This feature is available on the Unlimited Plan. \nUpgrade to remove limits.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to Payment/Subscription Screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Subscription Flow Coming Soon")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text("Get Unlimited Access"),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}