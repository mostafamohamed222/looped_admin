import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Circular mark with red / cyan / navy segments (placeholder for brand asset).
class DashboardLogoMark extends StatelessWidget {
  const DashboardLogoMark({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingSegmentsPainter(),
      ),
    );
  }
}

class _RingSegmentsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.shortestSide * 0.19;
    final radius = (size.shortestSide - stroke) / 2;

    final segments = <({Color color, double start, double sweep})>[
      (color: const Color(0xFFE11D48), start: -math.pi / 2, sweep: math.pi * 2 / 3),
      (color: const Color(0xFF7DD3FC), start: math.pi / 6, sweep: math.pi * 2 / 3),
      (color: const Color(0xFF1E3A5F), start: 5 * math.pi / 6, sweep: math.pi * 2 / 3),
    ];

    for (final s in segments) {
      final paint = Paint()
        ..color = s.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        s.start,
        s.sweep,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
