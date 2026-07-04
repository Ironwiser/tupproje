import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class FiretrackLogo extends StatelessWidget {
  const FiretrackLogo({
    super.key,
    this.size = 72,
    this.showText = true,
    this.light = false,
    this.showTagline = false,
  });

  final double size;
  final bool showText;
  final bool light;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    final markSize = size * 0.85;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomPaint(
              size: Size(markSize * 0.42, markSize),
              painter: _ExtinguisherMarkPainter(
                color: light ? AppColors.primary : AppColors.primary,
                onDark: light,
              ),
            ),
            if (showText) ...[
              SizedBox(width: size * 0.14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      color: light ? Colors.white : AppColors.ink,
                      fontSize: size * 0.28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      height: 1,
                    ),
                  ),
                  if (showTagline)
                    Padding(
                      padding: EdgeInsets.only(top: size * 0.06),
                      child: Text(
                        'Yangın güvenliği takibi',
                        style: TextStyle(
                          color: light ? Colors.white70 : AppColors.textSecondary,
                          fontSize: size * 0.14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// özgün tüp silüeti, hazır ikon yerine
class _ExtinguisherMarkPainter extends CustomPainter {
  const _ExtinguisherMarkPainter({required this.color, this.onDark = false});

  final Color color;
  final bool onDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()
      ..color = onDark ? Colors.white : color
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = onDark ? color : AppColors.primaryDark
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // gövde
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.18, h * 0.22, w * 0.64, h * 0.62),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(body, bodyPaint);

    // boyun
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.1, w * 0.32, h * 0.16),
        Radius.circular(w * 0.06),
      ),
      bodyPaint,
    );

    // tutamak
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.02, h * 0.3, w * 0.2, h * 0.08),
        const Radius.circular(2),
      ),
      accentPaint,
    );

    // hortum ucu
    canvas.drawCircle(Offset(w * 0.88, h * 0.34), w * 0.07, accentPaint);

    // etiket şeridi
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.48, w * 0.48, h * 0.1),
        Radius.circular(w * 0.02),
      ),
      Paint()..color = onDark ? color.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _ExtinguisherMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.onDark != onDark;
}
