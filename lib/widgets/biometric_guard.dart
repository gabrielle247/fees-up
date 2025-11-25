import 'package:fees_up/utils/app_singleton.dart';
import 'package:flutter/material.dart';
import '../services/local_auth_service.dart';

class BiometricGuard extends StatefulWidget {
  final Widget child;

  const BiometricGuard({super.key, required this.child});

  @override
  State<BiometricGuard> createState() => _BiometricGuardState();
}

class _BiometricGuardState extends State<BiometricGuard> {
  bool _isAuthenticated = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  // Inside lib/widgets/biometric_guard.dart

  Future<void> _checkAuth() async {
    // This now calls the Service, which updates the Singleton
    await LocalAuthService.authenticate();
    
    if (mounted) {
      setState(() {
        // Read directly from the Singleton for truth
        _isAuthenticated = AppSingleton.instance.isAuthenticated; 
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Loading State (Brief flash while checking)
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // 2. Success State (Render the Dashboard)
    if (_isAuthenticated) {
      return widget.child;
    }

    // 3. Locked State (If they hit Cancel or Fail)
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_rounded, 
              size: 80, 
              color: Theme.of(context).colorScheme.primary.withAlpha(115),
            ),
            const SizedBox(height: 24),
            const Text(
              "Greyway Secured",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Authentication required to view sensitive data.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.withAlpha(115)),
            ),
            const SizedBox(height: 48),
            
            // Unlock Button
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isLoading = true);
                  _checkAuth();
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text("Unlock Now"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}