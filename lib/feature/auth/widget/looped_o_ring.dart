import 'dart:math' as math;

import 'package:flutter/material.dart';

class LoopedORing extends StatelessWidget {
  const LoopedORing({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CustomPaint(painter: LoopedOPainter()),
    );
  }
}

class LoopedOPainter extends CustomPainter {
  const LoopedOPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = size.width * 0.46;
    const count = 26;
    for (var i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) - math.pi / 2;
      final isRed = i % 2 == 0;
      final paint = Paint()
        ..color = isRed ? const Color(0xFFE11D48) : const Color(0xFF38BDF8)
        ..strokeWidth = size.width * 0.055
        ..strokeCap = StrokeCap.round;
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + dir * (outer * 0.38),
        center + dir * outer,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
