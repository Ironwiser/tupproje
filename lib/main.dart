import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/supabase/supabase_bootstrap.dart';
import 'core/theme/app_typography.dart';
import 'app.dart';

Future<void> _preloadFonts() async {
  try {
    await AppTypography.preload();
  } catch (_) {
    // font preload patlasa da uygulama açılsın
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // fontlar internetten iner; açılışı bekletme
  unawaited(_preloadFonts());
  await bootstrapSupabase();
  runApp(
    const ProviderScope(
      child: FiretrackApp(),
    ),
  );
}
