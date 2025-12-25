import 'package:fees_up/mobile/screens/auth/mobile_signup_screen.dart';
import 'package:flutter/material.dart';
// For PC, we usually want a split screen: Branding on Left, Form on Right.
// Since the user asked for "Setup School" specifically based on the image:
// I will wrap the Mobile Form in a Center Card for PC to match the uploaded image style exactly but centered.

class PCSignupScreen extends StatelessWidget {
  const PCSignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 900),
            child: const Card(
              color: Colors.transparent, 
              elevation: 0,
              // We reuse the MobileSignupScreen logic/UI because the "Setup School" 
              // image provided is vertical and works perfectly inside a PC center card.
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: MobileSignupScreen(), 
              ),
            ),
          ),
        ),
      ),
    );
  }
}