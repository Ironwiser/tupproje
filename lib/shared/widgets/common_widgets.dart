import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    final radius = BorderRadius.circular(borderRadius);

    return Material(
      color: Colors.transparent,
      elevation: 4,
      shadowColor: const Color(0xFF4A0404).withValues(alpha: 0.28),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                AppAssets.fireButtonBg,
                fit: BoxFit.cover,
                alignment: const Alignment(0, -0.12),
                cacheWidth: 900,
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

/// ink + boxShadow web'de köşe hayaleti yapıyor; gölgeyi Material elevation'a taşır
class ElevationInkTile extends StatelessWidget {
  const ElevationInkTile({
    super.key,
    required this.onTap,
    required this.decoration,
    required this.child,
    this.borderRadius = AppDecorations.radiusMd,
    this.elevation = 2,
    this.shadowColor,
  });

  final VoidCallback? onTap;
  final BoxDecoration decoration;
  final Widget child;
  final double borderRadius;
  final double elevation;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    return Material(
      color: Colors.transparent,
      elevation: elevation,
      shadowColor: shadowColor ?? const Color(0x0A000000),
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Ink(
          decoration: decoration.copyWith(boxShadow: const []),
          child: child,
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

/// kalan ömür çubuğu, alım-skt aralığına göre
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

/// ana sayfa uyarı ve reklam şeridi yüksekliği
abstract final class DashboardBannerHeight {
  static const double value = 82;
}

class DashboardAdSlider extends StatefulWidget {
  const DashboardAdSlider({super.key});

  @override
  State<DashboardAdSlider> createState() => _DashboardAdSliderState();
}

class _DashboardAdSliderState extends State<DashboardAdSlider> {
  static const _autoSlideDuration = Duration(seconds: 5);

  final _pageController = PageController();
  late final Timer _autoSlideTimer;
  int _activeIndex = 0;

  static final _slides = <_DashboardAdSlide>[
    const _DashboardAdSlide(
      imageAsset: AppAssets.dashboardAdTupDolumuMock2,
    ),
    const _DashboardAdSlide(
      imageAsset: AppAssets.dashboardAdCelikburunMock2,
    ),
    const _DashboardAdSlide(
      imageAsset: AppAssets.dashboardAdKaskMock2,
    ),
    const _DashboardAdSlide(
      imageAsset: AppAssets.dashboardAdDetektorMock3,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _autoSlideTimer = Timer.periodic(_autoSlideDuration, (_) => _nextSlide());
  }

  @override
  void dispose() {
    _autoSlideTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _nextSlide() {
    if (!_pageController.hasClients || !mounted) return;
    final next = (_activeIndex + 1) % _slides.length;
    _pageController.animateToPage(
      next,
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: DashboardBannerHeight.value,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) => setState(() => _activeIndex = index),
              itemBuilder: (context, index) {
                final slide = _slides[index];
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: slide.route.isEmpty ? null : () => context.push(slide.route),
                    child: slide.imageAsset != null
                        ? _DashboardAdImageSlide(asset: slide.imageAsset!)
                        : slide.useFireSurface
                            ? FireButtonSurface(
                                borderRadius: 0,
                                child: _DashboardAdSlideContent(slide: slide),
                              )
                            : Ink(
                                decoration: slide.decoration,
                                child: _DashboardAdSlideContent(slide: slide),
                              ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_slides.length, (index) {
                final active = index == _activeIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active
                        ? AppColors.ink.withValues(alpha: 0.75)
                        : AppColors.ink.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardAdSlide {
  const _DashboardAdSlide({
    this.imageAsset,
    this.title = '',
    this.subtitle = '',
    this.icon = Icons.circle,
    this.iconColor = AppColors.textPrimary,
    this.titleColor = AppColors.textPrimary,
    this.subtitleColor = AppColors.textSecondary,
    this.route = '',
    this.decoration,
    this.useFireSurface = false,
  });

  final String? imageAsset;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final String route;
  final BoxDecoration? decoration;
  final bool useFireSurface;
}

class _DashboardAdImageSlide extends StatelessWidget {
  const _DashboardAdImageSlide({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      alignment: Alignment.center,
      cacheWidth: 900,
      errorBuilder: (_, _, _) => ColoredBox(
        color: AppColors.surfaceMuted,
        child: Center(
          child: Icon(Icons.image_not_supported_outlined, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

class _DashboardAdSlideContent extends StatelessWidget {
  const _DashboardAdSlideContent({required this.slide});

  final _DashboardAdSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.sm, AppSpacing.sm + 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: slide.useFireSurface
                  ? Colors.white.withValues(alpha: 0.16)
                  : slide.iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
            ),
            child: Icon(slide.icon, color: slide.iconColor, size: 24),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slide.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headerTitle(color: slide.titleColor).copyWith(fontSize: 15),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  slide.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.headerSubtitle(color: slide.subtitleColor).copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: slide.titleColor.withValues(alpha: 0.75),
            size: 20,
          ),
        ],
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
    return SizedBox(
      height: DashboardBannerHeight.value,
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
          child: FireButtonSurface(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$alertCount tüp yaklaşıyor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headerTitle().copyWith(
                            fontSize: 16,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${extinguisher.name} · ${extinguisher.daysUntilExpiry} gün',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headerSubtitle().copyWith(
                            fontSize: 12,
                            height: 1.1,
                          ),
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

    return ElevationInkTile(
      onTap: onTap,
      elevation: 4,
      shadowColor: AppColors.premiumGoldDeep.withValues(alpha: 0.3),
      decoration: AppDecorations.premiumGoldMetallicFill(),
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
