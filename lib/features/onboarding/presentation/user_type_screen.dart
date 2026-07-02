import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/onboarding_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../auth/domain/user_type.dart';
import '../../auth/providers/user_state_providers.dart';
import '../../../shared/widgets/firetrack_logo.dart';

class UserTypeScreen extends ConsumerWidget {
  const UserTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FiretrackLogo(size: 48, light: true, showText: true),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    'Kullanım türünü seçin',
                    style: AppTypography.headerTitle().copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Daha sonra ayarlardan değiştirebilirsiniz.',
                    style: AppTypography.headerSubtitle(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: AppDecorations.contentSheet(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.lg, AppSpacing.page, AppSpacing.md),
              child: Column(
                children: [
                  _TypeOption(
                    title: 'Bireysel',
                    description: 'Ev, daire veya tek lokasyon',
                    icon: Icons.home_work_outlined,
                    onTap: () => _select(context, ref, UserType.individual),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _TypeOption(
                    title: 'Kurumsal',
                    description: 'Çoklu tüp, lokasyon ve rapor',
                    icon: Icons.domain_outlined,
                    onTap: () => _select(context, ref, UserType.corporate),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _select(BuildContext context, WidgetRef ref, UserType type) async {
    ref.read(userTypeProvider.notifier).state = type;
    await OnboardingStorage.savePendingUserType(type);
    if (context.mounted) context.go('/login');
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Ink(
          decoration: AppDecorations.panel(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppDecorations.radiusSm),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(description, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
