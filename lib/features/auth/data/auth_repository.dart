import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/user_profile.dart';
import '../domain/user_type.dart';

class AuthRepository {
  static const _mobileRedirect = 'com.firetrack.firetrack://login-callback';

  SupabaseClient get _client {
    final client = supabaseClient;
    if (client == null) {
      throw StateError('Supabase yapılandırılmamış');
    }
    return client;
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> sendPhoneOtp(String phoneDigits) async {
    await _client.auth.signInWithOtp(phone: _formatPhone(phoneDigits));
  }

  Future<AuthResponse> verifyPhoneOtp({
    required String phoneDigits,
    required String token,
  }) {
    return _client.auth.verifyOTP(
      phone: _formatPhone(phoneDigits),
      token: token,
      type: OtpType.sms,
    );
  }

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: _redirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<UserProfile?> fetchProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final profile = await _client
        .from('profiles')
        .select('id, full_name, user_type, company_id, is_premium')
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) return null;

    String? companyName;
    final companyId = profile['company_id'] as String?;
    if (companyId != null) {
      final company = await _client
          .from('companies')
          .select('name')
          .eq('id', companyId)
          .maybeSingle();
      companyName = company?['name'] as String?;
    }

    return UserProfile.fromJson(profile, companyName: companyName);
  }

  Future<UserProfile> upsertProfileAfterLogin({
    required UserType userType,
    String? fullName,
    String? companyName,
  }) async {
    final user = currentUser!;
    String? companyId;

    if (userType == UserType.corporate) {
      final existing = await _client
          .from('profiles')
          .select('company_id')
          .eq('id', user.id)
          .maybeSingle();

      companyId = existing?['company_id'] as String?;

      if (companyId == null) {
        final company = await _client
            .from('companies')
            .insert({
              'name': companyName ?? 'Şirketim',
              'owner_id': user.id,
            })
            .select('id')
            .single();
        companyId = company['id'] as String;
      }
    }

    await _client.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName ?? _displayNameFromUser(user),
      'user_type': userType.name,
      'company_id': companyId,
      'updated_at': DateTime.now().toIso8601String(),
    });

    final profile = await fetchProfile();
    return profile!;
  }

  String get _redirectUrl {
    if (kIsWeb) {
      final base = Uri.base;
      return '${base.origin}${base.path}';
    }
    return _mobileRedirect;
  }

  String _displayNameFromUser(User user) {
    final meta = user.userMetadata;
    if (meta != null) {
      final name = meta['full_name'] as String? ?? meta['name'] as String?;
      if (name != null && name.isNotEmpty) return name;
    }
    return user.email ?? user.phone ?? 'Kullanıcı';
  }

  String _formatPhone(String digits) {
    final cleaned = digits.replaceAll(RegExp(r'\D'), '');
    if (cleaned.startsWith('90')) return '+$cleaned';
    if (cleaned.startsWith('0')) return '+9$cleaned';
    return '+90$cleaned';
  }
}
