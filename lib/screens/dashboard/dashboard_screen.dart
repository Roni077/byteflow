/// Main real-time network monitoring dashboard screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/providers/user_preferences_provider.dart';
import 'package:byteflow/widgets/connection_badge.dart';
import 'package:byteflow/widgets/speed_card.dart';
import 'package:byteflow/widgets/theme_toggle_button.dart';
import 'package:byteflow/widgets/usage_summary_card.dart';

/// The primary dashboard displaying real-time throughput and connection health.
///
/// Implements adaptive responsive layouts for phones and tablets without triggering
/// full screen rebuilds on 1 Hz speed update cycles.
class DashboardScreen extends StatelessWidget {
  /// Creates a [DashboardScreen] widget.
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ByteFlow Dashboard'),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final themeMode = ref.watch(themeModeProvider);
              final isDark = themeMode == ThemeMode.dark ||
                  (themeMode == ThemeMode.system &&
                      MediaQuery.platformBrightnessOf(context) ==
                          Brightness.dark);

              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: ThemeToggleButton(
                  isDark: isDark,
                  onToggle: () {
                    final nextMode =
                        isDark ? ThemeMode.light : ThemeMode.dark;
                    ref
                        .read(userPreferencesProvider.notifier)
                        .setThemeMode(nextMode);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 640;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: isWideScreen
                  ? _buildWideLayout(context)
                  : _buildCompactLayout(context),
            ),
          );
        },
      ),
    );
  }

  /// Compact single-column scrollable view optimized for mobile phone displays.
  Widget _buildCompactLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ConnectionBadge()
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.05, end: 0),
          const SizedBox(height: 12),
          const SpeedCard()
              .animate()
              .fadeIn(duration: 350.ms, delay: 50.ms)
              .slideY(begin: 0.05, end: 0),
          const SizedBox(height: 12),
          const UsageSummaryCard()
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .slideY(begin: 0.05, end: 0),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Adaptive dual-column side-by-side view optimized for tablets and wide displays.
  Widget _buildWideLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: Active transport & Real-time Throughput
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const ConnectionBadge()
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.05, end: 0),
                const SizedBox(height: 16),
                const SpeedCard()
                    .animate()
                    .fadeIn(duration: 350.ms, delay: 50.ms)
                    .slideY(begin: 0.05, end: 0),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Right Column: Aggregated Usage Statistics & Breakdown
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const UsageSummaryCard()
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.05, end: 0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
