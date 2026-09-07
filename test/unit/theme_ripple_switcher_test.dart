import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/widgets/theme_ripple_switcher.dart';

void main() {
  group('ThemeRippleSwitcher Geometry & Radius Calculations', () {
    test('calculates correct max radius from top-left origin (0, 0)', () {
      const origin = Offset(0, 0);
      const size = Size(100, 200);

      final radius = calculateMaxRadius(origin, size);
      final expected = math.sqrt(100 * 100 + 200 * 200);

      expect(radius, closeTo(expected, 0.0001));
    });

    test('calculates correct max radius from screen center', () {
      const origin = Offset(50, 100);
      const size = Size(100, 200);

      final radius = calculateMaxRadius(origin, size);
      final expected = math.sqrt(50 * 50 + 100 * 100);

      expect(radius, closeTo(expected, 0.0001));
    });

    test('calculates correct max radius from bottom-right origin', () {
      const origin = Offset(100, 200);
      const size = Size(100, 200);

      final radius = calculateMaxRadius(origin, size);
      final expected = math.sqrt(100 * 100 + 200 * 200);

      expect(radius, closeTo(expected, 0.0001));
    });

    test('calculates correct max radius from arbitrary off-center coordinate', () {
      const origin = Offset(20, 180);
      const size = Size(100, 200);

      // maxDx = max(20, 80) = 80; maxDy = max(180, 20) = 180
      final radius = calculateMaxRadius(origin, size);
      final expected = math.sqrt(80 * 80 + 180 * 180);

      expect(radius, closeTo(expected, 0.0001));
    });
  });

  group('ThemeRippleSwitcher Widget Configuration', () {
    test('instantiates with expected default values', () {
      final switcher = ThemeRippleSwitcher(
        isDark: false,
        onToggle: () {},
      );

      expect(switcher.isDark, isFalse);
      expect(switcher.size, equals(44.0));
      expect(switcher.iconSize, equals(22.0));
      expect(switcher.duration, equals(const Duration(milliseconds: 550)));
      expect(switcher.curve, equals(Curves.easeInOutCubic));
      expect(switcher.enableFeedback, isTrue);
      expect(switcher.rippleColor, isNull);
    });

    test('accepts custom configuration overrides', () {
      final switcher = ThemeRippleSwitcher(
        isDark: true,
        size: 56.0,
        iconSize: 28.0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.fastOutSlowIn,
        rippleColor: Colors.amber,
        tooltip: 'Custom Toggle Tooltip',
        enableFeedback: false,
        onToggle: () {},
      );

      expect(switcher.isDark, isTrue);
      expect(switcher.size, equals(56.0));
      expect(switcher.iconSize, equals(28.0));
      expect(switcher.duration, equals(const Duration(milliseconds: 700)));
      expect(switcher.curve, equals(Curves.fastOutSlowIn));
      expect(switcher.rippleColor, equals(Colors.amber));
      expect(switcher.tooltip, equals('Custom Toggle Tooltip'));
      expect(switcher.enableFeedback, isFalse);
    });
  });
}
