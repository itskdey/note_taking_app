import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:note_taking_app/core/values/app_colors.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

// usage:
//
// FullWidthDropdownButton.rich(
//   iconAsset: AppImages.scanQr,
//   iconSize: 20,
//   openIconAsset: AppImages.close,
//   openIconTurns: 0.25, // 90 degrees
//   dropdownItems: [
//     DropdownItem(
//       label: "ប្រភេទអាហារ",
//       leading: Icon(Icons.restaurant_rounded, size: 16),
//       subItems: ["សុប", "អាំង", "ឆា"],
//     ),
//     DropdownItem(
//       label: "ប្រភេទសាច់",
//       leading: SvgPicture.asset(
//         AppImages.scanQr,
//         width: 16,
//         height: 16,
//         colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
//       ),
//       subItems: ["សាច់គោ", "សាច់មាន់", "សាច់ជ្រូក"],
//     ),
//     DropdownItem(label: "ពេញនិយម"), // no leading = number
//
//     // Destructive parent item.
//     DropdownItem(
//       label: "Clear all",
//       isDestructible: true,
//       leading: Icon(Icons.delete_outline_rounded, size: 16),
//     ),
//
//     // Destructive sub-item.
//     DropdownItem(
//       label: "Settings",
//       leading: Icon(Icons.settings_rounded, size: 16),
//       subItems: [
//         "Edit",
//         DropdownSubItem(label: "Delete", isDestructible: true),
//         DropdownSubItem(label: "Clear", isDestructible: true),
//       ],
//     ),
//   ],
//   onItemSelected: (parent, sub) {
//     if (sub != null) {
//       print('$parent › $sub');
//     } else {
//       print(parent);
//     }
//   },
// );

class DropdownItem {
  const DropdownItem({
    required this.label,
    this.leading,
    this.subItems = const [],
    this.isDestructible = false,
  });

  factory DropdownItem.simple(String label) => DropdownItem(label: label);

  final String label;

  /// Optional leading widget.
  /// If null, dropdown will show number: 1, 2, 3...
  final Widget? leading;

  /// Keep this dynamic so old code like:
  /// subItems: ["Edit", "Delete"]
  /// still works.
  ///
  /// For red delete/clear sub-items, use:
  /// subItems: [
  ///   DropdownSubItem(label: "Delete", isDestructible: true),
  /// ]
  final List<dynamic> subItems;

  /// Use this for delete, clear, remove, reset, etc.
  final bool isDestructible;

  bool get hasSubItems => subItems.isNotEmpty;
}

class DropdownSubItem {
  const DropdownSubItem({required this.label, this.isDestructible = false});

  factory DropdownSubItem.simple(String label) => DropdownSubItem(label: label);

  final String label;

