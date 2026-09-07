/// Root application widget configuring theme, router, and Riverpod root scope.
library;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/app/router.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/providers/user_preferences_provider.dart';
import 'package:byteflow/widgets/theme_ripple_switcher.dart';

/// The root application widget for ByteFlow.
class ByteFlowApp extends StatelessWidget {
  /// Creates the root [ByteFlowApp] widget with optional provider [overrides].
  const ByteFlowApp({super.key, this.overrides = const []});

  /// Riverpod provider overrides for testing or initialization.
  final List<Override> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: const _ByteFlowMaterialApp(),
    );
  }
}

class _ByteFlowMaterialApp extends ConsumerWidget {
  const _ByteFlowMaterialApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'ByteFlow',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildLightTheme(lightDynamic),
          darkTheme: AppTheme.buildDarkTheme(darkDynamic),
          themeMode: themeMode,
          routerConfig: appRouter,
          builder: (context, child) {
            return ThemeRevealBoundary(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
