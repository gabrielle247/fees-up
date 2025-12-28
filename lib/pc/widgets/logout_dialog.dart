import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isLoading = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoading = true);
    try {
      // 1. Sign out from Supabase
      await Supabase.instance.client.auth.signOut();
      
      if (mounted) {
        // 2. Close dialog
        Navigator.of(context).pop(); 
        
        // 3. The Router (GoRouter) should detect the auth state change 
        // and redirect to /login automatically. 
        // But for safety, we can explicitly go there if the listener lags.
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Logout failed: $e"), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    const bgColor = Color(0xFF151718);
    const surfaceColor = Color(0xFF1F2227); // Slightly lighter for dialog
    const textWhite = Colors.white;
    const textGrey = Color(0xFF9CA3AF);
    const dangerRed = Color(0xFFEF4444);

    return Dialog(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Align left as per design
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dangerRed.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: dangerRed, size: 24),
                ),
                const SizedBox(width: 16),
                const Text(
                  "Confirm Logout",
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Are you sure you want to log out of the Financial Portal? Any unsaved changes on the current page will be preserved locally.",
              style: TextStyle(color: textGrey, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: textGrey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dangerRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: _isLoading 
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Log Out", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}