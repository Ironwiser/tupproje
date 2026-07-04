import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session_listener.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/firetrack_logo.dart';
import '../../auth/domain/user_type.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeIn;
  late final Animation<double> _contentOpacity;

  @override
  void initState() {
    super.initState();
    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _contentOpacity = CurvedAnimation(parent: _fadeIn, curve: Curves.easeOut);
    _fadeIn.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;

    final pendingLogin = isSupabaseReady && await hasPendingLogin();

    if (isSupabaseReady) {
      await waitForSupabaseSession(
        ref,
        timeout: pendingLogin ? const Duration(seconds: 10) : const Duration(seconds: 2),
      );
    }

    if (!mounted) return;

    if (isSupabaseReady && ref.read(authRepositoryProvider).currentUser != null) {
      await syncProfileToState(ref);
      unawaited(ref.read(extinguisherProvider.notifier).ensureLoaded());
      if (!mounted) return;
      final userType = ref.read(userTypeProvider) ?? UserType.individual;
      context.go(userType == UserType.corporate ? '/corporate' : '/individual');
      return;
    }

    if (pendingLogin) {
      context.go('/login');
      return;
    }

    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _contentOpacity,
      child: RedHeaderScaffold(
        headerHeight: 248,
        headerOverlap: AppSpacing.lg,
        headerBackgroundAsset: AppAssets.dashboardHeaderBg,
        headerOverlayColors: [
          AppColors.primary.withValues(alpha: 0.52),
          AppColors.primaryDark.withValues(alpha: 0.78),
        ],
        header: const Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: FiretrackLogo(size: 72, light: true, showTagline: true),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Güvenlik takibi\nbasitleşti.',
                style: AppTypography.textTheme().displaySmall?.copyWith(
                      height: 1.12,
                      letterSpacing: -0.4,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Kontrol+ hazırlanıyor…',
                style: AppTypography.textTheme().bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const Spacer(),
              const Center(
                child: AppLoadingIndicator(
                  size: 44,
                  strokeWidth: 3.2,
                  label: 'Yükleniyor',
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
