import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:note_taking_app/core/values/app_colors.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';
import 'package:note_taking_app/core/values/app_images.dart';

class ButtonState {
  static const String idle = "idle";
  static const String loading = "loading";
  static const String success = "success";
}

class AnimatedSubmitButton extends StatefulWidget {
  final String text;
  final String successText;
  final RxString submitState; // 'idle' | 'loading' | 'success'
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? pillColor;
  final Color? successPillColor;
  final String? iconAsset;

  const AnimatedSubmitButton({
    super.key,
    required this.text,
    required this.successText,
    required this.submitState,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.pillColor,
    this.successPillColor,
    this.iconAsset,
  });

  @override
  State<AnimatedSubmitButton> createState() => _AnimatedSubmitButtonState();
}

class _AnimatedSubmitButtonState extends State<AnimatedSubmitButton>
    with TickerProviderStateMixin {
  late final AnimationController _submitCtrl;
  late final Animation<double> _submitExpandAnim;
  late final Animation<double> _submitLabelFadeOut;
  late final Animation<double> _submitSpinnerFadeIn;
  late final Animation<double> _submitSpinnerFadeOut;
  late final Animation<double> _successFadeIn;

  late final AnimationController _hoverCtrl;
  late final Animation<double> _arrowAngle;

  StreamSubscription<String>? _submitStateSub;

  @override
  void initState() {
    super.initState();

    // Submit Animations
    _submitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _submitLabelFadeOut = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _submitCtrl, curve: const Interval(0.0, 0.2)),
    );

    _submitExpandAnim = CurvedAnimation(
      parent: _submitCtrl,
      curve: const Interval(0.1, 0.45, curve: Curves.easeInOut),
    );

    _submitSpinnerFadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _submitCtrl, curve: const Interval(0.35, 0.55)),
    );

    _submitSpinnerFadeOut = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _submitCtrl, curve: const Interval(0.72, 0.85)),
    );

    _successFadeIn = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _submitCtrl, curve: const Interval(0.85, 1.0)),
    );

    // Arrow Hover rotation animation
    _hoverCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _arrowAngle = Tween<double>(begin: 0, end: 0.125).animate(
      CurvedAnimation(
        parent: _hoverCtrl,
        curve: const Cubic(0.34, 1.56, 0.64, 1),
      ),
    );

    // Listen to submitState RxString changes
    _submitStateSub = widget.submitState.listen(_onSubmitStateChanged);

    // Handle initial state
    _onSubmitStateChanged(widget.submitState.value);
  }

  void _onSubmitStateChanged(String state) {
    if (!mounted) return;
    setState(() {});
    if (state == 'loading') {
      _submitCtrl.animateTo(0.72, duration: const Duration(milliseconds: 900));
    } else if (state == 'success') {
      _submitCtrl.forward();
    } else if (state == 'idle') {
      _submitCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _submitStateSub?.cancel();
    _submitCtrl.dispose();
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultBg = widget.backgroundColor ?? AppColors.darkBackgroundColor;
    final defaultText = widget.textColor ?? AppColors.lightBackgroundColor;
    final defaultPill = widget.pillColor ?? AppColors.lightBackgroundColor;
    final defaultSuccessPill =
        widget.successPillColor ?? AppColors.primaryColor;
    final defaultIcon = widget.iconAsset ?? AppImages.arrowFUp;

    return _PressableButton(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => _hoverCtrl.forward(),
        onExit: (_) => _hoverCtrl.reverse(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: Listenable.merge([_submitCtrl, _hoverCtrl]),
              builder: (context, _) {
                final expand = _submitExpandAnim.value;
                final maxWidth = constraints.maxWidth;
                final maxPillWidth = maxWidth - 8;
                final circleWidth = 43.5 + (maxPillWidth - 43.5) * expand;
                const borderRadius = 50.0;

                final spinnerOpacity = widget.submitState.value == 'loading'
                    ? (_submitSpinnerFadeIn.value * _submitSpinnerFadeOut.value)
                    : 0.0;

                final pillColor = Color.lerp(
                  defaultPill,
                  defaultSuccessPill,
                  _successFadeIn.value,
                )!;

                return Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: defaultBg,
                    border: Border.all(color: defaultBg),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      // Label (fades out)
                      Positioned(
                        left: 20,
                        child: Opacity(
                          opacity: _submitLabelFadeOut.value,
                          child: Text(
                            widget.text,
                            style: AppFonts.appStyle(
                              color: defaultText,
                              fontSize: 17,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),

                      // Expanding pill
                      Positioned(
                        right: 3,
                        child: AnimatedContainer(
                          duration: Duration.zero,
                          width: circleWidth,
                          height: 43.5,
                          decoration: BoxDecoration(
                            color: pillColor,
                            borderRadius: BorderRadius.circular(borderRadius),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Arrow icon (idle state, fades out with label)
                              Opacity(
                                opacity: _submitLabelFadeOut.value,
                                child: Transform.rotate(
                                  angle: _arrowAngle.value * 2 * 3.14159,
                                  child: SvgPicture.asset(
                                    defaultIcon,
                                    width: 30,
                                    height: 30,
                                    colorFilter: ColorFilter.mode(
                                      defaultBg,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ),

                              // Spinner
                              Opacity(
                                opacity: spinnerOpacity,
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation(
                                      defaultBg,
                                    ),
                                  ),
                                ),
                              ),

                              // Success check and text (done state)
                              Opacity(
                                opacity: _successFadeIn.value,
                                child: _buildSuccessContent(defaultText),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessContent(Color textAndIconColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_rounded, color: textAndIconColor, size: 22),
        const SizedBox(width: 10),
        Text(
          widget.successText,
          style: AppFonts.appStyle(
            color: textAndIconColor,
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Spring press-feedback wrapper
// ─────────────────────────────────────────────
class _PressableButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressableButton({required this.child, this.onTap});

  @override
  State<_PressableButton> createState() => _PressableButtonState();
}

class _PressableButtonState extends State<_PressableButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
