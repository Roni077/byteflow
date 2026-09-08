/// Root application widget configuring theme, router, and Riverpod root scope.
library;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:byteflow/app/router.dart';
import 'package:byteflow/app/theme.dart';
import 'package:byteflow/providers/user_preferences_provider.dart';

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
      child: DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          return _ByteFlowMaterialApp(
            lightDynamic: lightDynamic,
            darkDynamic: darkDynamic,
          );
        },
      ),
    );
  }
}

class _ByteFlowMaterialApp extends ConsumerWidget {
  const _ByteFlowMaterialApp({
    this.lightDynamic,
    this.darkDynamic,
  });

  final ColorScheme? lightDynamic;
  final ColorScheme? darkDynamic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ByteFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildLightTheme(lightDynamic),
      darkTheme: AppTheme.buildDarkTheme(darkDynamic),
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 200),
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: appRouter,
    );
  }
}
