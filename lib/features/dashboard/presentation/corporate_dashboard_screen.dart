import 'package:fl_chart/fl_chart.dart';
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
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';

class CorporateDashboardScreen extends ConsumerWidget {
  const CorporateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companyName = ref.watch(companyNameProvider);
    final extinguishers = ref
        .watch(extinguisherProvider)
        .where((e) => e.companyId != null)
        .toList();

    final total = extinguishers.length;
    final okCount = extinguishers.where((e) => e.status == ExtinguisherStatus.ok).length;
    final approachingCount =
        extinguishers.where((e) => e.status == ExtinguisherStatus.approaching).length;
    final expiredCount =
        extinguishers.where((e) => e.status == ExtinguisherStatus.expired).length;

    void openFilter(ExtinguisherFilter filter) {
      ref.read(extinguisherFilterProvider.notifier).state = filter;
      context.go('/extinguishers');
    }

    return RedHeaderScaffold(
      headerBackgroundAsset: AppAssets.dashboardHeaderBg,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, mode: BottomNavMode.corporate),
      header: SizedBox(
        height: AppDecorations.pageHeaderContentHeight,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.headerTitle().copyWith(fontSize: 18, height: 1.15),
                      ),
                      Text(
                        'Kurumsal güvenlik paneli · $total tüp',
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
            Row(
              children: [
                HeaderStatChip(
                  value: '$total',
                  label: 'Toplam',
                  onTap: () => openFilter(ExtinguisherFilter.all),
                ),
                const SizedBox(width: AppSpacing.xs),
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
      ),
      body: Container(
        color: AppColors.surfaceMuted,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: AppDecorations.panel(),
              child: Column(
                children: [
                  const SectionLabel('Durum dağılımı'),
                  SizedBox(
                    height: 180,
                    child: total == 0
                        ? Center(
                            child: Text(
                              'Henüz tüp yok',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          )
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 48,
                              sections: [
                                if (okCount > 0)
                                  _pieSection(okCount, total, AppColors.statusOk),
                                if (approachingCount > 0)
                                  _pieSection(approachingCount, total, AppColors.statusWarning),
                                if (expiredCount > 0)
                                  _pieSection(expiredCount, total, AppColors.statusExpired),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _ActionTile(
                  icon: Icons.list_alt,
                  label: 'Tüm tüpler',
                  onTap: () => context.go('/extinguishers'),
                ),
                const SizedBox(width: AppSpacing.xs),
                _ActionTile(
                  icon: Icons.download_outlined,
                  label: 'Rapor',
                  onTap: () => context.showSnackBar('Rapor özelliği yakında'),
                ),
              ],
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
          ],
        ),
      ),
    );
  }

  PieChartSectionData _pieSection(int count, int total, Color color) {
    return PieChartSectionData(
      value: count.toDouble(),
      color: color,
      title: '${((count / total) * 100).round()}%',
      radius: 44,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
          child: Ink(
            decoration: AppDecorations.insetPanel(color: AppColors.surface),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Column(
                children: [
                  Icon(icon, color: AppColors.primary, size: 22),
                  const SizedBox(height: AppSpacing.xs),
                  Text(label, style: Theme.of(context).textTheme.labelSmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
