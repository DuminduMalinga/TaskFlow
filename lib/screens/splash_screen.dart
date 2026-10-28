import 'package:flutter/material.dart';

import '../widgets/donezo_logo.dart';

/// Launch screen: logo, wordmark and tagline on deep indigo.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const background = Color(0xFF111827);

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
          Center(
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x553B82F6), Color(0x003B82F6)],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: fade,
              child: ScaleTransition(
                scale: Tween(begin: 0.92, end: 1.0).animate(fade),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DonezoLogo(size: 112),
                    SizedBox(height: 24),
                    DonezoWordmark(color: Colors.white, fontSize: 40),
                    SizedBox(height: 8),
                    Text(
                      'Make it happen.',
                      style: TextStyle(
                        color: Color(0xFFA5B4FC),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 64,
            child: Center(
              child: SizedBox(
                width: 48,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    color: Color(0xFF818CF8),
                    backgroundColor: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
