part of '../diary_home_screen_view.dart';

class DiaryMonthPillRow extends StatelessWidget {
  const DiaryMonthPillRow({
    super.key,
    required this.months,
    required this.selectedMonth,
    required this.onSelect,
  });

  final List<int> months;
  final int? selectedMonth;
  final ValueChanged<int> onSelect;

  static const double _buttonGap = 8;
  static const double _horizontalPadding = 18;

  double _buttonWidth(
    String label,
    TextStyle style,
    TextDirection textDirection,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: textDirection,
      maxLines: 1,
    )..layout();
    final width = painter.width + _horizontalPadding * 2;
    painter.dispose();
    return width;
  }

  @override
  Widget build(BuildContext context) {
    if (months.isEmpty) return const SizedBox.shrink();
    final selectedIndex = selectedMonth == null
        ? -1
        : months.indexOf(selectedMonth!);
    final labels = [
      for (final month in months) KhmerDateUtils.monthName(month),
    ];
    final textStyle = AppFonts.appStyle(
      color: AppColors.noteTextSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    final widths = [
      for (final label in labels)
        _buttonWidth(label, textStyle, Directionality.of(context)),
    ];
    final leftOffsets = <double>[];
    var contentWidth = 0.0;
    for (final width in widths) {
      leftOffsets.add(contentWidth);
      contentWidth += width + _buttonGap;
    }
    contentWidth -= _buttonGap;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: SizedBox(
        width: double.infinity,
        height: 36,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: contentWidth,
            child: Stack(
              children: [
                for (int index = 0; index < months.length; index++)
                  Positioned(
                    left: leftOffsets[index],
                    width: widths[index],
                    top: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.noteChipBackground,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                if (selectedIndex >= 0)
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: selectedIndex.toDouble(),
                      end: selectedIndex.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeInOutCubic,
                    builder: (context, value, child) {
                      final lowerIndex = value.floor().clamp(
                        0,
                        months.length - 1,
                      );
                      final upperIndex = value.ceil().clamp(
                        0,
                        months.length - 1,
                      );
                      final progress = value - lowerIndex;
                      final left =
                          leftOffsets[lowerIndex] +
                          (leftOffsets[upperIndex] - leftOffsets[lowerIndex]) *
                              progress;
                      final width =
                          widths[lowerIndex] +
                          (widths[upperIndex] - widths[lowerIndex]) * progress;
                      return Transform.translate(
                        offset: Offset(left, 0),
                        child: SizedBox(width: width, height: 36, child: child),
                      );
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.notePill,
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                for (int index = 0; index < months.length; index++)
                  Positioned(
                    left: leftOffsets[index],
                    width: widths[index],
                    top: 0,
                    bottom: 0,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onSelect(months[index]),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeInOut,
                          style: textStyle.copyWith(
                            color: selectedMonth == months[index]
                                ? Colors.white
                                : AppColors.noteTextSecondary,
                          ),
                          child: Text(labels[index]),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
