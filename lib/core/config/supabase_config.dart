abstract final class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get apiKey {
    if (publishableKey.isNotEmpty) return publishableKey;
    return anonKey;
  }

  static bool get isConfigured => url.isNotEmpty && apiKey.isNotEmpty;
}
