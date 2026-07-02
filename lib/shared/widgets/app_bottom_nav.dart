import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../features/auth/domain/user_type.dart';
import '../../features/extinguishers/providers/extinguisher_providers.dart';

enum BottomNavMode { individual, corporate }

class AppBottomNav extends ConsumerWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.mode,
  });

  final int currentIndex;
  final BottomNavMode? mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userType = ref.watch(userTypeProvider);
    final navMode = mode ??
        (userType == UserType.corporate
            ? BottomNavMode.corporate
            : BottomNavMode.individual);

    final items = navMode == BottomNavMode.corporate
        ? const [
            _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Panel'),
            _NavItem(Icons.inventory_2_outlined, Icons.inventory_2, 'Tüpler'),
            _NavItem(Icons.bar_chart_outlined, Icons.bar_chart, 'Rapor'),
            _NavItem(Icons.tune_outlined, Icons.tune, 'Ayar'),
          ]
        : const [
            _NavItem(Icons.space_dashboard_outlined, Icons.space_dashboard, 'Özet'),
            _NavItem(Icons.local_fire_department_outlined, Icons.local_fire_department, 'Tüpler'),
            _NavItem(Icons.notifications_none, Icons.notifications_active, 'Uyarı'),
            _NavItem(Icons.account_circle_outlined, Icons.account_circle, 'Profil'),
          ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final selected = i == currentIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () => navMode == BottomNavMode.corporate
                    ? _onCorporateTap(context, i)
                    : _onIndividualTap(context, i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selected ? item.selectedIcon : item.icon,
                      size: 22,
                      color: selected ? AppColors.primary : Colors.white54,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? Colors.white : Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _onIndividualTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/individual');
      case 1:
        context.go('/extinguishers');
      case 2:
        context.go('/notifications');
      case 3:
        context.go('/profile');
    }
  }

  void _onCorporateTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/corporate');
      case 1:
        context.go('/extinguishers');
      case 2:
        context.push('/subscription');
      case 3:
        context.go('/notifications');
    }
  }
}

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
