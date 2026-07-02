import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../core/theme/app_colors.dart';
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

    if (isSupabaseReady && ref.read(authRepositoryProvider).currentUser != null) {
      await syncProfileToState(ref);
      await ref.read(extinguisherProvider.notifier).ensureLoaded();
      if (!mounted) return;
      final userType = ref.read(userTypeProvider) ?? UserType.individual;
      context.go(userType == UserType.corporate ? '/corporate' : '/individual');
      return;
    }

    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 11,
            child: Container(
              width: double.infinity,
              color: AppColors.primary,
              child: const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(28),
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
            child: Container(
              width: double.infinity,
              color: AppColors.background,
              child: const Padding(
                padding: EdgeInsets.fromLTRB(28, 32, 28, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Güvenlik takibi\nbasitleşti.',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: -0.8,
                        color: AppColors.ink,
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
