import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/storage/onboarding_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/firetrack_logo.dart';
import '../../auth/domain/user_type.dart';
import '../../auth/providers/user_state_providers.dart';

class UserTypeScreen extends ConsumerWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return RedHeaderScaffold(
      headerHeight: 188,
      headerOverlap: AppSpacing.md,
      headerBackgroundAsset: AppAssets.dashboardHeaderBg,
      headerOverlayColors: [
        AppColors.ink.withValues(alpha: 0.1),
        AppColors.primary.withValues(alpha: 0.55),
        AppColors.primaryDark.withValues(alpha: 0.8),
      ],
      header: const _OnboardingPageHeader(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.md + bottomInset,
        ),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: _PremiumTypeCard(
                  variant: _CardVariant.individual,
                  title: 'Bireysel',
                  badge: 'Kişisel',
                  description: 'Ev, daire veya tek lokasyon',
                  icon: Icons.home_work_rounded,
                  compactFeatures: true,
                  highlights: const [
                  'Tek lokasyon takibi',
                  'Son kullanma hatırlatması',
                  'Fotoğraflı tüp kaydı',
                  'SKT durumu özeti',
                  'SKT takvim görünümü',
                  'Tüp ekleme ve düzenleme',
                ],
                onTap: () => _select(context, ref, UserType.individual),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: _PremiumTypeCard(
                variant: _CardVariant.corporate,
                title: 'Kurumsal',
                badge: 'İşletme',
                description: 'Çoklu tüp, lokasyon ve rapor',
                icon: Icons.apartment_rounded,
                highlights: const [
                  'Çoklu tüp yönetimi',
                  'Lokasyon bazlı filtre',
                  'Durum bazlı filtreleme',
                  'Kurumsal özet paneli',
                  'Grafikli durum analizi',
                  'Merkezi tüp envanteri',
                ],
                onTap: () => _select(context, ref, UserType.corporate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, UserType type) async {
    ref.read(userTypeProvider.notifier).state = type;
    await OnboardingStorage.savePendingUserType(type);
    if (context.mounted) context.go('/login');
  }
}

class _OnboardingPageHeader extends StatelessWidget {
  const _OnboardingPageHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xs, AppSpacing.page, AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const FiretrackLogo(size: 42, light: true, showText: true),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ADIM 1',
                  style: AppTypography.textTheme().labelSmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        fontSize: 10,
                        height: 1,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Kullanım türünü seçin',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme().displaySmall?.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 26,
                  height: 1.08,
                  letterSpacing: -0.7,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Size en uygun modu seçin',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headerSubtitle().copyWith(
                  fontSize: 13,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}

enum _CardVariant { individual, corporate }

const _cardBorderSide = BorderSide(
  color: AppColors.border,
);

extension on _CardVariant {
  Color get badgeBg => switch (this) {
        _CardVariant.individual => AppColors.primary,
        _CardVariant.corporate => AppColors.corporateAccent,
      };

  Color get badgeText => AppColors.onPrimary;

  Color get iconBg => switch (this) {
        _CardVariant.individual => AppColors.primary,
        _CardVariant.corporate => AppColors.corporateAccent,
      };

  Color get iconFg => AppColors.onPrimary;
}

class _PremiumTypeCard extends StatelessWidget {
  const _PremiumTypeCard({
    required this.variant,
    required this.title,
    required this.badge,
    required this.description,
    required this.icon,
    required this.highlights,
    required this.onTap,
    this.compactFeatures = false,
  });

  final _CardVariant variant;
  final String title;
  final String badge;
  final String description;
  final IconData icon;
  final List<String> highlights;
  final VoidCallback onTap;
  final bool compactFeatures;

  @override
  Widget build(BuildContext context) {
    const footerHeight = 52.0;

    return ElevationInkTile(
      onTap: onTap,
      elevation: 3,
      shadowColor: AppColors.ink.withValues(alpha: 0.1),
      borderRadius: AppDecorations.radiusLg,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        child: Column(
          mainAxisSize: compactFeatures ? MainAxisSize.min : MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: variant.iconBg,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.onPrimary.withValues(alpha: 0.18),
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.xs,
                  AppSpacing.sm,
                  AppSpacing.xs,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ModeBadge(
                            label: badge,
                            variant: variant,
                            onAccent: true,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme().titleLarge?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.35,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.textTheme().bodySmall?.copyWith(
                                  color: AppColors.onPrimary.withValues(alpha: 0.82),
                                  height: 1.2,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _HeroIcon(
                      icon: icon,
                      size: 56,
                      variant: variant,
                      onAccent: true,
                    ),
                  ],
                ),
              ),
            ),
            _buildFeatureSection(),
            _CardFooter(
              title: title,
              height: footerHeight,
              variant: variant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureSection() {
    final panel = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      child: _FeaturePanel(
        highlights: highlights,
        variant: variant,
      ),
    );

    final section = DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          left: _cardBorderSide,
          right: _cardBorderSide,
        ),
      ),
      child: compactFeatures
          ? panel
          : LayoutBuilder(
              builder: (context, constraints) {
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth,
                      maxHeight: constraints.maxHeight,
                    ),
                    child: panel,
                  ),
                );
              },
            ),
    );

    if (compactFeatures) return section;
    return Expanded(child: section);
  }
}

class _FeaturePanel extends StatelessWidget {
  const _FeaturePanel({
    required this.highlights,
    required this.variant,
  });

  final List<String> highlights;
  final _CardVariant variant;

  @override
  Widget build(BuildContext context) {
    final dividerGap = highlights.length > 4 ? 3.0 : 5.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < highlights.length; i++) ...[
            if (i > 0)
              Padding(
                padding: EdgeInsets.symmetric(vertical: dividerGap),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: _cardBorderSide.color,
                ),
              ),
            _FeatureRow(label: highlights[i], variant: variant),
          ],
        ],
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({
    required this.label,
    required this.variant,
    this.onAccent = false,
  });

  final String label;
  final _CardVariant variant;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: onAccent ? AppColors.onPrimary : variant.badgeBg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.textTheme().labelSmall?.copyWith(
              color: onAccent ? variant.badgeBg : variant.badgeText,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.35,
              fontSize: 10,
              height: 1,
            ),
      ),
    );
  }
}

class _HeroIcon extends StatelessWidget {
  const _HeroIcon({
    required this.icon,
    required this.size,
    required this.variant,
    this.onAccent = false,
  });

  final IconData icon;
  final double size;
  final _CardVariant variant;
  final bool onAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: onAccent
            ? AppColors.onPrimary.withValues(alpha: 0.18)
            : variant.iconBg,
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Icon(
        icon,
        color: onAccent ? AppColors.onPrimary : variant.iconFg,
        size: size * 0.52,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.label,
    required this.variant,
  });

  final String label;
  final _CardVariant variant;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: variant.iconBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            Icons.check_rounded,
            size: 12,
            color: variant.iconFg,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.textTheme().bodySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.5,
                  height: 1.2,
                ),
          ),
        ),
      ],
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({
    required this.title,
    required this.height,
    required this.variant,
  });

  final String title;
  final double height;
  final _CardVariant variant;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: variant.iconBg,
        border: const Border(top: _cardBorderSide),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              '$title ile devam et',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTypography.textTheme().bodyMedium?.copyWith(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppColors.onPrimary,
            size: 18,
          ),
        ],
      ),
    );
  }
}
