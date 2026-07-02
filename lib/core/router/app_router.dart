import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/corporate_dashboard_screen.dart';
import '../../features/dashboard/presentation/individual_dashboard_screen.dart';
import '../../features/extinguishers/presentation/add_edit_extinguisher_screen.dart';
import '../../features/extinguishers/presentation/extinguisher_detail_screen.dart';
import '../../features/extinguishers/presentation/extinguisher_list_screen.dart';
import '../../features/notifications/presentation/notification_settings_screen.dart';
import '../../features/onboarding/presentation/user_type_screen.dart';
import '../../features/premium/presentation/premium_screen.dart';
import '../../features/premium/presentation/subscription_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

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
    GoRoute(
      path: '/individual',
      builder: (context, state) => const IndividualDashboardScreen(),
    ),
    GoRoute(
      path: '/corporate',
      builder: (context, state) => const CorporateDashboardScreen(),
    ),
    GoRoute(
      path: '/extinguishers',
      builder: (context, state) => const ExtinguisherListScreen(),
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
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
    GoRoute(
      path: '/premium',
      builder: (context, state) => const PremiumScreen(),
    ),
    GoRoute(
      path: '/subscription',
      builder: (context, state) => const SubscriptionScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
