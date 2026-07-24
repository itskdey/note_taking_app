import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:note_taking_app/core/values/app_colors.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';
import 'package:note_taking_app/core/values/app_images.dart';
import 'package:note_taking_app/routes/app_routes.dart';
import 'package:note_taking_app/widget/animation/animated_widget.dart';
import 'package:note_taking_app/widget/dropdown/dropdown_menu.dart';

import '../diary_shared/diary_database_service.dart';
import '../diary_shared/diary_entry_model.dart';
import '../diary_shared/khmer_date_utils.dart';

part 'diary_home_screen_binding.dart';
part 'diary_home_screen_controller.dart';
part 'widget/diary_empty_state.dart';
part 'widget/diary_month_group.dart';
part 'widget/diary_month_pill_row.dart';
part 'widget/diary_year_header.dart';

class DiaryHomeScreen extends GetView<DiaryHomeController> {
  const DiaryHomeScreen({super.key, this.onOpenNavigation});

  final VoidCallback? onOpenNavigation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackgroundColor,
      body: SafeArea(
        child: Obx(() {
          final Map<int, List<DiaryEntryModel>> grouped =
              controller.groupedByMonth;
          final List<int> months = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));
          final bool isSplash = controller.showSplash.value;

          if (isSplash) {
            return const DiaryHomeSplash();
          }

          return _DiaryHomeContent(
            controller: controller,
            grouped: grouped,
            months: months,
            onOpenNavigation: onOpenNavigation,
          );
        }),
      ),
      floatingActionButton: Obx(() {
        if (controller.showSplash.value) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: controller.openNewEntry,
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.darkTextColor,
          elevation: 3,
          shape: const CircleBorder(),
          tooltip: 'take_note'.tr,
          child: const Icon(Icons.edit_rounded, size: 24),
        );
      }),
    );
  }
}

class _DiaryHomeContent extends StatefulWidget {
  const _DiaryHomeContent({
    required this.controller,
    required this.grouped,
    required this.months,
    required this.onOpenNavigation,
  });

  final DiaryHomeController controller;
  final Map<int, List<DiaryEntryModel>> grouped;
  final List<int> months;
  final VoidCallback? onOpenNavigation;

  @override
  State<_DiaryHomeContent> createState() => _DiaryHomeContentState();
}

