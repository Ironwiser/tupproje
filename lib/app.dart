import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_session_listener.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/app_layout.dart';

class FiretrackApp extends ConsumerStatefulWidget {
  const FiretrackApp({super.key});

  @override
  ConsumerState<FiretrackApp> createState() => _FiretrackAppState();
}

class _FiretrackAppState extends ConsumerState<FiretrackApp> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheRedHeaderBackground(context);
  }

  @override
  Widget build(BuildContext context) {
    return AuthSessionListener(
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: appRouter,
      ),
    );
  }
}
