import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/common_widgets.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.premiumProtectionBg,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.ink),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.72),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xs, AppSpacing.page, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.surfaceMuted.withValues(alpha: 0.85),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'Premium',
                              style: AppTypography.headerTitle().copyWith(fontSize: 20),
                            ),
                          ),
                          const PremiumBadge(),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Kritik dönemde ekstra koruma',
                        style: AppTypography.headerSubtitle().copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.md, AppSpacing.page, AppSpacing.sm),
                    children: [
                      DecoratedBox(
                        decoration: AppDecorations.premiumGoldMetallicCard(),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 48,
                                child: Icon(
                                  Icons.phone_in_talk_outlined,
                                  color: AppColors.premiumGoldInk,
                                  size: 40,
                                  shadows: AppTypography.premiumGoldTextShadow,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'OTOMATİK ARAMA',
                                      style: AppTypography.premiumGoldCardTitle().copyWith(
                                        shadows: AppTypography.premiumGoldTextShadow,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xxs),
                                    Text(
                                      'KRİTİK DÖNEMDE SİZİ ARAYARAK UYARIR',
                                      style: AppTypography.premiumGoldCardSubtitle().copyWith(
                                        shadows: AppTypography.premiumGoldTextShadow,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GlassPanel(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: const Column(
                          children: [
                            _FeatureItem('Son kullanma tarihine 1 ay kala arama'),
                            _FeatureItem('Haftada bir otomatik arama'),
                            _FeatureItem('Kritik dönemde ekstra uyarı'),
                            _FeatureItem('SMS hatırlatmaları dahil'),
                            _FeatureItem('Sınırsız tüp ekleme', isLast: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.md),
                  child: PrimaryButton(
                    label: 'Planları gör',
                    color: AppColors.premiumGoldDark,
                    onPressed: () => context.push('/subscription'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem(this.text, {this.isLast = false});

  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.premiumGold.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(AppDecorations.radiusXs),
              border: Border.all(color: AppColors.premiumGoldBright.withValues(alpha: 0.35)),
            ),
            child: const Icon(Icons.check, color: AppColors.premiumGoldBright, size: 14),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
