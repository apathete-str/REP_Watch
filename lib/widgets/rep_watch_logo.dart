import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom animated brand logo for Rep Watch:
/// A squircle badge with an animated pulsing rep stopwatch hand,
/// an organic squibbly orbit, and high-visibility Material 3 styling.
class RepWatchLogo extends StatelessWidget {
  final double size;
  final bool animate;

  const RepWatchLogo({
    super.key,
    this.size = 48,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.asset(
          'assets/rep_logo.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            final colorScheme = Theme.of(context).colorScheme;
            return animate
                ? _AnimatedRepWatchLogo(size: size)
                : _StaticRepWatchLogo(size: size, colorScheme: colorScheme);
          },
        ),
      ),
    );
  }
}

class _AnimatedRepWatchLogo extends StatefulWidget {
  final double size;

  const _AnimatedRepWatchLogo({required this.size});

  @override
  State<_AnimatedRepWatchLogo> createState() => _AnimatedRepWatchLogoState();
}

class _AnimatedRepWatchLogoState extends State<_AnimatedRepWatchLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RepWatchLogoPainter(
            animationValue: _controller.value,
            primaryColor: colorScheme.primary,
            secondaryColor: colorScheme.secondary,
            tertiaryColor: colorScheme.tertiary,
            surfaceColor: colorScheme.primaryContainer,
          ),
        );
      },
    );
  }
}

class _StaticRepWatchLogo extends StatelessWidget {
  final double size;
  final ColorScheme colorScheme;

  const _StaticRepWatchLogo({required this.size, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _RepWatchLogoPainter(
        animationValue: 0.25,
        primaryColor: colorScheme.primary,
        secondaryColor: colorScheme.secondary,
        tertiaryColor: colorScheme.tertiary,
        surfaceColor: colorScheme.primaryContainer,
      ),
    );
  }
}

class _RepWatchLogoPainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;
  final Color secondaryColor;
  final Color tertiaryColor;
  final Color surfaceColor;

  _RepWatchLogoPainter({
    required this.animationValue,
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Squircle Background
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.38),
    );

    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRRect(rrect, bgPaint);

    // Subtle inner squircle glow
    final innerRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.08, size.width * 0.84, size.height * 0.84),
      Radius.circular(size.width * 0.32),
    );
    final innerGlowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(innerRRect, innerGlowPaint);

    // Watch Dial Ring with squibbly tick marks
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.07
      ..strokeCap = StrokeCap.round;

    final dialRadius = radius * 0.58;
    canvas.drawCircle(center, dialRadius, ringPaint);

    // Top watch push crown
    final crownPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final crownRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.13),
        width: size.width * 0.18,
        height: size.height * 0.07,
      ),
      Radius.circular(size.width * 0.04),
    );
    canvas.drawRRect(crownRect, crownPaint);

    // Animated Rep Cadence Hand
    final handAngle = (animationValue * 2 * math.pi) - (math.pi / 2);
    final handLength = dialRadius * 0.82;
    final handEnd = Offset(
      center.dx + handLength * math.cos(handAngle),
      center.dy + handLength * math.sin(handAngle),
    );

    final handPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, handEnd, handPaint);

    // Center pivot jewel
    final pivotPaint = Paint()..color = primaryColor;
    canvas.drawCircle(center, size.width * 0.06, pivotPaint);

    // Inner bright point
    final pointPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, size.width * 0.025, pointPaint);
  }

  @override
  bool shouldRepaint(covariant _RepWatchLogoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.primaryColor != primaryColor;
  }
}
