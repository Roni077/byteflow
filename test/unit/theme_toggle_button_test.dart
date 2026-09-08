import 'package:flutter_test/flutter_test.dart';
import 'package:byteflow/widgets/theme_toggle_button.dart';

void main() {
  group('ThemeToggleButton Widget Configuration', () {
    test('instantiates with expected default values', () {
      final button = ThemeToggleButton(
        isDark: false,
        onToggle: () {},
      );

      expect(button.isDark, isFalse);
      expect(button.size, equals(44.0));
      expect(button.iconSize, equals(22.0));
      expect(button.enableFeedback, isTrue);
      expect(button.tooltip, isNull);
    });

    test('accepts custom configuration overrides', () {
      bool toggled = false;
      final button = ThemeToggleButton(
        isDark: true,
        size: 38.0,
        iconSize: 18.0,
        tooltip: 'Custom Tooltip',
        enableFeedback: false,
        onToggle: () {
          toggled = true;
        },
      );

      expect(button.isDark, isTrue);
      expect(button.size, equals(38.0));
      expect(button.iconSize, equals(18.0));
      expect(button.tooltip, equals('Custom Tooltip'));
      expect(button.enableFeedback, isFalse);

      button.onToggle();
      expect(toggled, isTrue);
    });
  });
}
