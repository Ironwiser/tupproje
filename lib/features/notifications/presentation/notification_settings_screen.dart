import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/domain/user_type.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';

enum ReminderLevel { normal, intense, critical }

final pushEnabledProvider = StateProvider<bool>((ref) => true);
final smsEnabledProvider = StateProvider<bool>((ref) => false);
final callEnabledProvider = StateProvider<bool>((ref) => false);
final reminderLevelProvider =
    StateProvider<ReminderLevel>((ref) => ReminderLevel.critical);

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final isCorporate = ref.watch(userTypeProvider) == UserType.corporate;
    final pushEnabled = ref.watch(pushEnabledProvider);
    final smsEnabled = ref.watch(smsEnabledProvider);
    final callEnabled = ref.watch(callEnabledProvider);
    final reminderLevel = ref.watch(reminderLevelProvider);

    return RedHeaderScaffold(
      headerBackgroundAsset: AppAssets.dashboardHeaderBg,
      bottomNavigationBar: AppBottomNav(
        currentIndex: isCorporate ? 3 : 2,
        mode: isCorporate ? BottomNavMode.corporate : BottomNavMode.individual,
      ),
      header: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xxs, AppSpacing.page, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Bildirimler',
            style: AppTypography.headerTitle().copyWith(fontSize: 20, height: 1.15),
          ),
        ),
      ),
      body: Container(
        color: AppColors.surfaceMuted,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, AppSpacing.md),
          children: [
            const SectionLabel('Kanallar'),
            const SizedBox(height: AppSpacing.xs),
            _SettingsGroup(
              children: [
                _SwitchTile(
                  title: 'Push bildirim',
                  subtitle: 'Anlık uygulama uyarıları',
                  value: pushEnabled,
                  onChanged: (v) => ref.read(pushEnabledProvider.notifier).state = v,
                ),
                _SwitchTile(
                  title: 'SMS',
                  subtitle: 'SKT yaklaşınca mesaj',
                  value: smsEnabled && isPremium,
                  premium: !isPremium,
                  onChanged: isPremium
                      ? (v) => ref.read(smsEnabledProvider.notifier).state = v
                      : (_) => context.push('/premium'),
                ),
                _SwitchTile(
                  title: 'Otomatik arama',
                  subtitle: 'Kritik dönemde sesli uyarı',
                  value: callEnabled && isPremium,
                  premium: !isPremium,
                  onChanged: isPremium
                      ? (v) => ref.read(callEnabledProvider.notifier).state = v
                      : (_) => context.push('/premium'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionLabel('Sıklık'),
            const SizedBox(height: AppSpacing.xs),
            _SettingsGroup(
              children: ReminderLevel.values.map((level) {
                final selected = reminderLevel == level;
                return InkWell(
                  onTap: () => ref.read(reminderLevelProvider.notifier).state = level,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? AppColors.primary : AppColors.borderStrong,
                              width: selected ? 6 : 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _levelLabel(level),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                              ),
                              Text(
                                _levelDescription(level),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (!isPremium) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: AppDecorations.bentoTile(accent: AppColors.premiumGold),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const PremiumBadge(),
                        const SizedBox(width: AppSpacing.xs),
                        Text('Premium ile açın', style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'SMS ve otomatik arama özellikleri premium planda.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    PrimaryButton(
                      label: 'Planları gör',
                      onPressed: () => context.push('/subscription'),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _levelLabel(ReminderLevel level) => switch (level) {
        ReminderLevel.normal => 'Normal',
        ReminderLevel.intense => 'Yoğun',
        ReminderLevel.critical => 'Kritik',
      };

  String _levelDescription(ReminderLevel level) => switch (level) {
        ReminderLevel.normal => '30 ve 7 gün kala',
        ReminderLevel.intense => '30, 14, 7 ve 3 gün kala',
        ReminderLevel.critical => 'Her kritik günde tekrar',
      };
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.panel(),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.premium = false,
  });

  final String title;
  final String subtitle;
  final bool value;
  final bool premium;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15)),
          if (premium) ...[const SizedBox(width: AppSpacing.xs), const PremiumBadge()],
        ],
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
