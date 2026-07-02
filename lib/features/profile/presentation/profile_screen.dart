import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/supabase/supabase_bootstrap.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(userNameProvider);
    final isPremium = ref.watch(isPremiumProvider);
    final initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return RedHeaderScaffold(
      headerHeight: 160,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3, mode: BottomNavMode.individual),
      header: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              userName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              isPremium ? 'Premium üye' : 'Ücretsiz plan',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          _MenuRow(
            icon: Icons.notifications_outlined,
            title: 'Bildirim ayarları',
            onTap: () => context.push('/notifications'),
          ),
          _MenuRow(
            icon: Icons.workspace_premium_outlined,
            title: 'Premium',
            trailing: isPremium ? const PremiumBadge() : null,
            onTap: () => context.push('/premium'),
          ),
          _MenuRow(icon: Icons.shield_outlined, title: 'Gizlilik ve KVKK', onTap: () {}),
          _MenuRow(icon: Icons.help_outline, title: 'Yardım', onTap: () {}),
          const SizedBox(height: 28),
          PrimaryButton(
            label: 'Çıkış yap',
            color: AppColors.inkMuted,
            onPressed: () async {
              if (isSupabaseReady) {
                await ref.read(authRepositoryProvider).signOut();
              }
              clearUserSession(ref);
              ref.read(extinguisherProvider.notifier).reset();
              if (context.mounted) context.go('/onboarding');
            },
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(icon, color: AppColors.primary, size: 22),
                  const SizedBox(width: 14),
                  Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
                  if (trailing != null) trailing!,
                  const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
