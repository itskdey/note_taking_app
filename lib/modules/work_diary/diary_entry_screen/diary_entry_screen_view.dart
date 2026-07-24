import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:note_taking_app/core/values/app_colors.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';
import 'package:note_taking_app/core/values/app_images.dart';
import 'package:note_taking_app/modules/work_diary/diary_shared/diary_block_model.dart';
import 'package:note_taking_app/widget/animation/animated_widget.dart';
import 'package:note_taking_app/widget/app_bar/app_bar_custom.dart';
import 'package:note_taking_app/widget/dropdown/dropdown_menu.dart';
import 'package:note_taking_app/widget/sheets/app_name_sheet.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../diary_shared/diary_database_service.dart';
import '../diary_shared/diary_entry_model.dart';
import '../diary_shared/khmer_date_utils.dart';

part 'diary_entry_screen_binding.dart';
part 'diary_entry_screen_controller.dart';
part 'widgets/diary_block_list_widget.dart';
part 'widgets/diary_block_picker_sheet.dart';
part 'widgets/diary_compose_toolbar.dart';
part 'widgets/image_preview_sheet.dart';
part 'widgets/save_status_pill.dart';

class DiaryEntryScreen extends StatefulWidget {
  const DiaryEntryScreen({super.key});

  @override
  State<DiaryEntryScreen> createState() => _DiaryEntryScreenState();
}

class _DiaryEntryScreenState extends State<DiaryEntryScreen> {
  bool _canPop = false;

  DiaryEntryController get controller => Get.find<DiaryEntryController>();

