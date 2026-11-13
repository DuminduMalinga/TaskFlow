import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/donezo_logo.dart';

/// Launch screen: logo, wordmark and tagline on amber.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const background = AppColors.header;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return Scaffold(
      backgroundColor: SplashScreen.background,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: CustomPaint(painter: _WavePainter()),
          ),
          Center(
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: Tween(begin: 0.92, end: 1.0).animate(fade),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DonezoLogo(size: 96),
                    SizedBox(height: 20),
                    DonezoWordmark(color: AppColors.onHeader, fontSize: 36),
                    SizedBox(height: 6),
                    Text(
                      'Capture it. Do it. Done.',
                      style: TextStyle(
                        color: AppColors.onHeader,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The dark wave along the bottom edge of the splash.
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(0, h * 0.4)
      ..cubicTo(w * 0.17, h * 0.27, w * 0.35, h * 0.64, w * 0.58, h * 0.5)
      ..cubicTo(w * 0.78, h * 0.38, w * 0.87, h * 0.18, w, h * 0.27)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.onHeader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
