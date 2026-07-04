import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

/// Markalı dönen halka — Flutter'da "loading indicator" / "progress indicator".
class AppLoadingIndicator extends StatefulWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 40,
    this.color,
    this.strokeWidth = 3,
    this.label,
  });

  final double size;
  final Color? color;
  final double strokeWidth;
  final String? label;

  @override
  State<AppLoadingIndicator> createState() => _AppLoadingIndicatorState();
}

class _AppLoadingIndicatorState extends State<AppLoadingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    )..repeat();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;

    final ring = SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spin, _pulse]),
        builder: (context, _) {
          return CustomPaint(
            painter: _AppLoadingRingPainter(
              rotation: _spin.value * 2 * math.pi,
              pulse: 0.55 + _pulse.value * 0.45,
              color: color,
              strokeWidth: widget.strokeWidth,
            ),
          );
        },
      ),
    );

    if (widget.label == null) return ring;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ring,
        const SizedBox(height: AppSpacing.sm),
        Text(
          widget.label!,
          style: AppTypography.textTheme().bodySmall?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.4,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _AppLoadingRingPainter extends CustomPainter {
  const _AppLoadingRingPainter({
    required this.rotation,
    required this.pulse,
    required this.color,
    required this.strokeWidth,
  });

  final double rotation;
  final double pulse;
  final Color color;
  final double strokeWidth;

  static const _sweep = 2.15;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    final innerRadius = radius * 0.38 * pulse;
    canvas.drawCircle(
      center,
      innerRadius,
      Paint()..color = color.withValues(alpha: 0.12 * pulse),
    );

    final arcPaint = Paint()
      ..shader = SweepGradient(
        startAngle: rotation,
        endAngle: rotation + _sweep,
        colors: [
          color.withValues(alpha: 0.15),
          color,
          AppColors.primaryDark,
        ],
        stops: const [0.0, 0.55, 1.0],
        transform: GradientRotation(rotation),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, rotation, _sweep, false, arcPaint);

    final tipAngle = rotation + _sweep;
    final tip = Offset(
      center.dx + radius * math.cos(tipAngle),
      center.dy + radius * math.sin(tipAngle),
    );
    canvas.drawCircle(
      tip,
      strokeWidth * 0.55,
      Paint()..color = AppColors.primaryDark,
    );
  }

  @override
  bool shouldRepaint(covariant _AppLoadingRingPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.pulse != pulse ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
