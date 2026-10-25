import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A custom squibbly, organic pulsing wave background for M3 workout interfaces.
class SquibblyWavePainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final double alpha;

  SquibblyWavePainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
    this.alpha = 0.12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final phase1 = animationValue * 2 * math.pi;
    final phase2 = animationValue * 2 * math.pi;

    // First organic undulating wave (adaptive step size for performance)
    final paint1 = Paint()
      ..color = primaryColor.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final path1 = Path();
    path1.moveTo(0, height * 0.45);

    const step = 16.0;
    for (double x = 0; x <= width; x += step) {
      final normX = x / width;
      final y = height * 0.45 +
          math.sin((normX * 2 * math.pi) + phase1) * 18 +
          math.cos((normX * 4 * math.pi) - phase1) * 10;
      path1.lineTo(x, y);
    }
    path1.lineTo(width, height);
    path1.lineTo(0, height);
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second squibbly wave
    final paint2 = Paint()
      ..color = secondaryColor.withValues(alpha: alpha * 0.8)
      ..style = PaintingStyle.fill;

    final path2 = Path();
    path2.moveTo(0, height * 0.52);

    for (double x = 0; x <= width; x += step) {
      final normX = x / width;
      final y = height * 0.52 +
          math.sin((normX * 3 * math.pi) - phase2) * 14 +
          math.cos((normX * 2 * math.pi) + phase2) * 12;
      path2.lineTo(x, y);
    }
    path2.lineTo(width, height);
    path2.lineTo(0, height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant SquibblyWavePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}

/// Squibbly wobbling circle for badges, rep counters, and celebratory icons.
class SquibblyBlobPainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final PaintingStyle style;
  final double strokeWidth;

  SquibblyBlobPainter({
    required this.animationValue,
    required this.color,
    this.style = PaintingStyle.fill,
    this.strokeWidth = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = math.min(size.width, size.height) / 2 - strokeWidth;

    final paint = Paint()
      ..color = color
      ..style = style
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    const pointsCount = 28;
    final phase = animationValue * 2 * math.pi;
    for (int i = 0; i <= pointsCount; i++) {
      final theta = (i / pointsCount) * 2 * math.pi;
      // Multi-frequency deformation for squibbly organic wobble
      final wobble = math.sin(theta * 3 + phase) * 5.0 +
          math.cos(theta * 5 - phase) * 3.5;
      final r = baseRadius + wobble;
      final x = center.dx + r * math.cos(theta);
      final y = center.dy + r * math.sin(theta);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SquibblyBlobPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.color != color;
  }
}
