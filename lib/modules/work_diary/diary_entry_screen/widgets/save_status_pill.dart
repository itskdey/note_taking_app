part of '../diary_entry_screen_view.dart';

class SaveStatusPill extends StatelessWidget {
  const SaveStatusPill({super.key, required this.controller});

  final DiaryEntryController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.saveStatus.value;

      late final Widget indicator;
      late final String label;
      late final Color color;

      switch (status) {
        case DiarySaveStatus.saving:
          indicator = const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.6,
              valueColor: AlwaysStoppedAnimation(AppColors.honey),
            ),
          );
          label = 'saving'.tr;
          color = AppColors.honey;
          break;
        case DiarySaveStatus.saved:
          indicator = const Icon(
            Icons.check_rounded,
            size: 12,
            color: AppColors.success,
          );
          label = controller.lastSavedLabel;
          color = AppColors.success;
          break;
        case DiarySaveStatus.error:
          indicator = const Icon(
            Icons.error_outline_rounded,
            size: 12,
            color: AppColors.danger,
          );
          label = 'save_failed'.tr;
          color = AppColors.danger;
          break;
        case DiarySaveStatus.idle:
          indicator = const SizedBox(width: 6, height: 6);
          label = '';
          color = context.noteTextSecondaryColor;
          break;
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        // UniqueKey() per build: Obx only rebuilds this widget when
        // saveStatus.value actually changes, so every rebuild is already
        // a real transition. A fresh unique key guarantees the outgoing
        // and incoming children can never collide in AnimatedSwitcher's
        // internal Stack, even if two transitions overlap faster than
        // the 200ms fade (e.g. a fast local save cycling
        // idle -> saving -> saved -> idle in quick succession).
        child: label.isEmpty
            ? SizedBox.shrink(key: UniqueKey())
            : Row(
                key: UniqueKey(),
                mainAxisSize: MainAxisSize.min,
                children: [
                  indicator,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
