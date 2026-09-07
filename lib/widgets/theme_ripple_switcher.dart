/// Reusable circular ripple & reveal theme switcher for Flutter.
///
/// Provides smooth, physics-inspired circular reveal transitions between Light and Dark
/// themes originating directly from the toggle button's global coordinates.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

/// Calculates the maximum diagonal distance from an [origin] point to any of the
/// four corners of a viewport of [size].
double calculateMaxRadius(Offset origin, Size size) {
  final double maxDx = math.max(origin.dx, size.width - origin.dx);
  final double maxDy = math.max(origin.dy, size.height - origin.dy);
  return math.sqrt(maxDx * maxDx + maxDy * maxDy);
}

/// A root boundary widget that captures a snapshot of the application screen
/// using a [RepaintBoundary] before a theme toggle takes place.
///
/// Wrap your root [MaterialApp.router] `builder` or root screen with this widget
/// to enable full-screen dual-theme snapshot circular reveal transitions.
class ThemeRevealBoundary extends StatefulWidget {
  /// Creates a [ThemeRevealBoundary] enclosing [child].
  const ThemeRevealBoundary({
    super.key,
    required this.child,
  });

  /// The widget subtree to snapshot during theme transitions.
  final Widget child;

  /// Retrieves the nearest [ThemeRevealBoundaryState] in the widget tree, if present.
  static ThemeRevealBoundaryState? of(BuildContext context) {
    return context.findAncestorStateOfType<ThemeRevealBoundaryState>();
  }

  @override
  State<ThemeRevealBoundary> createState() => ThemeRevealBoundaryState();
}

/// State for [ThemeRevealBoundary] managing snapshot acquisition.
class ThemeRevealBoundaryState extends State<ThemeRevealBoundary> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  /// Captures an uncompressed [ui.Image] snapshot of the enclosed subtree.
  Future<ui.Image?> captureSnapshot() async {
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null || !boundary.hasSize) return null;
      final pixelRatio = MediaQuery.of(context).devicePixelRatio;
      return await boundary.toImage(pixelRatio: pixelRatio);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: widget.child,
    );
  }
}

