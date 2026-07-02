import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_bootstrap.dart';
import '../domain/user_profile.dart';
import '../domain/user_type.dart';
import 'auth_providers.dart';

final userTypeProvider = StateProvider<UserType?>((ref) => null);
final userNameProvider = StateProvider<String>((ref) => 'Kullanıcı');
final companyNameProvider = StateProvider<String>((ref) => 'Şirketim');
final companyIdProvider = StateProvider<String?>((ref) => null);
final isPremiumProvider = StateProvider<bool>((ref) => false);
final cachedProfileProvider = StateProvider<UserProfile?>((ref) => null);

void applyProfileToState(WidgetRef ref, UserProfile profile) {
  ref.read(cachedProfileProvider.notifier).state = profile;
  ref.read(userTypeProvider.notifier).state = profile.userType;
  ref.read(userNameProvider.notifier).state = profile.fullName ?? 'Kullanıcı';
  ref.read(companyIdProvider.notifier).state = profile.companyId;
  if (profile.companyName != null) {
    ref.read(companyNameProvider.notifier).state = profile.companyName!;
  }
  ref.read(isPremiumProvider.notifier).state = profile.isPremium;
}

void clearUserSession(WidgetRef ref) {
  ref.read(cachedProfileProvider.notifier).state = null;
  ref.read(userTypeProvider.notifier).state = null;
  ref.read(userNameProvider.notifier).state = 'Kullanıcı';
  ref.read(companyNameProvider.notifier).state = 'Şirketim';
  ref.read(companyIdProvider.notifier).state = null;
  ref.read(isPremiumProvider.notifier).state = false;
}

Future<void> syncProfileToState(WidgetRef ref) async {
  if (!isSupabaseReady) return;

  final cached = ref.read(cachedProfileProvider);
  if (cached != null) {
    applyProfileToState(ref, cached);
    return;
  }

  final profile = await ref.read(authRepositoryProvider).fetchProfile();
  if (profile == null) return;

  applyProfileToState(ref, profile);
}
