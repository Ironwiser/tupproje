import 'package:flutter/material.dart';

/// nötr zemin + marka kırmızısı
abstract final class AppColors {
  static const ink = Color(0xFF111111);
  static const inkMuted = Color(0xFF3A3A3C);
  static const background = Color(0xFFF5F5F3);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0F0EE);
  static const border = Color(0xFFE8E8E6);
  static const borderStrong = Color(0xFFD4D4D2);

  static const primary = Color(0xFF901418);
  static const primaryDark = Color(0xFF6E1012);
  static const primarySoft = Color(0xFFFDF0F0);

  static const corporate = primary;
  static const corporateSoft = primarySoft;
  /// kurumsal vurgu — bireysel kırmızıdan ayrı, güven veren lacivert
  static const corporateAccent = Color(0xFF2A4260);

  static const textPrimary = ink;
  static const textSecondary = Color(0xFF6E6E73);
  static const textTertiary = Color(0xFF8E8E93);

  static const inputFill = Color(0xFFFAFAF8);

  static const statusOk = Color(0xFF1A7F5A);
  static const statusOkSoft = Color(0xFFE8F5EF);
  static const statusWarning = Color(0xFFB8860B);
  static const statusWarningSoft = Color(0xFFF8F2E4);
  static const statusExpired = Color(0xFFB01014);
  static const statusExpiredSoft = Color(0xFFF9EBEB);

  static const splashBackground = Color(0xFF111111);
  static const premiumGold = Color(0xFFFFB300);
  static const premiumGoldDark = Color(0xFFE69500);
  static const premiumGoldLight = Color(0xFFFFF3C4);
  static const premiumGoldBright = Color(0xFFFFD54F);
  static const premiumGoldEdge = Color(0xFFB8860B);
  static const premiumGoldDeep = Color(0xFF966919);
  static const premiumGoldShine = Color(0xFFF9D423);
  static const premiumSoft = Color(0xFFFFF8E1);
  static const premiumGoldInk = Color(0xFF2B2B1A);
  static const renewGreen = statusOk;

  static const onPrimary = Colors.white;
  static const onPrimaryMuted = Color(0xE6FFFFFF);
}
