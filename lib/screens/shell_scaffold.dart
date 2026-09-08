/// Adaptive shell scaffold hosting persistent bottom or side navigation.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:byteflow/app/theme.dart';

/// Hosts the root navigation frame adapting between a mobile [NavigationBar]
/// and a tablet [NavigationRail] based on available window width.
class ShellScaffold extends StatelessWidget {
  /// Creates an adaptive [ShellScaffold] enclosing the [navigationShell].
  const ShellScaffold({
    required this.navigationShell,
    super.key,
  });

  /// The active stateful navigation shell managing branch switching.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    if (index != navigationShell.currentIndex) {
      HapticFeedback.selectionClick();
    }
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primary = colorScheme.primary;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final isDark = theme.brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 640;

        if (isWideScreen) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: _onDestinationSelected,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedActivity01,
                      color: primary,
                      size: 32,
                    ),
                  ),
                  destinations: [
                    NavigationRailDestination(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDashboardSquare02,
                        color: onSurfaceVariant,
                        size: 24,
                      ),
                      selectedIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedDashboardSquare02,
                        color: primary,
                        size: 24,
                      ),
                      label: const Text('Dashboard'),
                    ),
                    NavigationRailDestination(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedAnalytics01,
                        color: onSurfaceVariant,
                        size: 24,
                      ),
                      selectedIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedAnalytics01,
                        color: primary,
                        size: 24,
                      ),
                      label: const Text('History'),
                    ),
                    NavigationRailDestination(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedGrid,
                        color: onSurfaceVariant,
                        size: 24,
                      ),
                      selectedIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedGrid,
                        color: primary,
                        size: 24,
                      ),
                      label: const Text('Apps'),
                    ),
                    NavigationRailDestination(
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedSettings02,
                        color: onSurfaceVariant,
                        size: 24,
                      ),
                      selectedIcon: HugeIcon(
                        icon: HugeIcons.strokeRoundedSettings02,
                        color: primary,
                        size: 24,
                      ),
                      label: const Text('Settings'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: navigationShell
                      .animate(key: ValueKey(navigationShell.currentIndex))
                      .fadeIn(duration: 250.ms),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: navigationShell
              .animate(key: ValueKey(navigationShell.currentIndex))
              .fadeIn(duration: 250.ms),
          bottomNavigationBar: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: AppTheme.popupNavBorderRadius,
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.3 : 0.45,
                    ),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.45)
                          : Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20.0,
                      spreadRadius: 0.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: AppTheme.popupNavBorderRadius,
                  child: NavigationBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    height: 68.0,
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _onDestinationSelected,
                    destinations: [
                      NavigationDestination(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDashboardSquare02,
                          color: onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedDashboardSquare02,
                          color: primary,
                          size: 24,
                        ),
                        label: 'Dashboard',
                      ),
                      NavigationDestination(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedAnalytics01,
                          color: onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedAnalytics01,
                          color: primary,
                          size: 24,
                        ),
                        label: 'History',
                      ),
                      NavigationDestination(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedGrid,
                          color: onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedGrid,
                          color: primary,
                          size: 24,
                        ),
                        label: 'Apps',
                      ),
                      NavigationDestination(
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedSettings02,
                          color: onSurfaceVariant,
                          size: 24,
                        ),
                        selectedIcon: HugeIcon(
                          icon: HugeIcons.strokeRoundedSettings02,
                          color: primary,
                          size: 24,
                        ),
                        label: 'Settings',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
