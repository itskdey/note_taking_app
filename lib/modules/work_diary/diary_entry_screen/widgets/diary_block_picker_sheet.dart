part of '../diary_entry_screen_view.dart';

class _DiaryBlockOptionSpec {
  const _DiaryBlockOptionSpec({
    required this.type,
    required this.icon,
    required this.labelKey,
  });
  final DiaryBlockType type;
  final IconData icon;
  final String labelKey;
}

const List<_DiaryBlockOptionSpec> _diaryBlockOptions = [
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.checklist,
    icon: Icons.check_box_outlined,
    labelKey: 'block_checklist',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.radio,
    icon: Icons.radio_button_checked_outlined,
    labelKey: 'block_radio',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.bullet,
    icon: Icons.format_list_bulleted_rounded,
    labelKey: 'block_bullet',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.numbered,
    icon: Icons.format_list_numbered_rounded,
    labelKey: 'block_numbered',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.quote,
    icon: Icons.format_quote_rounded,
    labelKey: 'block_quote',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.divider,
    icon: Icons.horizontal_rule_rounded,
    labelKey: 'block_divider',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.image,
    icon: Icons.photo_library_outlined,
    labelKey: 'block_image',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.heading,
    icon: Icons.title_rounded,
    labelKey: 'block_heading',
  ),
  _DiaryBlockOptionSpec(
    type: DiaryBlockType.callout,
    icon: Icons.lightbulb_outline_rounded,
    labelKey: 'block_callout',
  ),
];

Future<DiaryBlockType?> showDiaryBlockPickerSheet(BuildContext context) {
  return showModalBottomSheet<DiaryBlockType>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _DiaryBlockPickerSheet(),
  );
}

class _DiaryBlockPickerSheet extends StatelessWidget {
  const _DiaryBlockPickerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.noteSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.noteChipBorder, width: 0.6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.noteChipBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: AppNameHeader(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAnimatedWidget(
                    delay: 450,
                    from: SlideFrom.left,
                    child: Text(
                      'add_block_title'.tr,
                      style: AppFonts.appStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.noteTextSecondary,
                      ),
                    ),
                  ),

                  GridView.count(
                    crossAxisCount: 3,
                    padding: .zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 0.95,
                    children: _diaryBlockOptions
                        .asMap()
                        .entries
                        .map(
                          (entry) => CustomAnimatedWidget(
                            delay: 520 + (entry.key * 60),
                            from: SlideFrom.bottom,
                            pop: true,
                            child: _BlockOptionTile(spec: entry.value),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BlockOptionTile extends StatelessWidget {
  const _BlockOptionTile({required this.spec});
  final _DiaryBlockOptionSpec spec;

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: () => Navigator.of(context).pop(spec.type),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightBackgroundColor,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.noteChipBorder, width: 1),
            ),
            child: Icon(spec.icon, size: 19, color: AppColors.appRed),
          ),
          const SizedBox(height: 8),
          Text(
            spec.labelKey.tr,
            textAlign: TextAlign.center,
            style: AppFonts.appStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.noteTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
