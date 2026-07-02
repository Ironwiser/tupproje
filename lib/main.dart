import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/supabase/supabase_bootstrap.dart';
import 'app.dart';

Future<void> _preloadFonts() async {
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.plusJakartaSans(),
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
      GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w900),
    ]);
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
