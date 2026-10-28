import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/donezo_logo.dart';

/// First-run introduction. [onContinue] is called from either action.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  const DonezoLogo(size: 40),
                  const SizedBox(width: 12),
                  DonezoWordmark(color: colors.text, fontSize: 24),
                ],
              ),
              const Expanded(child: _Illustration()),
              Text(
                'Your day.\nYour way.',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Plan less in your head. Get more done in real life.',
                style: TextStyle(color: colors.muted, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.accent,
                    foregroundColor: colors.onAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: onContinue,
                  style: TextButton.styleFrom(foregroundColor: colors.muted),
                  child: const Text('I already know my way around'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Abstract scene: floating task cards, completed checks and motion trails.
class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _TrailPainter(colors.accent)),
            ),
            Positioned(
              left: 0,
              top: h * 0.12,
              child: _TaskCard(width: w * 0.62, angle: -0.08, done: true),
            ),
            Positioned(
              right: 0,
              top: h * 0.42,
              child: _TaskCard(width: w * 0.62, angle: 0.06, done: true),
            ),
            Positioned(
              left: w * 0.08,
              bottom: h * 0.04,
              child: _TaskCard(width: w * 0.5, angle: -0.04, done: false),
            ),
          ],
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.width,
    required this.angle,
    required this.done,
  });

  final double width;
  final double angle;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget line(double fraction) => FractionallySizedBox(
      widthFactor: fraction,
      alignment: Alignment.centerLeft,
      child: Container(
        height: 8,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.accent.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? colors.accent : Colors.transparent,
                border: done
                    ? null
                    : Border.all(color: colors.progressTrack, width: 2),
              ),
              child: done
                  ? Icon(Icons.check_rounded, size: 18, color: colors.onAccent)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(spacing: 8, children: [line(1), line(0.6)]),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrailPainter extends CustomPainter {
  _TrailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 3; i++) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..color = color.withValues(alpha: 0.22 - i * 0.06);
      final dy = i * 14.0;
      final path = Path()
        ..moveTo(size.width * 0.05, size.height * 0.95 - dy)
        ..cubicTo(
          size.width * 0.4,
          size.height * (0.9 - 0.1 * math.sin(i.toDouble())) - dy,
          size.width * 0.5,
          size.height * 0.3 - dy,
          size.width * 0.98,
          size.height * 0.05 - dy,
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) =>
      oldDelegate.color != color;
}
