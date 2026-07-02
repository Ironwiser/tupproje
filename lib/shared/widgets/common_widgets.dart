import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../features/extinguishers/domain/extinguisher_status.dart';
import '../../features/extinguishers/domain/fire_extinguisher.dart';
import 'app_layout.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final ExtinguisherStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: _softBg(status),
        borderRadius: BorderRadius.circular(AppDecorations.radiusXs),
      ),
      child: Text(
        status.label.toUpperCase(),
        style: TextStyle(
          color: status.color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Color _softBg(ExtinguisherStatus status) => switch (status) {
        ExtinguisherStatus.ok => AppColors.statusOkSoft,
        ExtinguisherStatus.approaching => AppColors.statusWarningSoft,
        ExtinguisherStatus.expired => AppColors.statusExpiredSoft,
      };
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.color,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? color;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: btnColor,
            side: BorderSide(color: btnColor, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: _child(btnColor),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: btnColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: _child(Colors.white),
      ),
    );
  }

  Widget _child(Color iconColor) {
    if (isLoading) {
      return SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: iconColor),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
        Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.2),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(action!, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}

class StatusSummaryCard extends StatelessWidget {
  const StatusSummaryCard({
    super.key,
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppDecorations.bentoTile(accent: color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AlertBannerCard extends StatelessWidget {
  const AlertBannerCard({
    super.key,
    required this.extinguisher,
    required this.alertCount,
    this.onTap,
  });

  final FireExtinguisher extinguisher;
  final int alertCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppDecorations.bentoTile(accent: AppColors.primary, filled: true),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$alertCount tüp yaklaşıyor',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${extinguisher.name} · ${extinguisher.daysUntilExpiry} gün',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class ExtinguisherThumbnail extends StatelessWidget {
  const ExtinguisherThumbnail({
    super.key,
    this.photoPath,
    this.photoUrl,
    this.size = 56,
    this.square = true,
  });

  final String? photoPath;
  final String? photoUrl;
  final double size;
  final bool square;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(square ? AppDecorations.radiusSm : AppDecorations.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (photoPath != null && !photoPath!.startsWith('http')) {
      return Image.file(File(photoPath!), fit: BoxFit.cover, width: size, height: size);
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return Image.network(photoUrl!, fit: BoxFit.cover, width: size, height: size);
    }
    return Icon(Icons.local_fire_department, color: AppColors.primary, size: size * 0.45);
  }
}

class DashedPhotoPicker extends StatelessWidget {
  const DashedPhotoPicker({super.key, this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: AppDecorations.insetPanel(),
        child: photoPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(photoPath!), fit: BoxFit.cover),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.ink.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppDecorations.radiusXs),
                        ),
                        child: const Text(
                          'Değiştir',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 32, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text('Fotoğraf ekle', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ],
              ),
      ),
    );
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.premiumSoft,
        borderRadius: BorderRadius.circular(AppDecorations.radiusXs),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: AppColors.premiumGold,
        ),
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  const FormSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(title),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: AppDecorations.panel(),
          child: child,
        ),
      ],
    );
  }
}
