import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
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

    return RedHeaderScaffold(
      headerHeight: 210,
      bottomNavigationBar: const AppBottomNav(currentIndex: 0, mode: BottomNavMode.individual),
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
                        'Merhaba, $userName',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total kayıtlı tüp',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
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
            const SizedBox(height: 20),
            Row(
              children: [
                HeaderStatChip(value: '$okCount', label: 'Uygun'),
                const SizedBox(width: 8),
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
          if (nearest != null) ...[
            AlertBannerCard(
              extinguisher: nearest,
              alertCount: approachingCount,
              onTap: () => context.push('/extinguishers/${nearest.id}'),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () => context.push('/extinguishers/add'),
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.all(16),
                    decoration: AppDecorations.bentoTile(accent: AppColors.primary, filled: true),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.add_circle_outline, color: Colors.white, size: 28),
                        Text(
                          'Yeni tüp\nekle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/extinguishers'),
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: AppDecorations.bentoTile(accent: AppColors.statusOk),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline, color: AppColors.statusOk, size: 20),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Liste',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => context.push('/premium'),
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: AppDecorations.bentoTile(accent: AppColors.premiumGold),
                        child: Row(
                          children: [
                            const PremiumBadge(),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Premium',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (extinguishers.isNotEmpty) ...[
            const SizedBox(height: 28),
            SectionLabel('Son tüpler', action: 'Tümü', onAction: () => context.go('/extinguishers')),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: extinguishers.take(6).length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final item = extinguishers[index];
                  return ExtinguisherMiniCard(
                    extinguisher: item,
                    onTap: () => context.push('/extinguishers/${item.id}'),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