class _DiaryHomeContentState extends State<_DiaryHomeContent>
    with SingleTickerProviderStateMixin {
  static const double _monthHeaderTopPadding = 20;
  static const double _stickyHeaderHeight = 42;
  static const double _greetingCollapseOffset = 24;

  final ScrollController _timelineController = ScrollController();
  final GlobalKey _timelineKey = GlobalKey();
  final Map<int, GlobalKey> _monthKeys = <int, GlobalKey>{};
  late final AnimationController _greetingController;
  late final Animation<double> _greetingVisibility;
  int? _stickyMonth;
  double _stickyHeaderOffset = 0;
  double _temporaryBottomSpace = 0;
  int _scrollRequestId = 0;
  bool _isButtonScrollActive = false;
  bool _isGreetingCollapsed = false;

  @override
  void initState() {
    super.initState();
    _greetingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
      reverseDuration: const Duration(milliseconds: 320),
    );
    _greetingVisibility = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _greetingController,
        curve: Curves.easeInOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
    _timelineController.addListener(_updateStickyMonth);
  }

  GlobalKey _keyForMonth(int month) =>
      _monthKeys.putIfAbsent(month, GlobalKey.new);

  Future<void> _scrollToMonth(int month) async {
    widget.controller.selectMonth(month);

    final targetContext = _keyForMonth(month).currentContext;
    final timelineContext = _timelineKey.currentContext;
    if (targetContext == null ||
        timelineContext == null ||
        !_timelineController.hasClients) {
      return;
    }

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final timelineBox = timelineContext.findRenderObject() as RenderBox?;
    if (targetBox == null || timelineBox == null) return;

    final rawTargetOffset =
        targetBox.localToGlobal(Offset.zero, ancestor: timelineBox).dy +
        _monthHeaderTopPadding;
    final requestId = ++_scrollRequestId;
    _isButtonScrollActive = true;

    try {
      final normalMaxScrollExtent =
          (_timelineController.position.maxScrollExtent - _temporaryBottomSpace)
              .clamp(
                _timelineController.position.minScrollExtent,
                double.infinity,
              );
      final requiredBottomSpace = (rawTargetOffset - normalMaxScrollExtent)
          .clamp(0.0, double.infinity)
          .toDouble();

      if (requiredBottomSpace > _temporaryBottomSpace + 0.5) {
        setState(() => _temporaryBottomSpace = requiredBottomSpace);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted || requestId != _scrollRequestId) return;
      }

      final targetOffset = rawTargetOffset
          .clamp(
            _timelineController.position.minScrollExtent,
            _timelineController.position.maxScrollExtent,
          )
          .toDouble();
      final distance = (targetOffset - _timelineController.position.pixels)
          .abs();
      final duration = Duration(
        milliseconds: (650 + distance * 0.65).round().clamp(750, 1800),
      );

      await _timelineController.animateTo(
        targetOffset,
        duration: duration,
        curve: Curves.easeInOutCubic,
      );

      if (_temporaryBottomSpace > 0) {
        final normalMaxScrollExtent =
            (_timelineController.position.maxScrollExtent -
                    _temporaryBottomSpace)
                .clamp(
                  _timelineController.position.minScrollExtent,
                  _timelineController.position.maxScrollExtent,
                )
                .toDouble();
        if (mounted &&
            requestId == _scrollRequestId &&
            targetOffset <= normalMaxScrollExtent + 0.5) {
          setState(() => _temporaryBottomSpace = 0);
        }
      }
    } finally {
      if (mounted && requestId == _scrollRequestId) {
        _isButtonScrollActive = false;
        widget.controller.selectMonth(month);
      }
    }
  }

  void _updateStickyMonth() {
    if (!_timelineController.hasClients) return;

    final timelineBox =
        _timelineKey.currentContext?.findRenderObject() as RenderBox?;
    if (timelineBox == null) return;

    final scrollOffset = _timelineController.position.pixels;
    final shouldCollapseGreeting = _isGreetingCollapsed
        ? scrollOffset > 0
        : scrollOffset >= _greetingCollapseOffset;
    if (_isGreetingCollapsed != shouldCollapseGreeting) {
      _isGreetingCollapsed = shouldCollapseGreeting;
      if (shouldCollapseGreeting) {
        _greetingController.forward();
      } else {
        _greetingController.reverse();
      }
    }
    int? stickyMonth;
    double? nextHeaderOffset;

    for (final month in widget.months) {
      final monthBox =
          _keyForMonth(month).currentContext?.findRenderObject() as RenderBox?;
      if (monthBox == null) continue;

      final headerOffset =
          monthBox.localToGlobal(Offset.zero, ancestor: timelineBox).dy +
          _monthHeaderTopPadding;
      if (headerOffset <= scrollOffset + 0.5) {
        stickyMonth = month;
      } else if (stickyMonth != null) {
        nextHeaderOffset = headerOffset;
        break;
      }
    }

    final stickyOffset = nextHeaderOffset == null
        ? 0.0
        : (nextHeaderOffset - scrollOffset - _stickyHeaderHeight).clamp(
            -_stickyHeaderHeight,
            0.0,
          );

    if (!_isButtonScrollActive &&
        stickyMonth != null &&
        widget.controller.selectedMonth.value != stickyMonth) {
      widget.controller.selectMonth(stickyMonth);
    }

    final shouldRemoveTemporarySpace =
        !_isButtonScrollActive &&
        _temporaryBottomSpace > 0 &&
        scrollOffset <=
            _timelineController.position.maxScrollExtent -
                _temporaryBottomSpace +
                0.5;

    if (_stickyMonth == stickyMonth &&
        (_stickyHeaderOffset - stickyOffset).abs() < 0.5 &&
        !shouldRemoveTemporarySpace) {
      return;
    }

    setState(() {
      _stickyMonth = stickyMonth;
      _stickyHeaderOffset = stickyOffset;
      if (shouldRemoveTemporarySpace) _temporaryBottomSpace = 0;
    });
  }

  @override
  void dispose() {
    _timelineController.removeListener(_updateStickyMonth);
    _timelineController.dispose();
    _greetingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: .start,
          children: [
            GestureDetector(
              onTap: () {},
              child: DiaryYearHeader(greetingName: "user", year: 2026),
            ),

            SizeTransition(
              sizeFactor: _greetingVisibility,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: _greetingVisibility,
                child: RepaintBoundary(
                  child: Row(
                    children: [
                      Expanded(child: _buildGreeting()),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: FullWidthDropdownButton.rich(
                          openIconAsset: AppImages.arrowFUp,
                          iconAsset: AppImages.arrowFUp,
                          iconSize: 30,
                          openIconTurns: 0.25,

                          decoration: BoxDecoration(),
                          openDecoration: BoxDecoration(),
                          openIconColor: context.noteTextPrimaryColor,
                          iconColor: context.noteTextPrimaryColor,

                          dropdownItems: [
                            DropdownItem(
                              label: "Setting",
                              leading: SvgPicture.asset(
                                AppImages.smartGuesture,
                                width: 18,
                                height: 18,
                              ),
                            ),
                            DropdownItem(
                              isDestructible: true,
                              label: "delete_entry",
                              leading: SvgPicture.asset(
                                AppImages.deleteIcon,
                                width: 18,
                                height: 18,
                                colorFilter: ColorFilter.mode(
                                  AppColors.danger,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ],
                          onItemSelected: (parent, sub) async {
                            if (parent == 'Setting') {
                              Get.toNamed(Routes.settingScreen);
                            }
                            if (parent == 'delete_entry') {
                              return;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Obx(
              () => DiaryMonthPillRow(
                months: widget.controller.monthsWithEntries,
                selectedMonth: widget.controller.selectedMonth.value,
                onSelect: _scrollToMonth,
              ),
            ),

            Expanded(
              child: widget.controller.isEmpty
                  ? DiaryEmptyState(
                      year: widget.controller.selectedYear.value,
                      onTap: widget.controller.openNewEntry,
                    )
                  : Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: SingleChildScrollView(
                              controller: _timelineController,
                              scrollDirection: Axis.vertical,
                              padding: const EdgeInsets.only(bottom: 120),
                              child: Column(
                                key: _timelineKey,
                                children: [
                                  for (final month in widget.months)
                                    DiaryMonthGroup(
                                      key: _keyForMonth(month),
                                      month: month,
                                      entries: widget.grouped[month]!,
                                      onTapEntry: widget.controller.openEntry,
                                      onToggleBookmark: (e) => widget.controller
                                          .toggleBookmark(e.id),
                                    ),
                                  if (_temporaryBottomSpace > 0)
                                    SizedBox(height: _temporaryBottomSpace),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_stickyMonth case final stickyMonth?)
                          Positioned(
                            top: _stickyHeaderOffset,
                            left: 16,
                            right: 16,
                            height: _stickyHeaderHeight,
                            child: IgnorePointer(
                              child: ColoredBox(
                                color: context.appBackgroundColor,
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: _MonthPill(
                                    label: KhmerDateUtils.monthName(
                                      stickyMonth,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 30),
          Text(
            "work_diary".tr,
            style: AppFonts.appStyle(fontSize: 38, fontWeight: FontWeight.w700),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: Text(
              "diary_greeting".trParams({'username': ""}),
              style: AppFonts.appStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DiaryHomeSplash extends StatelessWidget {
  const DiaryHomeSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: context.appBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAnimatedWidget(
            delay: 400,
            child: Text(
              "komnottra.diary",
              style: AppFonts.appStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
          ),
          CustomAnimatedWidget(
            delay: 600,
            child: Text(
              "Your work diary".toUpperCase(),
              style: AppFonts.appStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                appFontFamily: AppFontFamily.brier,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 10),
          CustomAnimatedWidget(
            delay: 800,
            child: Text(
              "diary_splash_description".tr,
              style: AppFonts.appStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
