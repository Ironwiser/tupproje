import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_session_listener.dart';
import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/firetrack_logo.dart';
import '../../auth/domain/user_type.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (!mounted) return;

    final pendingLogin = isSupabaseReady && await hasPendingLogin();

    if (isSupabaseReady) {
      // oauth dönüşünde cold start olursa deep link + oturum için daha uzun bekle
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

    // google tarayıcıdan döndü, oturum henüz gelmediyse onboarding'e atma
    if (pendingLogin) {
      context.go('/login');
      return;
    }

    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Container(
              width: double.infinity,
              color: AppColors.primary,
              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: FiretrackLogo(size: 72, light: true, showTagline: true),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 9,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Güvenlik takibi\nbasitleşti.',
                    style: AppTypography.textTheme().displaySmall,
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
