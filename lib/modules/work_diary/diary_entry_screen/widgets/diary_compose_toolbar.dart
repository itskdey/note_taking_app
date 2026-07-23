part of '../diary_entry_screen_view.dart';

class DiaryComposeToolbar extends StatelessWidget {
  const DiaryComposeToolbar({
    super.key,
    required this.controller,
    required this.onCamera,
    required this.onGallery,
    required this.onMic,
    required this.onUndo,
    required this.onRedo,
  });

  final DiaryEntryController controller;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onMic;
  final VoidCallback onUndo;
  final VoidCallback onRedo;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.noteSurface,
          border: Border(
            top: BorderSide(color: AppColors.noteDivider, width: 0.6),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            _ToolIcon(icon: Icons.camera_alt_outlined, onTap: onCamera),
            _ToolIcon(icon: Icons.photo_library_outlined, onTap: onGallery),
            _ToolIcon(icon: Icons.mic_none_rounded, onTap: onMic),
            const SizedBox(
              height: 20,
              child: VerticalDivider(
                color: AppColors.noteDivider,
                width: 18,
                thickness: 0.6,
              ),
            ),
            _ToolIcon(icon: Icons.undo_rounded, onTap: onUndo),
            _ToolIcon(icon: Icons.redo_rounded, onTap: onRedo),
            const Spacer(),
            Obx(
              () => _ToolIcon(
                icon: Icons.format_bold_rounded,
                active: controller.isBold.value,
                onTap: controller.toggleBold,
              ),
            ),
            Obx(
              () => _ToolIcon(
                icon: Icons.format_italic_rounded,
                active: controller.isItalic.value,
                onTap: controller.toggleItalic,
              ),
            ),
            Obx(
              () => _ToolIcon(
                icon: Icons.format_underline_rounded,
                active: controller.isUnderline.value,
                onTap: controller.toggleUnderline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: active ? AppColors.noteChipBackground : Colors.transparent,
        ),
        child: Icon(
          icon,
          size: 19,
          color: active
              ? AppColors.noteTextPrimary
              : AppColors.noteTextSecondary,
        ),
      ),
    );
  }
}
