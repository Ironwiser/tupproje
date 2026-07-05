import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../../shared/widgets/app_layout.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../auth/domain/user_type.dart';
import '../../extinguishers/providers/extinguisher_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _showOtp = false;
  bool _isLoading = false;
  bool _waitingOAuth = false;

  bool get _useSupabase => isSupabaseReady;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_resumePendingOAuth());
    });
  }

  Future<void> _resumePendingOAuth() async {
    if (!_useSupabase || !mounted) return;
    if (ref.read(authRepositoryProvider).currentUser == null) return;
    setState(() {
      _isLoading = true;
      _waitingOAuth = true;
    });
    try {
      await completeLoginAfterAuth(ref);
      unawaited(ref.read(extinguisherProvider.notifier).ensureLoaded());
      if (mounted) _navigateToHome();
    } catch (e) {
      if (mounted) context.showSnackBar('Giriş tamamlanamadı: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _waitingOAuth = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.length < 10) {
      context.showSnackBar('Geçerli bir telefon numarası girin');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_useSupabase) {
        await ref.read(authRepositoryProvider).sendPhoneOtp(_phoneController.text);
        if (mounted) context.showSnackBar('Doğrulama kodu gönderildi');
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) context.showSnackBar('Doğrulama kodu gönderildi (demo)');
      }
      if (mounted) setState(() => _showOtp = true);
    } catch (e) {
      if (mounted) context.showSnackBar('SMS gönderilemedi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyAndLogin() async {
    if (_otpController.text.length < 4) {
      context.showSnackBar('Doğrulama kodunu girin');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_useSupabase) {
        await ref.read(authRepositoryProvider).verifyPhoneOtp(
              phoneDigits: _phoneController.text,
              token: _otpController.text.trim(),
            );
        await completeLoginAfterAuth(ref);
        await ref.read(extinguisherProvider.notifier).ensureLoaded();
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }
      if (mounted) _navigateToHome();
    } catch (e) {
      if (mounted) context.showSnackBar('Giriş başarısız: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!_useSupabase) {
      _navigateToHome();
      return;
    }

    setState(() {
      _isLoading = true;
      _waitingOAuth = true;
    });
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (kIsWeb) return;

      if (mounted) {
        context.showSnackBar('Tarayıcıda Google girişini tamamlayın, sonra uygulamaya dönün');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Google girişi başarısız: $e');
        setState(() {
          _isLoading = false;
          _waitingOAuth = false;
        });
      }
    }
  }

  void _navigateToHome() {
    final userType = ref.read(userTypeProvider) ?? UserType.individual;
    context.go(userType == UserType.corporate ? '/corporate' : '/individual');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return RedHeaderScaffold(
      headerBackgroundAsset: AppAssets.dashboardHeaderBg,
      headerOverlayColors: [
        AppColors.ink.withValues(alpha: 0.1),
        AppColors.primary.withValues(alpha: 0.55),
        AppColors.primaryDark.withValues(alpha: 0.8),
      ],
      header: _LoginPageHeader(
        onBack: () => context.go('/onboarding'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.md + bottomInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_useSupabase) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderStrong),
                ),
                child: Text(
                  'DEMO MODU',
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme().labelSmall?.copyWith(
                        color: AppColors.inkMuted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        fontSize: 10,
                      ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            _GoogleSignInButton(
              waiting: _waitingOAuth,
              enabled: !_isLoading,
              onPressed: _signInWithGoogle,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Expanded(child: Divider(color: AppColors.border, height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    'veya telefon',
                    style: AppTypography.textTheme().labelSmall?.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                  ),
                ),
                const Expanded(child: Divider(color: AppColors.border, height: 1)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Telefon',
                prefixText: '+90 ',
                hintText: '5XX XXX XX XX',
              ),
              enabled: !_showOtp && !_waitingOAuth,
            ),
            if (_showOtp) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Doğrulama kodu',
                  hintText: '6 haneli kod',
                  counterText: '',
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              label: _showOtp ? 'Giriş yap' : 'Kod gönder',
              isLoading: _isLoading && !_waitingOAuth,
              onPressed: _waitingOAuth ? null : (_showOtp ? _verifyAndLogin : _sendOtp),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Devam ederek KVKK Aydınlatma Metni ve Kullanım Koşullarını kabul etmiş olursunuz.',
              textAlign: TextAlign.center,
              style: AppTypography.textTheme().labelSmall?.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginPageHeader extends StatelessWidget {
  const _LoginPageHeader({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDecorations.pageHeaderContentHeight,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.xs),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary, size: 20),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.onPrimary.withValues(alpha: 0.16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.onPrimary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ADIM 2',
                  style: AppTypography.textTheme().labelSmall?.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        fontSize: 10,
                        height: 1,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Giriş yap',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.headerTitle().copyWith(
                  fontSize: 22,
                  height: 1.12,
                  letterSpacing: -0.4,
                ),
          ),
        ],
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.waiting,
    required this.enabled,
    required this.onPressed,
  });

  final bool waiting;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (waiting) ...[
                  const AppLoadingIndicator(size: 22, strokeWidth: 2.5),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Google girişi bekleniyor…',
                    style: AppTypography.textTheme().labelLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ] else ...[
                  const Icon(Icons.g_mobiledata, size: 28, color: Color(0xFF4285F4)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Google ile devam et',
                    style: AppTypography.textTheme().labelLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
