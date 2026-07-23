import 'package:flutter/material.dart';

/// Sweeps a widget into view from left → right using a clip reveal.
/// Matches the `_bigBrandReveal` animation from FaqScreen exactly.
///
/// Example:
/// ```dart
/// BigBrandReveal(
///   delay: Duration(milliseconds: 800),
///   child: FittedBox(
///     child: Text(
///       'khtextify.',
///       style: TextStyle(fontSize: 999, fontWeight: FontWeight.bold),
///     ),
///   ),
/// )
/// ```
class BigBrandReveal extends StatefulWidget {
  const BigBrandReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 900),
    this.curve = const Interval(0.1, 1.0, curve: Cubic(0.22, 1.0, 0.36, 1.0)),
    this.autoPlay = true,
    this.controller,
  });

  final Widget child;

  /// Delay before the sweep starts.
  final Duration delay;

  /// Total duration of the reveal.
  final Duration duration;

  /// Curve controlling the sweep speed. Defaults to a spring starting at 10%.
  final Curve curve;

  /// Auto-start on mount. Set false when driving via [controller].
  final bool autoPlay;

  /// Optional external controller to sync with other animations.
  final AnimationController? controller;

  @override
  State<BigBrandReveal> createState() => _BigBrandRevealState();
}

class _BigBrandRevealState extends State<BigBrandReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _reveal;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _ctrl = widget.controller!;
      _ownsController = false;
    } else {
      _ctrl = AnimationController(vsync: this, duration: widget.duration);
      _ownsController = true;
    }

    _reveal = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _ctrl, curve: widget.curve));

    if (widget.autoPlay && _ownsController) {
      if (widget.delay == Duration.zero) {
        _ctrl.forward();
      } else {
        Future.delayed(widget.delay, () {
          if (mounted) _ctrl.forward();
        });
      }
    }
  }

  @override
  void dispose() {
    if (_ownsController) _ctrl.dispose();
    super.dispose();
  }

  /// Replay from scratch.
  void replay() => _ctrl.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _reveal,
      builder: (_, child) => ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: _reveal.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
