import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../extinguishers/domain/extinguisher_status.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/widgets/extinguisher_card.dart';

class IndividualDashboardScreen extends ConsumerWidget {
  const IndividualDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final extinguishers = ref
        .watch(extinguisherProvider)
        .where((e) => e.companyId == null)
        .toList();

    final approaching = extinguishers
        .where((e) => e.status == ExtinguisherStatus.approaching)
        .toList();
    final okCount = extinguishers.where((e) => e.status == ExtinguisherStatus.ok).length;
    final expiredCount = extinguishers.where((e) => e.status == ExtinguisherStatus.expired).length;
    final approachingCount = approaching.length;
    final total = extinguishers.length;
    final nearest = approaching.isNotEmpty
        ? (approaching..sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry))).first
        : null;

    void openFilter(ExtinguisherFilter filter) {
      ref.read(extinguisherFilterProvider.notifier).state = filter;
      context.go('/extinguishers');
    }

    return RedHeaderScaffold(
      headerHeight: 118,
      headerOverlap: 20,
      headerBackgroundAsset: AppAssets.dashboardHeaderBg,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, mode: BottomNavMode.individual),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxs, AppSpacing.page, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Merhaba, $userName',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headerTitle().copyWith(fontSize: 18, height: 1.15),
                      ),
                      Text(
                        '$total kayıtlı tüp',
                        style: AppTypography.headerSubtitle().copyWith(fontSize: 12, height: 1.25),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary, size: 20),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.surfaceMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            Row(
              children: [
                HeaderStatChip(
                  value: '$okCount',
                  label: 'Uygun',
                  valueColor: AppColors.statusOk,
                  onTap: () => openFilter(ExtinguisherFilter.ok),
                ),
                const SizedBox(width: AppSpacing.xs),
                HeaderStatChip(
                  value: '$approachingCount',
                  label: 'Yaklaşan',
                  valueColor: AppColors.statusWarning,
                  onTap: () => openFilter(ExtinguisherFilter.approaching),
                ),
                const SizedBox(width: AppSpacing.xs),
                HeaderStatChip(
                  value: '$expiredCount',
                  label: 'Dolmuş',
                  valueColor: AppColors.statusExpired,
                  onTap: () => openFilter(ExtinguisherFilter.expired),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: AppColors.surfaceMuted,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
          children: [
            const DashboardAdSlider(),
            if (nearest != null) ...[
              const SizedBox(height: AppSpacing.xs),
              AlertBannerCard(
                extinguisher: nearest,
                alertCount: approachingCount,
                onTap: () => context.push('/extinguishers/${nearest.id}'),
              ),
              const SizedBox(height: AppSpacing.sm),
            ] else
              const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 48,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ElevationInkTile(
                      onTap: () => context.push('/expiry-calendar'),
                      decoration: AppDecorations.bentoTileFill(accent: const Color(0xFF5C6B8A)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                        child: Center(
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_outlined, color: Color(0xFF5C6B8A), size: 20),
                              const SizedBox(width: AppSpacing.xs),
                              Flexible(
                                child: Text(
                                  'SKT çizelgesi',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: PremiumCtaTile(
                      expand: true,
                      onTap: () => context.push('/premium'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
                child: InkWell(
                  onTap: () => context.push('/extinguishers/add'),
                  borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
                  child: FireButtonSurface(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'Yeni tüp ekle',
                              style: AppTypography.headerTitle().copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (extinguishers.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              SectionLabel('Son tüpler', action: 'Tümü', onAction: () => context.go('/extinguishers')),
              ...extinguishers.take(6).map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ExtinguisherMiniCard(
                    extinguisher: item,
                    stacked: true,
                    onTap: () => context.push('/extinguishers/${item.id}'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
