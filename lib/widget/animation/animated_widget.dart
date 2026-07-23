import 'package:flutter/material.dart';

enum SlideFrom { left, right, top, bottom, none }

class CustomAnimatedWidget extends StatefulWidget {
  final Widget child;

  /// Delay before starting animation (ms)
  final int delay;

  /// Animation duration (ms)
  final int duration;

  /// Slide direction
  final SlideFrom from;

  /// Slide distance in px
  final double distance;

  /// Add small scale pop
  final bool pop;

  const CustomAnimatedWidget({
    super.key,
    required this.child,
    this.delay = 0,
    this.duration = 450,
    this.from = SlideFrom.bottom,
    this.distance = 18,
    this.pop = false,
  });

  @override
  State<CustomAnimatedWidget> createState() => _CustomAnimatedWidgetState();
}

class _CustomAnimatedWidgetState extends State<CustomAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );

    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

    _fade = Tween<double>(begin: 0, end: 1).animate(curve);

    _slide = Tween<Offset>(
      begin: _beginOffset(widget.from, widget.distance),
      end: Offset.zero,
    ).animate(curve);

    _scale = Tween<double>(
      begin: widget.pop ? 0.98 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutBack));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _c.forward();
    });
  }

  Offset _beginOffset(SlideFrom from, double d) {
    switch (from) {
      case SlideFrom.left:
        return Offset(-d, 0);
      case SlideFrom.right:
        return Offset(d, 0);
      case SlideFrom.top:
        return Offset(0, -d);
      case SlideFrom.bottom:
        return Offset(0, d);
      case SlideFrom.none:
        return Offset.zero;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        // Convert px offset into translation
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: _slide.value,
            child: Transform.scale(scale: _scale.value, child: child),
          ),
        );
      },
    );
  }
}
