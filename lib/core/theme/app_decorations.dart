import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppDecorations {
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;

  static const double pagePadding = 20;
  static const double headerOverlap = 28;

  static BorderRadius get sheetTop => const BorderRadius.vertical(
        top: Radius.circular(radiusXl),
      );

  static BoxDecoration redHeader({double bottomRadius = radiusXl}) {
    return BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(bottomRadius)),
    );
  }

  static BoxDecoration contentSheet() {
    return const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
    );
  }

  static BoxDecoration panel({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radiusMd),
      boxShadow: const [
        BoxShadow(
          color: Color(0x12000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration insetPanel({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(radiusSm),
    );
  }

  static BoxDecoration bentoTile({required Color accent, bool filled = false}) {
    return BoxDecoration(
      color: filled ? accent : AppColors.surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: filled ? null : Border.all(color: accent.withValues(alpha: 0.25)),
      boxShadow: filled
          ? [
              BoxShadow(
                color: accent.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ]
          : const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
    );
  }

  static BoxDecoration statChipOnRed() {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(radiusSm),
      border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
    );
  }
}
