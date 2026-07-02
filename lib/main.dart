import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase/supabase_bootstrap.dart';
import 'core/theme/app_typography.dart';
import 'app.dart';

Future<void> _preloadFonts() async {
  try {
    await AppTypography.preload();
  } catch (_) {
    // Font önbelleği yoksa uygulama yine de açılır.
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    bootstrapSupabase(),
    _preloadFonts(),
  ]);
  runApp(
    const ProviderScope(
      child: FiretrackApp(),
    ),
  );
}
