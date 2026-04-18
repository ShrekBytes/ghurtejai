import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/create/presentation/create_experience_screen.dart';
import '../../features/create/presentation/create_tab_screen.dart';
import '../../features/experiences/presentation/experience_detail_screen.dart';
import '../../features/experiences/presentation/experiences_screen.dart';
import '../../features/explore/presentation/all_destinations_screen.dart';
import '../../features/explore/presentation/destination_detail_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/moderation/presentation/moderation_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/public_profile_screen.dart';
import '../../features/shell/main_shell.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/explore',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/create/experience',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => CreateExperienceScreen(
          initialDestinationSlug: state.uri.queryParameters['destination'],
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExploreScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/experiences',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ExperiencesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/create',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: CreateTabScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/destinations',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AllDestinationsScreen(),
      ),
      GoRoute(
        path: '/destination/:slug',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            DestinationDetailScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/experience/:slug/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => CreateExperienceScreen(
          editSlug: state.pathParameters['slug']!,
        ),
      ),
      GoRoute(
        path: '/experience/:slug',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ExperienceDetailScreen(
          slug: state.pathParameters['slug']!,
          initialScrollToComments: state.uri.queryParameters['comments'] == '1',
        ),
      ),
      GoRoute(
        path: '/u/:username',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            PublicProfileScreen(username: state.pathParameters['username']!),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/moderation',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ModerationScreen(),
      ),
    ],
  );
});
