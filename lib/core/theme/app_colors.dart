import 'package:flutter/material.dart';

/// Sıcak nötr zemin + klasik yangın tüpü kırmızısı.
abstract final class AppColors {
  static const ink = Color(0xFF16181D);
  static const inkMuted = Color(0xFF3D424C);
  static const background = Color(0xFFF3F0EA);
  static const surface = Color(0xFFFFFCF8);
  static const surfaceMuted = Color(0xFFE8E4DC);
  static const border = Color(0xFFD4CFC6);
  static const borderStrong = Color(0xFFB8B2A8);

  /// Klasik toz yangın söndürücü kırmızısı
  static const primary = Color(0xFFD71418);
  static const primaryDark = Color(0xFFA80F12);
  static const primarySoft = Color(0xFFFCE8E8);

  static const corporate = primary;
  static const corporateSoft = primarySoft;

  static const textPrimary = ink;
  static const textSecondary = Color(0xFF6B6560);
  static const textTertiary = Color(0xFF9A948C);

  static const inputFill = Color(0xFFEBE7E0);

  static const statusOk = Color(0xFF1F6B4F);
  static const statusOkSoft = Color(0xFFE3F0EA);
  static const statusWarning = Color(0xFFB8860B);
  static const statusWarningSoft = Color(0xFFF5EDD8);
  static const statusExpired = Color(0xFFB01014);
  static const statusExpiredSoft = Color(0xFFF3E4E4);

  static const splashBackground = Color(0xFF16181D);
  static const premiumGold = Color(0xFF8B6914);
  static const premiumSoft = Color(0xFFF0E8D4);
  static const renewGreen = statusOk;
}
