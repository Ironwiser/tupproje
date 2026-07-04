import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../router/app_router.dart';
import '../storage/onboarding_storage.dart';
import '../supabase/supabase_bootstrap.dart';
import '../../features/auth/domain/user_type.dart';
import '../../features/extinguishers/providers/extinguisher_providers.dart';

/// mobil google oauth: tarayıcıdan dönen deep link + oturum olayını yakalar
class AuthSessionListener extends ConsumerStatefulWidget {
  const AuthSessionListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthSessionListener> createState() => _AuthSessionListenerState();
}

class _AuthSessionListenerState extends ConsumerState<AuthSessionListener>
    with WidgetsBindingObserver {
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<Uri>? _linkSubscription;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapAuth());
    });
  }

  Future<void> _bootstrapAuth() async {
    if (!isSupabaseReady || !mounted) return;

    _authSubscription = ref.read(authRepositoryProvider).authStateChanges.listen(
      (state) {
        if (state.session == null) return;
        if (state.event == AuthChangeEvent.signedIn ||
            state.event == AuthChangeEvent.initialSession ||
            state.event == AuthChangeEvent.tokenRefreshed) {
          unawaited(_completeOAuthSignIn());
        }
      },
      onError: (Object error) {
        debugPrint('Auth dinleyici hatası: $error');
      },
    );

    // cold start: supabase mobil tarafta getInitialLink çağırmıyor, biz işliyoruz
    await recoverOAuthSessionFromDeepLink();

    if (ref.read(authRepositoryProvider).currentUser != null) {
      unawaited(_completeOAuthSignIn());
    }

    if (!kIsWeb) {
      _linkSubscription = AppLinks().uriLinkStream.listen(
        (uri) => unawaited(_handleAuthUri(uri)),
        onError: (Object error) => debugPrint('Deep link hatası: $error'),
      );
    }
  }

  Future<void> _handleAuthUri(Uri uri) async {
    if (!isAuthCallbackUri(uri) || !isSupabaseReady) return;
    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
      await _completeOAuthSignIn();
    } catch (error, stack) {
      debugPrint('OAuth deep link işlenemedi: $error\n$stack');
    }
  }

  Future<void> _completeOAuthSignIn() async {
    if (!mounted || !isSupabaseReady || _completing) return;
    if (ref.read(authRepositoryProvider).currentUser == null) return;

    final current = appRouter.state.uri.path;
    // zaten ana sayfadaysa tekrar işleme
    if (current == '/individual' || current == '/corporate') return;

    _completing = true;
    try {
      await completeLoginAfterAuth(ref);
      unawaited(ref.read(extinguisherProvider.notifier).ensureLoaded());

      if (!mounted) return;

      final userType = ref.read(userTypeProvider) ?? UserType.individual;
      final target = userType == UserType.corporate ? '/corporate' : '/individual';
      appRouter.go(target);
    } catch (error, stack) {
      debugPrint('OAuth sonrası giriş tamamlanamadı: $error\n$stack');
    } finally {
      _completing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_onResumed());
    }
  }

  Future<void> _onResumed() async {
    if (!isSupabaseReady) return;
    // tarayıcıdan dönünce oturum gecikmeli gelebilir
    for (var i = 0; i < 20; i++) {
      if (ref.read(authRepositoryProvider).currentUser != null) {
        await _completeOAuthSignIn();
        return;
      }
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_authSubscription?.cancel());
    unawaited(_linkSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

bool isAuthCallbackUri(Uri uri) {
  final fragment = Uri.splitQueryString(uri.fragment);
  bool has(String key) =>
      uri.queryParameters.containsKey(key) || fragment.containsKey(key);
  return has('access_token') || has('code') || has('error_description');
}

/// cold start / resume: oauth callback uri varsa oturuma çevir
Future<bool> recoverOAuthSessionFromDeepLink() async {
  if (!isSupabaseReady || kIsWeb) return false;

  try {
    final initial = await AppLinks().getInitialLink();
    if (initial != null && isAuthCallbackUri(initial)) {
      await Supabase.instance.client.auth.getSessionFromUrl(initial);
      return supabaseClient?.auth.currentUser != null;
    }
  } catch (error, stack) {
    debugPrint('Initial deep link okunamadı: $error\n$stack');
  }
  return false;
}

/// splash: oturum veya oauth dönüşü için bekle
Future<bool> waitForSupabaseSession(
  WidgetRef ref, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  if (!isSupabaseReady) return false;

  await recoverOAuthSessionFromDeepLink();

  final auth = ref.read(authRepositoryProvider);
  if (auth.currentUser != null) return true;

  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (auth.currentUser != null) return true;
    await Future.delayed(const Duration(milliseconds: 150));
  }
  return auth.currentUser != null;
}

/// giriş yarım kaldıysa onboarding yerine login'e dön
Future<bool> hasPendingLogin() async {
  final pending = await OnboardingStorage.getPendingUserType();
  return pending != null;
}
