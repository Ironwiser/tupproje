import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppDecorations {
  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 24;

  static const double pagePadding = AppSpacing.page;
  static const double headerOverlap = AppSpacing.md;

  static List<BoxShadow> get shadowSm => const [
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => const [
        BoxShadow(
          color: Color(0x0F000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ];

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
      border: Border.all(color: AppColors.border),
      boxShadow: shadowSm,
    );
  }

  static BoxDecoration insetPanel({Color? color}) {
    return BoxDecoration(
      color: color ?? AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(radiusSm),
      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
    );
  }

  static BoxDecoration bentoTile({required Color accent, bool filled = false}) {
    return BoxDecoration(
      color: filled ? accent : AppColors.surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: filled ? null : Border.all(color: accent.withValues(alpha: 0.2)),
      boxShadow: filled
          ? [
              BoxShadow(
                color: accent.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : shadowSm,
    );
  }

  /// bentoTile dolgusu — gölge Material elevation ile verilir (web köşe hayaleti olmasın)
  static BoxDecoration bentoTileFill({required Color accent, bool filled = false}) {
    return BoxDecoration(
      color: filled ? accent : AppColors.surface,
      borderRadius: BorderRadius.circular(radiusMd),
      border: filled ? null : Border.all(color: accent.withValues(alpha: 0.2)),
    );
  }

  static BoxDecoration premiumTile() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.premiumGoldBright,
          AppColors.premiumGold,
        ],
      ),
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      boxShadow: [
        BoxShadow(
          color: AppColors.premiumGoldDark.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  /// metalik altın gradyan, kenar bronz orta parlak
  static BoxDecoration premiumGoldMetallicCard() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.premiumGoldDeep,
          AppColors.premiumGoldEdge,
          AppColors.premiumGoldShine,
          AppColors.premiumGoldEdge,
          AppColors.premiumGoldDeep,
        ],
        stops: [0.0, 0.22, 0.5, 0.78, 1.0],
      ),
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      boxShadow: [
        BoxShadow(
          color: AppColors.premiumGoldDeep.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// premiumGoldMetallicCard dolgusu — gölge Material elevation ile verilir
  static BoxDecoration premiumGoldMetallicFill() {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppColors.premiumGoldDeep,
          AppColors.premiumGoldEdge,
          AppColors.premiumGoldShine,
          AppColors.premiumGoldEdge,
          AppColors.premiumGoldDeep,
        ],
        stops: [0.0, 0.22, 0.5, 0.78, 1.0],
      ),
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
    );
  }

  static BoxDecoration premiumBadge() {
    return BoxDecoration(
      color: AppColors.premiumGoldDark,
      borderRadius: BorderRadius.circular(radiusXs),
    );
  }

  static BoxDecoration statChipOnRed() {
    return BoxDecoration(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(radiusSm),
      border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      boxShadow: shadowSm,
    );
  }
}
