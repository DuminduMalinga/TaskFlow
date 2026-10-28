import 'package:flutter/material.dart';

/// The Donezo app icon: a "D" with a checkmark inside, on a navy tile.
class DonezoLogo extends StatelessWidget {
  const DonezoLogo({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Donezo logo',
      child: CustomPaint(size: Size.square(size), painter: _LogoPainter()),
    );
  }
}

/// "Donezo" set in the brand's bold geometric style.
class DonezoWordmark extends StatelessWidget {
  const DonezoWordmark({super.key, required this.color, this.fontSize = 36});

  final Color color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Donezo',
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        height: 1.1,
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  static const _navy = Color(0xFF172554);
  static const _violet = Color(0xFF8B7AF6);
  static const _sky = Color(0xFF38BDF8);

  @override
  void paint(Canvas canvas, Size size) {
    // Everything is drawn on a 100 x 100 grid, then scaled.
    canvas.scale(size.width / 100, size.height / 100);

    final tile = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 100, 100),
      const Radius.circular(22),
    );
    canvas.drawRRect(tile, Paint()..color = _navy);

    final letter = Path()
      ..moveTo(31.5, 25.2)
      ..lineTo(49.2, 25.2)
      ..arcToPoint(
        const Offset(49.2, 74.2),
        radius: const Radius.circular(24.5),
      )
      ..lineTo(31.5, 74.2)
      ..close();
    canvas.drawPath(
      letter,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.1
        ..strokeJoin = StrokeJoin.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_violet, _sky],
        ).createShader(const Rect.fromLTWH(28, 22, 50, 55)),
    );

    final check = Path()
      ..moveTo(37.1, 49.2)
      ..lineTo(45.9, 58)
      ..lineTo(63.9, 39.1);
    canvas.drawPath(
      check,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
