/// Material 3 theme configurations and color palettes for ByteFlow.
library;

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Distinct functional signal colors for download, upload, warning, and error states.
abstract final class AppColors {
  /// Secondary accent color representing live transmission / download activity (RX).
  static const Color downloadGreen = Color(0xFF00C853);

  /// Secondary accent color representing live transmission / upload activity (TX).
  static const Color uploadBlue = Color(0xFF2979FF);

  /// Functional warning color for quota threshold alerts.
  static const Color warningAmber = Color(0xFFF59E0B);

  /// Functional error color for quota exceeded states.
  static const Color errorRed = Color(0xFFDC2626);
}

/// Defines application-wide visual styling, typography, and color schemes.
abstract final class AppTheme {
  /// Primary seed color used to derive cohesive Material 3 palettes when dynamic color is unavailable.
  static const Color seedColor = Color(0xFF1E88E5);

  /// Secondary accent color representing live transmission / download activity (RX).
  static const Color rxColor = AppColors.downloadGreen;

  /// Secondary accent color representing live transmission / upload activity (TX).
  static const Color txColor = AppColors.uploadBlue;

  /// Functional warning color for quota threshold alerts.
  static const Color warningColor = AppColors.warningAmber;

  /// Functional error color for quota exceeded states.
  static const Color errorColor = AppColors.errorRed;

  /// Global border radius standard for card and container surfaces (numeric).
  static const double cardRadius = 20.0;

  /// Global border radius standard for pill badges and search bars (numeric).
  static const double pillRadius = 24.0;

  /// Global border radius standard for bottom sheets (numeric).
  static const double sheetRadius = 28.0;

  /// Global border radius standard for popup bottom navigation dock (numeric).
  static const double popupNavRadius = 24.0;

  /// Global BorderRadius standard for card and container surfaces.
  static const BorderRadius cardBorderRadius =
      BorderRadius.all(Radius.circular(cardRadius));

  /// Global BorderRadius standard for pill badges and search bars.
  static const BorderRadius pillBorderRadius =
      BorderRadius.all(Radius.circular(pillRadius));

  /// Global BorderRadius standard for bottom sheets.
  static const BorderRadius sheetBorderRadius =
      BorderRadius.vertical(top: Radius.circular(sheetRadius));

  /// Global BorderRadius standard for popup bottom navigation dock.
  static const BorderRadius popupNavBorderRadius =
      BorderRadius.all(Radius.circular(popupNavRadius));

  /// Monospaced tabular text style for counters and throughput figures to eliminate horizontal jitter.
  static TextStyle tabularMetricStyle({
    BuildContext? context,
    required double fontSize,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
    double letterSpacing = -0.5,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Backward-compatible light theme definition without dynamic color.
  static ThemeData get lightTheme => buildLightTheme(null);

  /// Backward-compatible dark theme definition without dynamic color.
  static ThemeData get darkTheme => buildDarkTheme(null);

  /// Builds the Material 3 light theme with optional wallpaper color extraction.
  static ThemeData buildLightTheme(ColorScheme? dynamicColorScheme) {
    final colorScheme = (dynamicColorScheme ??
            ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.light,
            ))
        .harmonized();

    return _buildTheme(colorScheme, Brightness.light);
  }

  /// Builds the Material 3 dark theme with optional wallpaper color extraction.
  static ThemeData buildDarkTheme(ColorScheme? dynamicColorScheme) {
    final colorScheme = (dynamicColorScheme ??
            ColorScheme.fromSeed(
              seedColor: seedColor,
              brightness: Brightness.dark,
            ))
        .harmonized();

    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final baseTextTheme = brightness == Brightness.light
        ? Typography.material2021().black
        : Typography.material2021().white;

    final textTheme = GoogleFonts.interTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        systemOverlayStyle: brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 2,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        labelType: NavigationRailLabelType.all,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
