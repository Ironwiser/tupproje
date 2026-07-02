import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/onboarding_storage.dart';
import '../../../core/supabase/supabase_bootstrap.dart';
import '../data/auth_repository.dart';
import '../domain/user_type.dart';
import 'user_state_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

Future<void> completeLoginAfterAuth(WidgetRef ref) async {
  if (!isSupabaseReady) return;

  final auth = ref.read(authRepositoryProvider);
  if (auth.currentUser == null) return;

  final pendingType = await OnboardingStorage.getPendingUserType();
  final userType = pendingType ?? ref.read(userTypeProvider) ?? UserType.individual;

  final user = auth.currentUser!;
  final meta = user.userMetadata;
  final fullName =
      meta?['full_name'] as String? ?? meta?['name'] as String? ?? user.email;

  final profile = await auth.upsertProfileAfterLogin(
    userType: userType,
    fullName: fullName,
    companyName: ref.read(companyNameProvider),
  );

  await OnboardingStorage.clearPendingUserType();
  applyProfileToState(ref, profile);
}
