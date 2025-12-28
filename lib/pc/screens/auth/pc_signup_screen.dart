import 'package:fees_up/mobile/screens/auth/mobile_signup_screen.dart';
import 'package:flutter/material.dart';

class PCSignupScreen extends StatelessWidget {
  final bool initialIsLogin; 

  const PCSignupScreen({
    super.key, 
    this.initialIsLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. BACKGROUND LAYER with CustomPaint
          CustomPaint(
            painter: WaveBackgroundPainter(),
            size: Size.infinite,
          ),

          // 2. CONTENT LAYER
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
                maxHeight: 900,
              ),
              child: Card(
                // Use a slightly transparent dark color to blend with your theme
                // Fixed: withAlpha expects an int, converted (0.9 * 255) to int
                color: const Color(0xFF0F172A).withAlpha((0.9 * 255).toInt()), 
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  // Fixed: withAlpha expects an int
                  side: BorderSide(color: Colors.white.withAlpha((0.1 * 255).toInt())),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  child: MobileAuthScreen(initialIsLogin: initialIsLogin), 
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Background gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0f1729),
        Color(0xFF280a2a),
      ],
    );
    paint.shader = backgroundGradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Wave 1
    final wave1Path = Path();
    wave1Path.moveTo(0, size.height);
    wave1Path.cubicTo(
      size.width * 0.1, size.height * 0.65,
      size.width * 0.3, size.height * 0.45,
      size.width * 0.5, size.height * 0.5,
    );
    wave1Path.cubicTo(
      size.width * 0.7, size.height * 0.55,
      size.width * 0.9, size.height * 0.6,
      size.width, size.height * 0.45,
    );
    wave1Path.lineTo(size.width, size.height);
    wave1Path.lineTo(0, size.height);
    wave1Path.close();

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF263a69).withAlpha((0.9 * 255).toInt()),
        const Color(0xFF692e69).withAlpha((0.9 * 255).toInt()),
      ],
    ).createShader(rect);
    canvas.drawPath(wave1Path, paint);

    // Wave 2
    final wave2Path = Path();
    wave2Path.moveTo(0, size.height);
    wave2Path.cubicTo(
      size.width * 0.15, size.height * 0.7,
      size.width * 0.35, size.height * 0.55,
      size.width * 0.5, size.height * 0.6,
    );
    wave2Path.cubicTo(
      size.width * 0.65, size.height * 0.65,
      size.width * 0.85, size.height * 0.7,
      size.width, size.height * 0.55,
    );
    wave2Path.lineTo(size.width, size.height);
    wave2Path.lineTo(0, size.height);
    wave2Path.close();

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF324c8a).withAlpha((0.9 * 255).toInt()),
        const Color(0xFF8a3c8a).withAlpha((0.9 * 255).toInt()),
      ],
    ).createShader(rect);
    canvas.drawPath(wave2Path, paint);

    // Wave 3 (Additional wave)
    final wave3Path = Path();
    wave3Path.moveTo(0, size.height);
    wave3Path.cubicTo(
      size.width * 0.2, size.height * 0.8,
      size.width * 0.4, size.height * 0.65,
      size.width * 0.5, size.height * 0.7,
    );
    wave3Path.cubicTo(
      size.width * 0.6, size.height * 0.75,
      size.width * 0.8, size.height * 0.8,
      size.width, size.height * 0.65,
    );
    wave3Path.lineTo(size.width, size.height);
    wave3Path.lineTo(0, size.height);
    wave3Path.close();

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF1b294a).withAlpha((0.9 * 255).toInt()),
        const Color(0xFF4a1f4a).withAlpha((0.9 * 255).toInt()),
      ],
    ).createShader(rect);
    canvas.drawPath(wave3Path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}