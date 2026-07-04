import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// inter font ailesi + tipografi hiyerarşisi
abstract final class AppTypography {
  static TextTheme textTheme([TextTheme? base]) {
    final theme = GoogleFonts.interTextTheme(base);
    return theme.copyWith(
      displaySmall: theme.displaySmall?.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.15,
        color: AppColors.textPrimary,
      ),
      headlineMedium: theme.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.2,
        color: AppColors.textPrimary,
      ),
      titleLarge: theme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.25,
        color: AppColors.textPrimary,
      ),
      titleMedium: theme.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        height: 1.3,
        color: AppColors.textPrimary,
      ),
      bodyLarge: theme.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textPrimary,
      ),
      bodyMedium: theme.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: AppColors.textSecondary,
      ),
      bodySmall: theme.bodySmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: AppColors.textSecondary,
      ),
      labelLarge: theme.labelLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: AppColors.textPrimary,
      ),
      labelMedium: theme.labelMedium?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: AppColors.textTertiary,
      ),
      labelSmall: theme.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textTertiary,
      ),
    );
  }

  /// kırmızı header başlıkları
  static TextStyle headerTitle({Color color = AppColors.onPrimary}) {
    return GoogleFonts.inter(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.4,
      height: 1.2,
      color: color,
    );
  }

  static TextStyle headerSubtitle({Color color = AppColors.onPrimaryMuted}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.35,
      color: color,
    );
  }

  static TextStyle sectionTitle({Color color = AppColors.textPrimary}) {
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: color,
    );
  }

  static TextStyle statValue({Color color = AppColors.onPrimary}) {
    return GoogleFonts.inter(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      height: 1,
      color: color,
    );
  }

  /// altın kart başlığı
  static const premiumGoldTextShadow = [
    Shadow(
      color: Color(0x402B2B1A),
      blurRadius: 8,
      offset: Offset(0, 1),
    ),
    Shadow(
      color: Color(0x262B2B1A),
      blurRadius: 3,
      offset: Offset(0, 0.5),
    ),
  ];

  static TextStyle premiumGoldCardTitle({Color color = AppColors.premiumGoldInk}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      height: 1.1,
      color: color,
    );
  }

  /// altın kart alt metni, geniş harf aralığı
  static TextStyle premiumGoldCardSubtitle({Color color = AppColors.premiumGoldInk}) {
    return GoogleFonts.barlow(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.6,
      height: 1.3,
      color: color,
    );
  }

  /// ana sayfa premium buton etiketi
  static TextStyle premiumGoldCtaLabel({Color color = AppColors.premiumGoldInk}) {
    return GoogleFonts.barlowCondensed(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.8,
      height: 1.1,
      color: color,
    );
  }

  static Future<void> preload() async {
    await GoogleFonts.pendingFonts([
      GoogleFonts.inter(),
      GoogleFonts.inter(fontWeight: FontWeight.w500),
      GoogleFonts.inter(fontWeight: FontWeight.w600),
      GoogleFonts.inter(fontWeight: FontWeight.w700),
      GoogleFonts.barlowCondensed(fontWeight: FontWeight.w500),
      GoogleFonts.barlow(fontWeight: FontWeight.w500),
    ]);
  }
}
