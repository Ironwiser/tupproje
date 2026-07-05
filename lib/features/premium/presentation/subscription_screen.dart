import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/domain/user_type.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  late UserType _planType;
  bool _yearly = true;

  @override
  void initState() {
    super.initState();
    _planType = ref.read(userTypeProvider) ?? UserType.individual;
  }

  @override
  Widget build(BuildContext context) {
    final isCorporate = ref.watch(userTypeProvider) == UserType.corporate;
    final monthlyPrice = _planType == UserType.corporate ? '99,99' : '29,99';
    final yearlyPrice = _planType == UserType.corporate ? '899,00' : '299,00';

    return RedHeaderScaffold(
      headerBackgroundAsset: AppAssets.dashboardHeaderBg,
      bottomNavigationBar: isCorporate
          ? const AppBottomNav(currentIndex: 2, mode: BottomNavMode.corporate)
          : null,
      header: ThemedPageHeader(
        title: isCorporate ? 'Rapor / Plan' : 'Paket seçimi',
        onBack: isCorporate ? null : () => context.pop(),
      ),
      body: Container(
        color: AppColors.surfaceMuted,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.lg),
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: AppDecorations.insetPanel(color: AppColors.surface),
              child: Row(
                children: [
                  _PlanTab(
                    label: 'Bireysel',
                    selected: _planType == UserType.individual,
                    onTap: () => setState(() => _planType = UserType.individual),
                  ),
                  _PlanTab(
                    label: 'Kurumsal',
                    selected: _planType == UserType.corporate,
                    onTap: () => setState(() => _planType = UserType.corporate),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Plan'),
            const SizedBox(height: AppSpacing.xs),
            _PricingCard(
              title: 'Aylık',
              price: '$monthlyPrice ₺',
              period: '/ ay',
              selected: !_yearly,
              onTap: () => setState(() => _yearly = false),
            ),
            const SizedBox(height: AppSpacing.xs),
            _PricingCard(
              title: 'Yıllık',
              price: '$yearlyPrice ₺',
              period: '/ yıl',
              badge: '%17 indirim',
              selected: _yearly,
              onTap: () => setState(() => _yearly = true),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: AppDecorations.panel(color: AppColors.surface),
              child: Column(
                children: _features(_planType)
                    .map(
                      (f) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Row(
                          children: [
                            const Icon(Icons.check, color: AppColors.primary, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(child: Text(f, style: Theme.of(context).textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Devam et',
              onPressed: () {
                ref.read(isPremiumProvider.notifier).state = true;
                ref.read(userTypeProvider.notifier).state = _planType;
                context.showSnackBar('Premium abonelik aktif edildi (demo)');
                context.go(_planType == UserType.corporate ? '/corporate' : '/individual');
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 15, color: AppColors.textTertiary),
                const SizedBox(width: AppSpacing.xs),
                Text('Güvenli ödeme altyapısı', style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _features(UserType type) {
    final base = [
      'Sınırsız tüp ekleme',
      'SMS bildirimleri',
      'Otomatik arama uyarıları',
      'Gelişmiş raporlama',
    ];
    if (type == UserType.corporate) base.add('Çoklu lokasyon yönetimi');
    return base;
  }
}

class _PlanTab extends StatelessWidget {
  const _PlanTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String period;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: AppDecorations.bentoTile(accent: AppColors.primary, filled: selected),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: selected ? Colors.white : AppColors.ink,
                        ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontSize: 24,
                              color: selected ? Colors.white : AppColors.ink,
                            ),
                      ),
                      Text(
                        period,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: selected ? Colors.white70 : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: selected ? Colors.white.withValues(alpha: 0.2) : AppColors.statusOkSoft,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.statusOk,
                  ),
                ),
              ),
            if (selected) const Icon(Icons.check_circle, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
