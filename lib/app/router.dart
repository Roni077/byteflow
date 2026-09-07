/// Declarative routing configuration powered by GoRouter and StatefulShellRoute.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:byteflow/screens/apps/apps_screen.dart';
import 'package:byteflow/screens/dashboard/dashboard_screen.dart';
import 'package:byteflow/screens/data_plans/data_plans_screen.dart';
import 'package:byteflow/screens/history/history_screen.dart';
import 'package:byteflow/screens/settings/permissions_screen.dart';
import 'package:byteflow/screens/settings/settings_screen.dart';
import 'package:byteflow/screens/shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// The application GoRouter instance managing tab branches and route stacks.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
          ],
        ),

        // Tab 2: History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),

        // Tab 3: Apps
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/apps',
              builder: (context, state) => const AppsScreen(),
            ),
          ],
        ),

        // Tab 4: Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'permissions',
                  builder: (context, state) => const PermissionsScreen(),
                ),
                GoRoute(
                  path: 'plans',
                  builder: (context, state) => const DataPlansScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/plans',
      redirect: (context, state) => '/settings/plans',
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Text('Route not found: ${state.uri.toString()}'),
    ),
  ),
);