  /// Use this for delete, clear, remove, reset, etc.
  final bool isDestructible;
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class FullWidthDropdownButton extends StatefulWidget {
  FullWidthDropdownButton({
    super.key,
    required this.iconAsset,
    this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(14),
    this.decoration,
    this.openDecoration,
    this.iconColor,
    this.openIconColor,
    this.iconSize,
    this.openIconAsset,
    this.openIconTurns,
    required List<String> items,
    required ValueChanged<String> onSelected,
    this.selectedItem,
    this.onClose,
  }) : dropdownItems = items.map(DropdownItem.simple).toList(),
       onItemSelected = ((parent, sub) => onSelected(sub ?? parent));

  const FullWidthDropdownButton.rich({
    super.key,
    required this.iconAsset,
    this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(14),
    this.decoration,
    this.openDecoration,
    required this.dropdownItems,
    required this.onItemSelected,
    this.selectedItem,
    this.onClose,
    this.iconColor,
    this.openIconColor,
    this.iconSize,
    this.openIconAsset,
    this.openIconTurns,
  });

  final String iconAsset;
  final String? openIconAsset;
  final double? iconSize;

  /// Rotation applied while the dropdown is open.
  /// One full turn is 360°, so 0.25 is 90° and 0.5 is 180°.
  final double? openIconTurns;
  final List<DropdownItem> dropdownItems;
  final void Function(String parent, String? sub) onItemSelected;
  final String? selectedItem;
  final VoidCallback? onClose;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final BoxDecoration? openDecoration;
  final Color? iconColor;
  final Color? openIconColor;

  @override
  State<FullWidthDropdownButton> createState() =>
      _FullWidthDropdownButtonState();
}

// ---------------------------------------------------------------------------
// Button state
// ---------------------------------------------------------------------------

class _FullWidthDropdownButtonState extends State<FullWidthDropdownButton>
    with TickerProviderStateMixin {
  OverlayEntry? _entry;
  bool _isOpen = false;

  late final AnimationController _pressController;
  late final Animation<double> _pressScale;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  @override
  void initState() {
    super.initState();

    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );

    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseOpacity = Tween<double>(begin: 0.0, end: 0.18).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _toggle() async {
    HapticFeedback.lightImpact();
    await _pressController.forward();
    _pressController.reverse();

    _isOpen ? _closeDropdown() : _openDropdown();
  }

  void _openDropdown() {
    setState(() => _isOpen = true);
    FocusScope.of(context).unfocus();
    _show();
  }

  void _closeDropdown() {
    if (!_isOpen) return;

    setState(() => _isOpen = false);
    _hide();
    widget.onClose?.call();
  }

  void _hide() {
    _entry?.remove();
    _entry = null;
  }

  void _show() {
    final overlay = Overlay.of(context);
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    _entry = OverlayEntry(
      builder: (context) {
        final screenW = MediaQuery.of(context).size.width;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeDropdown,
                behavior: HitTestBehavior.translucent,
                child: const SizedBox.expand(),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              top: offset.dy + size.height + 12,
              child: _AnimatedDropdownPanel(
                items: widget.dropdownItems,
                screenWidth: screenW,
                onSelected: (parent, sub) {
                  widget.onItemSelected(parent, sub);
                  _closeDropdown();
                },
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_entry!);
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressScale, _pulseOpacity]),
        builder: (context, child) {
          return Transform.scale(
            scale: _pressScale.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              width: widget.width,
              height: widget.height,
              padding: widget.padding,
              decoration: _isOpen
                  ? widget.openDecoration ??
                        BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.warmShadow,
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        )
                  : widget.decoration ??
                        BoxDecoration(
                          color: context.noteChipBackgroundColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
              child: _buildIcon(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    final openIconAsset = widget.openIconAsset;
    final Widget icon;
    if (!_isOpen && widget.child != null) {
      icon = widget.child!;
    } else if (_isOpen && openIconAsset == null && widget.child != null) {
      icon = widget.child!;
    } else {
      icon = SvgPicture.asset(
        _isOpen ? openIconAsset ?? widget.iconAsset : widget.iconAsset,
        width: widget.iconSize,
        height: widget.iconSize,
        colorFilter: ColorFilter.mode(
          _isOpen
              ? widget.openIconColor ?? Colors.white
              : widget.iconColor ?? context.noteTextSecondaryColor,
          BlendMode.srcIn,
        ),
      );
    }

    return AnimatedRotation(
      turns: _isOpen ? widget.openIconTurns ?? 0 : 0,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
      child: icon,
    );
  }
}

// ---------------------------------------------------------------------------
// Animated Dropdown Panel
// ---------------------------------------------------------------------------

class _AnimatedDropdownPanel extends StatefulWidget {
  const _AnimatedDropdownPanel({
    required this.items,
    required this.screenWidth,
    required this.onSelected,
  });

  final List<DropdownItem> items;
  final double screenWidth;
  final void Function(String parent, String? sub) onSelected;

  @override
  State<_AnimatedDropdownPanel> createState() => _AnimatedDropdownPanelState();
}

class _AnimatedDropdownPanelState extends State<_AnimatedDropdownPanel>
    with TickerProviderStateMixin {
  static const Color _destructibleColor = Color(0xFFE53935);

  late final AnimationController _panelController;
  late final Animation<double> _scaleY;
  late final Animation<double> _opacity;

  late final List<AnimationController> _itemControllers;
  late final List<Animation<Offset>> _itemSlide;
  late final List<Animation<double>> _itemOpacity;
  late final List<AnimationController> _subControllers;

  int? _hoveredIndex;
  int? _hoveredSubKey;
  int? _expandedIndex;

  @override
  void initState() {
    super.initState();

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _scaleY = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _panelController, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _panelController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _itemControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 280),
      ),
    );

    _itemSlide = _itemControllers
        .map(
          (c) => Tween<Offset>(
            begin: const Offset(0, -0.25),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOutCubic)),
        )
        .toList();

    _itemOpacity = _itemControllers
        .map(
          (c) => Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)),
        )
        .toList();

    _subControllers = List.generate(
      widget.items.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 260),
      ),
    );

    _panelController.forward();

    for (var i = 0; i < _itemControllers.length; i++) {
      Future.delayed(Duration(milliseconds: 80 + i * 55), () {
        if (mounted) _itemControllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    _panelController.dispose();

    for (final c in _itemControllers) {
      c.dispose();
    }

    for (final c in _subControllers) {
      c.dispose();
    }

    super.dispose();
  }

  DropdownSubItem _subItemFrom(dynamic value) {
    if (value is DropdownSubItem) return value;
    return DropdownSubItem.simple(value.toString());
  }

  void _toggleExpand(int i) {
    if (!widget.items[i].hasSubItems) return;

    setState(() {
      if (_expandedIndex == i) {
        _subControllers[i].reverse();
        _expandedIndex = null;
      } else {
        if (_expandedIndex != null) {
          _subControllers[_expandedIndex!].reverse();
        }

        _expandedIndex = i;
        _subControllers[i].forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _panelController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform(
            transform: Matrix4.identity()
              ..translateByDouble(0.0, -(1.0 - _scaleY.value) * 20, 0.0, 1.0)
              ..scaleByDouble(1.0, _scaleY.value, 1.0, 1.0),
            alignment: Alignment.topCenter,
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: widget.screenWidth,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: context.noteSurfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.noteChipBorderColor),
              boxShadow: [
                BoxShadow(
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 12),
                  color: AppColors.warmShadow,
                ),
                BoxShadow(
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  color: AppColors.warmShadow.withValues(alpha: 0.5),
                ),
              ],
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.items.length; i++) ...[
                  _buildParentItem(i),
                  _buildSubPanel(i),
                  if (i < widget.items.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.noteChipBorderColor,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParentItem(int i) {
    final item = widget.items[i];
    final isHovered = _hoveredIndex == i;
    final isExpanded = _expandedIndex == i;
    final isActive = isHovered || isExpanded;
    final actionColor = item.isDestructible
        ? _destructibleColor
        : AppColors.primaryColor;

    return AnimatedBuilder(
      animation: _itemControllers[i],
      builder: (context, child) => FadeTransition(
        opacity: _itemOpacity[i],
        child: SlideTransition(position: _itemSlide[i], child: child),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hoveredIndex = i),
        onExit: (_) => setState(() => _hoveredIndex = null),
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();

            if (item.hasSubItems) {
              _toggleExpand(i);
            } else {
              widget.onSelected(item.label, null);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            color: isActive
                ? actionColor.withValues(
                    alpha: item.isDestructible ? 0.08 : 0.06,
                  )
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildLeadingBox(
                  index: i,
                  item: item,
                  isActive: isActive,
                  isDestructible: item.isDestructible,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    item.label,
                    style: AppFonts.appStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: item.isDestructible
                          ? actionColor
                          : context.noteTextPrimaryColor,
                    ),
                  ),
                ),

                if (item.hasSubItems)
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOutCubic,
                    child: AnimatedOpacity(
                      opacity: isActive ? 1.0 : 0.35,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: actionColor,
                      ),
                    ),
                  ),
                // else
                //   AnimatedSlide(
                //     offset: isHovered ? const Offset(0.15, 0) : Offset.zero,
                //     duration: const Duration(milliseconds: 200),
                //     curve: Curves.easeOut,
                //     child: AnimatedOpacity(
                //       opacity: isHovered ? 1.0 : 0.35,
                //       duration: const Duration(milliseconds: 200),
                //       child: Icon(
                //         Icons.arrow_forward_rounded,
                //         size: 17,
                //         color: actionColor,
                //       ),
                //     ),
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingBox({
    required int index,
    required DropdownItem item,
    required bool isActive,
    required bool isDestructible,
  }) {
    final actionColor = isDestructible
        ? _destructibleColor
        : AppColors.primaryColor;
    final foregroundColor = isActive ? Colors.white : actionColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? actionColor : actionColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: IconTheme(
        data: IconThemeData(size: 16, color: foregroundColor),
        child: DefaultTextStyle(
          style: AppFonts.appStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: foregroundColor,
          ),
          child:
              item.leading ??
              Text(
                '${index + 1}',
                style: AppFonts.appStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foregroundColor,
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildSubPanel(int parentIndex) {
    final item = widget.items[parentIndex];

    if (!item.hasSubItems) return const SizedBox.shrink();

    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: _subControllers[parentIndex],
        curve: Curves.easeInOutCubic,
      ),
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _subControllers[parentIndex],
          curve: Curves.easeOut,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.noteChipBackgroundColor.withValues(alpha: 0.55),
            border: Border(left: BorderSide(color: AppColors.accent, width: 2)),
          ),
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 8),
          child: ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var j = 0; j < item.subItems.length; j++) ...[
                  _buildSubItem(parentIndex, j, _subItemFrom(item.subItems[j])),
                  if (j < item.subItems.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: context.noteChipBorderColor,
                      indent: 12,
                      endIndent: 12,
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubItem(int parentIndex, int subIndex, DropdownSubItem subItem) {
    final hoverKey = parentIndex * 1000 + subIndex;
    final isHovered = _hoveredSubKey == hoverKey;
    final actionColor = subItem.isDestructible
        ? _destructibleColor
        : AppColors.primaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSubKey = hoverKey),
      onExit: (_) => setState(() => _hoveredSubKey = null),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onSelected(widget.items[parentIndex].label, subItem.label);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          color: isHovered
              ? actionColor.withValues(
                  alpha: subItem.isDestructible ? 0.10 : 0.07,
                )
              : Colors.transparent,
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 13,
            bottom: 13,
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: isHovered ? 8 : 6,
                height: isHovered ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isHovered
                      ? actionColor
                      : actionColor.withValues(
                          alpha: subItem.isDestructible ? 0.55 : 0.25,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  subItem.label,
                  style: AppFonts.appStyle(
                    fontSize: 14,
                    fontWeight: isHovered ? FontWeight.w600 : FontWeight.w500,
                    color: subItem.isDestructible
                        ? actionColor.withValues(alpha: isHovered ? 1.0 : 0.75)
                        : isHovered
                        ? context.noteTextPrimaryColor
                        : context.noteTextSecondaryColor,
                  ),
                ),
              ),

              AnimatedSlide(
                offset: isHovered ? Offset.zero : const Offset(0.3, 0),
                duration: const Duration(milliseconds: 160),
                child: AnimatedOpacity(
                  opacity: isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 14,
                    color: actionColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
