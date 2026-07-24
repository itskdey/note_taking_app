part of '../diary_home_screen_view.dart';

/// Renders one month's worth of diary entries as a vertical timeline:
/// a rounded month-label pill, then a connected line down the left edge
/// where the first entry of each day gets a filled circle badge (day
/// number + weekday label above it) and subsequent same-day entries get
/// a small dot marker instead.
class DiaryMonthGroup extends StatelessWidget {
  const DiaryMonthGroup({
    super.key,
    required this.month,
    required this.entries,
    required this.onTapEntry,
    required this.onToggleBookmark,
  });

  final int month;
  final List<DiaryEntryModel> entries;
  final ValueChanged<DiaryEntryModel> onTapEntry;
  final ValueChanged<DiaryEntryModel> onToggleBookmark;

  String get _monthLabel => KhmerDateUtils.monthName(month);

  String _weekdayLabel(DateTime date) => KhmerDateUtils.weekdayShort(date);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Entries are already sorted descending by date; this just clusters
  /// consecutive entries that fall on the same calendar day.
  List<List<DiaryEntryModel>> get _dayGroups {
    final List<List<DiaryEntryModel>> groups = [];
    for (final entry in entries) {
      if (groups.isNotEmpty && _isSameDay(groups.last.first.date, entry.date)) {
        groups.last.add(entry);
      } else {
        groups.add([entry]);
      }
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _dayGroups;

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MonthPill(label: _monthLabel),
          for (int g = 0; g < groups.length; g++)
            for (int i = 0; i < groups[g].length; i++)
              _DiaryTimelineRow(
                entry: groups[g][i],
                isDayHead: i == 0,
                weekdayLabel: i == 0 ? _weekdayLabel(groups[g][i].date) : null,
                isLast: g == groups.length - 1 && i == groups[g].length - 1,
                onTap: () => onTapEntry(groups[g][i]),
                onToggleBookmark: () => onToggleBookmark(groups[g][i]),
              ),
        ],
      ),
    );
  }
}

class _MonthPill extends StatelessWidget {
  const _MonthPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: context.noteChipBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.noteChipBorderColor),
        ),
        child: Text(
          label,
          style: AppFonts.appStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: context.noteTextPrimaryColor,
          ),
        ),
      ),
    );
  }
}

class _DiaryTimelineRow extends StatelessWidget {
  const _DiaryTimelineRow({
    required this.entry,
    required this.isDayHead,
    required this.weekdayLabel,
    required this.isLast,
    required this.onTap,
    required this.onToggleBookmark,
  });

  final DiaryEntryModel entry;
  final bool isDayHead;
  final String? weekdayLabel;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onToggleBookmark;

  static const Color _dayCircleColor = AppColors.timelineBadge;

  String get _timeLabel => KhmerDateUtils.formatTime(entry.date);

  @override
  Widget build(BuildContext context) {
    final lineColor = context.timelineColor;
    final dotColor = Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 44,
              child: Column(
                children: [
                  if (isDayHead) ...[
                    Text(
                      weekdayLabel ?? '',
                      style: AppFonts.appStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: context.noteTextPrimaryColor.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: _dayCircleColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        KhmerDateUtils.dayNumber(entry.date),
                        style: AppFonts.appStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    // Keep the dot centered on the time label. The line
                    // before it only fills the space above the marker.
                    Container(width: 2, height: 5, color: lineColor),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  Expanded(
                    child: isLast
                        ? const SizedBox.shrink()
                        : Center(child: Container(width: 2, color: lineColor)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  // Keep the weekday label level with the time label. The
                  // day badge remains below the weekday, matching the dot's
                  // position relative to the time on subsequent rows.
                  top: 0,
                  bottom: isLast ? 4 : 22,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _timeLabel,
                          style: AppFonts.appStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.info.withValues(alpha: 0.72),
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: onToggleBookmark,
                          child: Icon(
                            entry.isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 18,
                            color: context.noteTextPrimaryColor.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (entry.isLocked)
                      _LockedEntryPreview()
                    else ...[
                      if (entry.title.trim().isNotEmpty)
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          KhmerDateUtils.toKhmerNumber(entry.title),
                          style: AppFonts.appStyle(
                            fontSize: isDayHead ? 16 : 16,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                            color: context.noteTextPrimaryColor,
                          ),
                        ),
                      if (entry.content.trim().isNotEmpty)
                        Text(
                          KhmerDateUtils.toKhmerNumber(entry.content),
                          style: AppFonts.appStyle(
                            fontSize: isDayHead ? 11 : 11,
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                            color: context.noteTextSecondaryColor,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (entry.imagePaths.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: context.noteChipBackgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 14,
                                color: context.noteTextPrimaryColor.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'diary_image_count'.trParams({
                                  'count': KhmerDateUtils.toKhmerNumber(
                                    entry.imagePaths.length,
                                  ),
                                }),
                                style: AppFonts.appStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: context.noteTextPrimaryColor
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedEntryPreview extends StatelessWidget {
  const _LockedEntryPreview();

  @override
  Widget build(BuildContext context) {
    final dotColor = context.noteTextPrimaryColor.withValues(alpha: 0.72);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ObscuredDotGroup(count: 4, color: dotColor),
              const SizedBox(width: 12),
              _ObscuredDotGroup(count: 2, color: dotColor),
              const SizedBox(width: 14),
              _ObscuredDotGroup(count: 5, color: dotColor),
              const SizedBox(width: 8),
              Icon(
                Icons.lock_rounded,
                size: 16,
                color: context.noteTextPrimaryColor.withValues(alpha: 0.58),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _ObscuredDotGroup(count: 5, color: dotColor),
              const SizedBox(width: 12),
              _ObscuredDotGroup(count: 7, color: dotColor),
              const SizedBox(width: 12),
              _ObscuredDotGroup(count: 4, color: dotColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _ObscuredDotGroup extends StatelessWidget {
  const _ObscuredDotGroup({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < count; index++) ...[
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (index < count - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}