  static final TextInputFormatter _khmerDigitFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final converted = KhmerDateUtils.toKhmerNumber(newValue.text);
        if (converted == newValue.text) return newValue;
        return newValue.copyWith(text: converted);
      });

  Future<void> _popWithResult() async {
    final result = await controller.onWillPop();
    if (!mounted) return;
    setState(() => _canPop = true);
    Get.back(result: result);
  }

  /// First back press on an existing entry that's mid-edit just returns
  /// to the read-only preview; a second press actually leaves the screen.
  /// New entries and entries already in preview mode leave immediately.
  Future<void> _handleBackPressed() async {
    if (controller.entry != null && controller.isEditing.value) {
      await controller.exitEditMode();
      return;
    }
    await _popWithResult();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackPressed();
      },
      child: Scaffold(
        backgroundColor: context.appBackgroundColor,
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateRow(context),
                      const SizedBox(height: 18),
                      _buildEditorBox(),
                      const SizedBox(height: 20),
                      DiaryBlockListView(controller: controller),
                      Obx(
                        () => controller.isEditing.value
                            ? Center(
                                child: _AddBlockButton(
                                  onTap: () async {
                                    final type =
                                        await showDiaryBlockPickerSheet(
                                          context,
                                        );
                                    if (type == DiaryBlockType.image) {
                                      await controller.pickImages();
                                    } else if (type != null) {
                                      controller.addBlock(type);
                                    }
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => controller.isEditing.value
                    ? DiaryComposeToolbar(
                        controller: controller,
                        onCamera: () => controller.pickImages(fromCamera: true),
                        onGallery: controller.pickImages,
                        onMic: () => controller.addBlock(DiaryBlockType.voice),
                        onUndo: () {},
                        onRedo: () {},
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_note_title'.tr),
        content: Text('delete_note_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      final result = await controller.deleteEntry();
      if (!mounted) return;
      setState(() => _canPop = true);
      Get.back(result: result);
    } catch (_) {
      if (!mounted) return;
      Get.snackbar(
        'delete_note_failed_title'.tr,
        'delete_note_failed_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  AppBarCustom _buildAppBar(BuildContext context) {
    return AppBarCustom(
      title: "Diary",
      upText: "komnottra.entry",
      onBack: _handleBackPressed,
      actions: [
        Obx(
          () => controller.isEditing.value
              ? const SizedBox.shrink()
              : Bounceable(
                  onTap: controller.enterEditMode,
                  child: SvgPicture.asset(
                    AppImages.editIcon,
                    height: 18,
                    width: 18,
                    colorFilter: ColorFilter.mode(
                      context.noteTextPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
        ),
        FullWidthDropdownButton.rich(
          iconAsset: AppImages.moreIcon,
          decoration: BoxDecoration(),
          openDecoration: BoxDecoration(),
          openIconColor: context.noteTextPrimaryColor,
          iconColor: context.noteTextPrimaryColor,

          dropdownItems: [
            DropdownItem(
              label: controller.isLocked.value ? "unlock_diary" : "lock_diary",
              leading: SvgPicture.asset(
                AppImages.lockIcon,
                width: 18,
                height: 18,
              ),
            ),
            DropdownItem(
              label: "download",
              leading: SvgPicture.asset(
                AppImages.lockIcon,
                width: 18,
                height: 18,
              ),
              subItems: ["pdf", "markdown"],
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
            if (parent == 'delete_entry') {
              await _confirmDeleteEntry();
              return;
            }

            if (parent == 'lock_diary' || parent == 'unlock_diary') {
              final result = await controller.toggleLock();
              if (!mounted || result == null) return;
              setState(() => _canPop = true);
              Get.back(result: result);
              return;
            }

            setState(() => _canPop = true);
            Get.back(result: null);
          },
        ),
      ],
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Obx(
      () => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: controller.isEditing.value
                ? () => controller.pickDate(context)
                : null,
            child: TweenAnimationBuilder<double>(
              key: ValueKey(controller.selectedDate.value),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.linear,
              tween: Tween<double>(
                begin: 1.0,
                end: controller.selectedDate.value.day.toDouble(),
              ),
              builder: (context, day, child) {
                final digits = day.round().toString().padLeft(2, '0');
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildAnimatedDayDigit(digits[0]),
                    _buildAnimatedDayDigit(digits[1]),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: controller.isEditing.value
                ? () => controller.pickDate(context)
                : null,
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.monthName,
                        style: AppFonts.appStyle(
                          fontSize: 14,
                          color: context.noteTextPrimaryColor,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        KhmerDateUtils.toKhmerNumber(
                          controller.selectedDate.value.year,
                        ),
                        style: AppFonts.appStyle(
                          fontSize: 13,
                          color: context.noteTextSecondaryColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  if (controller.isEditing.value)
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: context.noteTextSecondaryColor,
                    ),
                ],
              ),
            ),
          ),
          const Spacer(),
          SaveStatusPill(controller: controller),
        ],
      ),
    );
  }

  Widget _buildAnimatedDayDigit(String digit) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 140),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.8),
          end: Offset.zero,
        ).animate(animation);
        return ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          ),
        );
      },
      child: Text(
        KhmerDateUtils.toKhmerNumber(digit),
        key: ValueKey(digit),
        style: AppFonts.appStyle(
          fontSize: 40,
          fontWeight: FontWeight.w700,
          color: AppColors.appRed,
          height: 1,
        ),
      ),
    );
  }

  /// Read-only rendering of the title/content used before the user taps
  /// into edit mode for an existing entry.
  Widget _buildEditorPreview() {
    final hasTitle = controller.titleController.text.trim().isNotEmpty;
    final hasContent = controller.contentController.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTitle)
            Text(
              controller.titleController.text,
              style: AppFonts.appStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.noteTextPrimaryColor,
                height: 1.3,
                letterSpacing: -0.3,
              ),
            ),
          if (hasTitle && hasContent) const SizedBox(height: 16),
          if (hasContent)
            Text(
              controller.contentController.text,
              style: AppFonts.appStyle(
                fontSize: 15.5,
                color: context.noteTextPrimaryColor.withValues(alpha: 0.78),
                height: 1.7,
                letterSpacing: 0.1,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEditorBox() {
    return Obx(() {
      if (!controller.isEditing.value) {
        return GestureDetector(
          onTap: controller.enterEditMode,
          behavior: HitTestBehavior.opaque,
          child: _buildEditorPreview(),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller.titleController,
              inputFormatters: [_khmerDigitFormatter],
              style: AppFonts.appStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.noteTextPrimaryColor,
                height: 1.3,
                letterSpacing: -0.3,
              ),
              maxLines: null,
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                hintText: 'diary_title_hint'.tr,
                hintStyle: AppFonts.appStyle(
                  color: context.noteTextSecondaryColor.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => TextField(
                controller: controller.contentController,
                focusNode: controller.contentFocusNode,
                inputFormatters: [_khmerDigitFormatter],
                style: AppFonts.appStyle(
                  fontSize: 15.5,
                  color: context.noteTextPrimaryColor.withValues(alpha: 0.78),
                  height: 1.7,
                  letterSpacing: 0.1,
                  fontWeight: controller.isBold.value
                      ? FontWeight.w700
                      : FontWeight.w400,
                  fontStyle: controller.isItalic.value
                      ? FontStyle.italic
                      : FontStyle.normal,
                  decoration: controller.isUnderline.value
                      ? TextDecoration.underline
                      : null,
                ),
                maxLines: null,
                minLines: 4,
                textCapitalization: TextCapitalization.sentences,
                cursorColor: AppColors.appRed,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  hintText: 'diary_content_hint'.tr,
                  hintStyle: AppFonts.appStyle(
                    color: context.noteTextSecondaryColor.withValues(
                      alpha: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _AddBlockButton extends StatelessWidget {
  const _AddBlockButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.noteSurfaceColor,
          border: Border.all(color: context.noteChipBorderColor, width: 1),
        ),
        child: Icon(
          Icons.add_rounded,
          size: 22,
          color: context.noteTextPrimaryColor,
        ),
      ),
    );
  }
}
