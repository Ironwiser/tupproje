import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../extinguishers/domain/extinguisher_status.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_layout.dart';

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

    return RedHeaderScaffold(
      headerHeight: 240,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, mode: BottomNavMode.corporate),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
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
                        companyName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Kurumsal güvenlik paneli',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.push('/notifications'),
                  icon: const Icon(Icons.notifications_none, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                HeaderStatChip(value: '$total', label: 'Toplam'),
                const SizedBox(width: 8),
                HeaderStatChip(value: '$okCount', label: 'Uygun'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                HeaderStatChip(value: '$approachingCount', label: 'Yaklaşan'),
                const SizedBox(width: 8),
                HeaderStatChip(value: '$expiredCount', label: 'Dolmuş'),
              ],
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppDecorations.panel(),
            child: Column(
              children: [
                const SectionLabel('Durum dağılımı'),
                SizedBox(
                  height: 180,
                  child: total == 0
                      ? const Center(child: Text('Henüz tüp yok', style: TextStyle(color: AppColors.textSecondary)))
                      : PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
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
          const SizedBox(height: 20),
          const SectionLabel('Hızlı işlemler'),
          const SizedBox(height: 12),
          Row(
            children: [
              _ActionTile(
                icon: Icons.add,
                label: 'Tüp ekle',
                onTap: () => context.push('/extinguishers/add'),
              ),
              const SizedBox(width: 10),
              _ActionTile(
                icon: Icons.list_alt,
                label: 'Tüm tüpler',
                onTap: () => context.go('/extinguishers'),
              ),
              const SizedBox(width: 10),
              _ActionTile(
                icon: Icons.download_outlined,
                label: 'Rapor',
                onTap: () => context.showSnackBar('Rapor özelliği yakında'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PieChartSectionData _pieSection(int count, int total, Color color) {
    return PieChartSectionData(
      value: count.toDouble(),
      color: color,
      title: '${((count / total) * 100).round()}%',
      radius: 46,
      titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: AppDecorations.insetPanel(color: AppColors.surface),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
