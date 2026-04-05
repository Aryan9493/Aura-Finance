import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/transactions/presentation/screens/transactions_screen.dart';
import '../../features/insights/presentation/screens/insights_screen.dart';
import '../../features/goals/presentation/screens/goals_screen.dart';
import '../../features/mood/presentation/screens/mood_screen.dart';
import '../widgets/scaffold_with_nav_bar.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
    navigatorKey: rootNavigatorKey,
    debugLogDiagnostics: true,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'dashboard',
                path: '/dashboard',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'transactions',
                path: '/transactions',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TransactionsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'insights',
                path: '/insights',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: InsightsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'goals',
                path: '/goals',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: GoalsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'mood',
                path: '/mood',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: MoodScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
