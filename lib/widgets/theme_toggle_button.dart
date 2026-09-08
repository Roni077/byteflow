/// Fast, accessible theme toggle button with smooth icon morphing and tactile feedback.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

/// A modern, responsive theme toggle button featuring smooth sun/moon rotation and morphing,
/// tactile haptic feedback, and instant state transitions without screen freezes or flickers.
class ThemeToggleButton extends StatefulWidget {
  /// Creates a [ThemeToggleButton].
  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onToggle,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.tooltip,
    this.enableFeedback = true,
  });

  /// Whether the active theme is currently dark.
  final bool isDark;

  /// Callback executed to toggle the application theme.
  final VoidCallback onToggle;

  /// Outer dimension (width and height) of the toggle button.
  final double size;

  /// Size of the sun/moon icon.
  final double iconSize;

  /// Tooltip message displayed on hover/long-press.
  final String? tooltip;

  /// Whether to fire light tactile haptic feedback on tap.
  final bool enableFeedback;

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isDark ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(ThemeToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isDark != oldWidget.isDark) {
      if (widget.isDark) {
        _iconController.forward();
      } else {
        _iconController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.enableFeedback) {
      HapticFeedback.lightImpact();
    }
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String defaultTooltip =
        widget.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode';
    final String effectiveTooltip = widget.tooltip ?? defaultTooltip;

    return Tooltip(
      message: effectiveTooltip,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _handleTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: _iconController,
              builder: (context, child) {
                final double t = _iconController.value;
                // Spin rotation and subtle scale bounce
                final double angle = t * math.pi;
                final double scale = 1.0 - (math.sin(t * math.pi) * 0.2);

                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(
                    angle: angle,
                    child: t < 0.5
                        ? HugeIcon(
                            icon: HugeIcons.strokeRoundedSun01,
                            color: Colors.amber.shade700,
                            size: widget.iconSize,
                          )
                        : HugeIcon(
                            icon: HugeIcons.strokeRoundedMoon02,
                            color: colorScheme.primary,
                            size: widget.iconSize,
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
