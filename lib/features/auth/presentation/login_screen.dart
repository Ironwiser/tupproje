import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/extensions/context_extensions.dart';
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

  bool get _useSupabase => isSupabaseReady;

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

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
      if (kIsWeb) return;

      await Future.delayed(const Duration(milliseconds: 300));
      if (ref.read(authRepositoryProvider).currentUser != null) {
        await completeLoginAfterAuth(ref);
        await ref.read(extinguisherProvider.notifier).ensureLoaded();
        if (mounted) _navigateToHome();
      }
    } catch (e) {
      if (mounted) context.showSnackBar('Google girişi başarısız: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    final userType = ref.read(userTypeProvider) ?? UserType.individual;
    context.go(userType == UserType.corporate ? '/corporate' : '/individual');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.xs, AppSpacing.md, AppSpacing.lg),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/onboarding'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text('Giriş', style: AppTypography.headerTitle()),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: AppDecorations.contentSheet(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _useSupabase ? 'Hesabınıza bağlanın' : 'Demo modu',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _useSupabase
                          ? 'Google ile hızlı giriş veya telefon numarası'
                          : 'Telefon numarası ile devam edin',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        icon: const Icon(Icons.g_mobiledata, size: 28, color: Colors.blue),
                        label: const Text('Google ile devam et'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(child: Container(height: 1, color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Text('veya telefon', style: Theme.of(context).textTheme.labelSmall),
                        ),
                        Expanded(child: Container(height: 1, color: AppColors.border)),
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
                      enabled: !_showOtp,
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
                      isLoading: _isLoading,
                      onPressed: _showOtp ? _verifyAndLogin : _sendOtp,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Devam ederek KVKK Aydınlatma Metni ve Kullanım Koşullarını kabul etmiş olursunuz.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(height: 1.5),
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
