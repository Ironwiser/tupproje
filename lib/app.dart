import 'package:flutter/material.dart';

import 'core/auth/auth_session_listener.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class FiretrackApp extends StatelessWidget {
  const FiretrackApp({super.key});

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