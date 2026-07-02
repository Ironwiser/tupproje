import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';

Future<void> bootstrapSupabase() async {
  if (!SupabaseConfig.isConfigured) return;

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.apiKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );
}

SupabaseClient? get supabaseClient {
  if (!SupabaseConfig.isConfigured) return null;
  return Supabase.instance.client;
}

bool get isSupabaseReady => SupabaseConfig.isConfigured && supabaseClient != null;