/// A modern, interactive theme toggle button featuring smooth sun/moon morphing,
/// tactile haptics, and a full-screen circular reveal animation expanding from
/// its exact screen coordinates.
///
/// Usage:
/// ```dart
/// ThemeRippleSwitcher(
///   isDark: isDark,
///   onToggle: () {
///     setState(() {
///       isDark = !isDark;
///     });
///   },
/// )
/// ```
class ThemeRippleSwitcher extends StatefulWidget {
  /// Creates a [ThemeRippleSwitcher].
  const ThemeRippleSwitcher({
    super.key,
    required this.isDark,
    required this.onToggle,
    this.size = 44.0,
    this.iconSize = 22.0,
    this.duration = const Duration(milliseconds: 550),
    this.curve = Curves.easeInOutCubic,
    this.rippleColor,
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

  /// Duration of the circular reveal animation across the screen.
  final Duration duration;

  /// Motion curve governing the expanding circle.
  final Curve curve;

  /// Optional color for the glowing ripple wavefront ring.
  /// If null, defaults to [ColorScheme.primary].
  final Color? rippleColor;

  /// Tooltip message displayed on hover/long-press.
  final String? tooltip;

  /// Whether to fire light tactile haptic feedback on tap.
  final bool enableFeedback;

  @override
  State<ThemeRippleSwitcher> createState() => _ThemeRippleSwitcherState();
}

class _ThemeRippleSwitcherState extends State<ThemeRippleSwitcher>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconController;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: widget.isDark ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(ThemeRippleSwitcher oldWidget) {
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

  Future<void> _handleTap() async {
    if (_isAnimating) return;

    if (widget.enableFeedback) {
      HapticFeedback.lightImpact();
    }

    // 1. Capture origin position from RenderBox
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final Offset origin = renderBox != null
        ? renderBox.localToGlobal(renderBox.size.center(Offset.zero))
        : MediaQuery.of(context).size.center(Offset.zero);

    // 2. Respect Accessibility (Reduced Motion)
    final bool disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      widget.onToggle();
      return;
    }

    _isAnimating = true;

    // 3. Attempt snapshot capture from ThemeRevealBoundary
    final boundaryState = ThemeRevealBoundary.of(context);
    final ui.Image? snapshot = await boundaryState?.captureSnapshot();

    if (!mounted) {
      _isAnimating = false;
      return;
    }

    // 4. Trigger the theme toggle immediately so underlying widgets rebuild
    widget.onToggle();

    // 5. Present the full-screen circular reveal overlay
    final overlayState = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;

    final Color effectiveRippleColor =
        widget.rippleColor ?? Theme.of(context).colorScheme.primary;

    entry = OverlayEntry(
      builder: (overlayContext) {
        return _CircularThemeRevealOverlay(
          origin: origin,
          snapshot: snapshot,
          duration: widget.duration,
          curve: widget.curve,
          rippleColor: effectiveRippleColor,
          fallbackColor: widget.isDark
              ? Colors.white
              : const Color(0xFF121212),
          onComplete: () {
            entry.remove();
            entry.dispose();
            snapshot?.dispose();
            if (mounted) {
              setState(() {
                _isAnimating = false;
              });
            } else {
              _isAnimating = false;
            }
          },
        );
      },
    );

    overlayState.insert(entry);
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
          onTap: _isAnimating ? null : _handleTap,
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
                // Spin rotation and scale bounce
                final double angle = t * math.pi;
                final double scale = 1.0 - (math.sin(t * math.pi) * 0.25);

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

/// The overlay widget rendering the circular mask cutout and glowing wavefront ripple.
class _CircularThemeRevealOverlay extends StatefulWidget {
  const _CircularThemeRevealOverlay({
    required this.origin,
    required this.snapshot,
    required this.duration,
    required this.curve,
    required this.rippleColor,
    required this.fallbackColor,
    required this.onComplete,
  });

  final Offset origin;
  final ui.Image? snapshot;
  final Duration duration;
  final Curve curve;
  final Color rippleColor;
  final Color fallbackColor;
  final VoidCallback onComplete;

  @override
  State<_CircularThemeRevealOverlay> createState() =>
      _CircularThemeRevealOverlayState();
}

class _CircularThemeRevealOverlayState extends State<_CircularThemeRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = calculateMaxRadius(widget.origin, size);

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final double currentRadius = _animation.value * maxRadius;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. Previous screen snapshot with expanding cutout hole
              if (widget.snapshot != null)
                ClipPath(
                  clipper: _InvertedCircleClipper(
                    origin: widget.origin,
                    radius: currentRadius,
                  ),
                  child: RawImage(
                    image: widget.snapshot,
                    width: size.width,
                    height: size.height,
                    fit: BoxFit.fill,
                  ),
                )
              else
                // Fallback radial ink disc if snapshot is unavailable
                ClipPath(
                  clipper: _DirectCircleClipper(
                    origin: widget.origin,
                    radius: currentRadius,
                  ),
                  child: Container(
                    color: widget.fallbackColor.withValues(
                      alpha: (1.0 - _animation.value * 0.5).clamp(0.0, 1.0),
                    ),
                  ),
                ),

              // 2. Luminous wavefront ripple ring along the perimeter
              CustomPaint(
                size: size,
                painter: _RippleWavePainter(
                  origin: widget.origin,
                  radius: currentRadius,
                  maxRadius: maxRadius,
                  progress: _animation.value,
                  color: widget.rippleColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Inverted circular clipper cutting out an expanding circular window
/// using [PathFillType.evenOdd].
class _InvertedCircleClipper extends CustomClipper<Path> {
  const _InvertedCircleClipper({
    required this.origin,
    required this.radius,
  });

  final Offset origin;
  final double radius;

  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: origin, radius: math.max(0, radius)))
      ..fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(_InvertedCircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.origin != origin;
  }
}

/// Regular circular clipper expanding from an origin.
class _DirectCircleClipper extends CustomClipper<Path> {
  const _DirectCircleClipper({
    required this.origin,
    required this.radius,
  });

  final Offset origin;
  final double radius;

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(center: origin, radius: math.max(0, radius)));
  }

  @override
  bool shouldReclip(_DirectCircleClipper oldClipper) {
    return oldClipper.radius != radius || oldClipper.origin != origin;
  }
}

/// Paints an expressive luminous wavefront ring along the boundary of the expanding circle.
class _RippleWavePainter extends CustomPainter {
  const _RippleWavePainter({
    required this.origin,
    required this.radius,
    required this.maxRadius,
    required this.progress,
    required this.color,
  });

  final Offset origin;
  final double radius;
  final double maxRadius;
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (radius <= 0.0 || progress >= 1.0) return;

    // Fade curve: swell quickly, then fade gracefully as the circle clears the screen
    final double opacity = (math.sin(progress * math.pi)).clamp(0.0, 1.0);
    if (opacity <= 0.001) return;

    // Outer soft aura
    final Paint auraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0 * (1.0 - progress * 0.5)
      ..color = color.withValues(alpha: opacity * 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    canvas.drawCircle(origin, radius, auraPaint);

    // Inner sharp wavefront
    final Paint wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 * (1.0 - progress * 0.4)
      ..color = color.withValues(alpha: opacity * 0.65);

    canvas.drawCircle(origin, radius, wavePaint);
  }

  @override
  bool shouldRepaint(_RippleWavePainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.origin != origin;
  }
}
