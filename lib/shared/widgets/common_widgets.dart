import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../features/extinguishers/domain/extinguisher_status.dart';
import '../../features/extinguishers/domain/fire_extinguisher.dart';
import '../extensions/context_extensions.dart';
import 'app_layout.dart';
import 'local_image.dart';
import 'storage_extinguisher_image.dart';

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = AppDecorations.radiusMd,
    this.tint,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final Color? tint;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final fill = tint ?? Colors.white;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      ),
    );
  }
}

class FireButtonSurface extends StatelessWidget {
  const FireButtonSurface({
    super.key,
    required this.child,
    this.borderRadius = AppDecorations.radiusMd,
  });

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A0404).withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.fireButtonBg,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.12),
                errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.primary),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.06),
                      Colors.black.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status, this.compact = false});

  final ExtinguisherStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.xs : 10,
        vertical: compact ? 3 : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: _softBg(status),
        borderRadius: BorderRadius.circular(AppDecorations.radiusXs),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: status.color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w600,
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

/// Kalan ömür ilerleme çubuğu (alım → son kullanma aralığına göre).
class ExtinguisherTimeBar extends StatelessWidget {
  const ExtinguisherTimeBar({
    super.key,
    required this.progress,
    required this.color,
    this.height = 5,
  });

  final double progress;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: [
            Container(color: AppColors.borderStrong),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class ExtinguisherExpirySummary extends StatelessWidget {
  const ExtinguisherExpirySummary({
    super.key,
    required this.extinguisher,
    this.showBar = true,
    this.showExpiryDate = true,
  });

  final FireExtinguisher extinguisher;
  final bool showBar;
  final bool showExpiryDate;

  String get _daysLabel {
    final days = extinguisher.daysUntilExpiry;
    if (days < 0) return '${days.abs()} gün önce doldu';
    if (days == 0) return 'Bugün doluyor';
    return '$days gün kaldı';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = extinguisher.status.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showExpiryDate) ...[
          Text(
            'Son kullanma: ${extinguisher.expiryDate.formatted}',
            style: textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xxs),
        ],
        Text(
          _daysLabel,
          style: textTheme.titleMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        if (showBar) ...[
          const SizedBox(height: AppSpacing.xs),
          ExtinguisherTimeBar(
            progress: extinguisher.remainingRatio,
            color: color,
          ),
        ],
      ],
    );
  }
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
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          color: outlined ? btnColor : AppColors.onPrimary,
        );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: btnColor,
            side: BorderSide(color: btnColor.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: _child(context, btnColor, textStyle),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
          boxShadow: onPressed == null || isLoading
              ? null
              : [
                  BoxShadow(
                    color: btnColor.withValues(alpha: 0.22),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
            ),
          ),
          onPressed: isLoading ? null : onPressed,
          child: _child(context, AppColors.onPrimary, textStyle),
        ),
      ),
    );
  }

  Widget _child(BuildContext context, Color iconColor, TextStyle? textStyle) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: iconColor),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: AppSpacing.xs)],
        Text(label, style: textStyle),
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
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (action != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(action!),
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
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: AppDecorations.bentoTile(accent: color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$count',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: FireButtonSurface(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$alertCount tüp yaklaşıyor',
                        style: AppTypography.headerTitle(),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '${extinguisher.name} · ${extinguisher.daysUntilExpiry} gün',
                        style: AppTypography.headerSubtitle(),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.8), size: 20),
              ],
            ),
          ),
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
    this.photoStoragePath,
    this.size = 56,
    this.square = true,
  });

  final String? photoPath;
  final String? photoUrl;
  final String? photoStoragePath;
  final double size;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = (photoStoragePath != null && photoStoragePath!.isNotEmpty) ||
        (photoUrl != null && photoUrl!.isNotEmpty) ||
        (photoPath != null && photoPath!.isNotEmpty);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasPhoto ? AppColors.primarySoft : AppColors.surface,
        borderRadius: BorderRadius.circular(square ? AppDecorations.radiusSm : AppDecorations.radiusMd),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: StorageExtinguisherImage(
        storagePath: photoStoragePath,
        signedUrl: photoUrl,
        localPath: photoStoragePath == null && photoUrl == null ? photoPath : null,
        size: size,
      ),
    );
  }
}

class DashedPhotoPicker extends StatelessWidget {
  const DashedPhotoPicker({
    super.key,
    this.photoPath,
    this.photoUrl,
    this.previewBytes,
    required this.onTap,
  });

  final String? photoPath;
  final String? photoUrl;
  final Uint8List? previewBytes;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final preview = _previewImage();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Ink(
          decoration: AppDecorations.insetPanel(),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: preview != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        preview,
                        Positioned(
                          right: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.ink.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(AppDecorations.radiusXs),
                            ),
                            child: Text(
                              'Değiştir',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, size: 28, color: AppColors.primary.withValues(alpha: 0.9)),
                      const SizedBox(height: AppSpacing.xs),
                      Text('Fotoğraf ekle', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget? _previewImage() {
    if (previewBytes != null) {
      return Image.memory(previewBytes!, fit: BoxFit.cover);
    }
    if (photoPath != null && !photoPath!.startsWith('http')) {
      return LocalImage(path: photoPath!, fit: BoxFit.cover);
    }
    final remoteUrl = photoUrl ?? (photoPath?.startsWith('http') == true ? photoPath : null);
    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      return Image.network(remoteUrl, fit: BoxFit.cover);
    }
    return null;
  }
}

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: AppDecorations.premiumBadge(),
      child: Text(
        'PRO',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontSize: 10,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}

class PremiumCtaTile extends StatelessWidget {
  const PremiumCtaTile({super.key, required this.onTap, this.expand = false});

  final VoidCallback onTap;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTypography.premiumGoldCtaLabel().copyWith(
      shadows: AppTypography.premiumGoldTextShadow,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Ink(
          decoration: AppDecorations.premiumGoldMetallicCard(),
          child: SizedBox(
            width: double.infinity,
            height: expand ? double.infinity : 48,
            child: Center(
              child: Transform.translate(
                offset: const Offset(-4, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.premiumGoldInk,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'PREMIUM',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        const SizedBox(height: AppSpacing.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: AppDecorations.panel(),
          child: child,
        ),
      ],
    );
  }
}
