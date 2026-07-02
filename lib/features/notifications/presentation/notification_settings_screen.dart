import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
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
    final isCorporate = ref.watch(userTypeProvider)?.name == 'corporate';
    final pushEnabled = ref.watch(pushEnabledProvider);
    final smsEnabled = ref.watch(smsEnabledProvider);
    final callEnabled = ref.watch(callEnabledProvider);
    final reminderLevel = ref.watch(reminderLevelProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Bildirimler')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SectionLabel('Kanallar'),
          const SizedBox(height: 10),
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
          const SizedBox(height: 24),
          const SectionLabel('Sıklık'),
          const SizedBox(height: 10),
          _SettingsGroup(
            children: ReminderLevel.values.map((level) {
              final selected = reminderLevel == level;
              return InkWell(
                onTap: () => ref.read(reminderLevelProvider.notifier).state = level,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                            Text(_levelLabel(level), style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              _levelDescription(level),
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
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
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppDecorations.bentoTile(accent: AppColors.premiumGold),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      PremiumBadge(),
                      SizedBox(width: 8),
                      Text('Premium ile açın', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('SMS ve otomatik arama özellikleri premium planda.'),
                  const SizedBox(height: 16),
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
      bottomNavigationBar: AppBottomNav(
        currentIndex: isCorporate ? 3 : 2,
        mode: isCorporate ? BottomNavMode.corporate : BottomNavMode.individual,
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
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            children[i],
          ],
        ],
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (premium) ...[const SizedBox(width: 8), const PremiumBadge()],
        ],
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}
