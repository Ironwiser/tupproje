import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/corporate_dashboard_screen.dart';
import '../../features/dashboard/presentation/individual_dashboard_screen.dart';
import '../../features/extinguishers/presentation/add_edit_extinguisher_screen.dart';
import '../../features/extinguishers/presentation/extinguisher_detail_screen.dart';
import '../../features/extinguishers/presentation/expiry_calendar_screen.dart';
import '../../features/extinguishers/presentation/extinguisher_list_screen.dart';
import '../../features/notifications/presentation/notification_settings_screen.dart';
import '../../features/onboarding/presentation/user_type_screen.dart';
import '../../features/premium/presentation/premium_screen.dart';
import '../../features/premium/presentation/subscription_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

Page<void> _instantTabPage({required GoRouterState state, required Widget child}) {
  return NoTransitionPage<void>(
    key: state.pageKey,
    child: child,
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const UserTypeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return SizedBox.expand(child: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/individual',
              pageBuilder: (context, state) => _instantTabPage(
                state: state,
                child: const IndividualDashboardScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/extinguishers',
              pageBuilder: (context, state) => _instantTabPage(
                state: state,
                child: const ExtinguisherListScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddEditExtinguisherScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) =>
                      ExtinguisherDetailScreen(id: state.pathParameters['id']!),
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) =>
                          AddEditExtinguisherScreen(id: state.pathParameters['id']),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              pageBuilder: (context, state) => _instantTabPage(
                state: state,
                child: const NotificationSettingsScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => _instantTabPage(
                state: state,
                child: const ProfileScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/corporate',
      pageBuilder: (context, state) => _instantTabPage(
        state: state,
        child: const CorporateDashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/expiry-calendar',
      builder: (context, state) => const ExpiryCalendarScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionScreen(),
    ),
  ],
);
