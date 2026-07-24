import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:note_taking_app/core/values/app_colors.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';
import 'package:note_taking_app/core/values/app_images.dart';

class AppBarCustom extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? upText;
  final List<Widget>? actions; // Added optional list of action widgets
  final bool safeAreaBottom;
  final bool? safeAreaTop;
  final VoidCallback? onBack;

  const AppBarCustom({
    super.key,
    required this.title,
    this.upText = "komnottra.setting",
    this.safeAreaBottom = false,
    this.safeAreaTop,
    this.actions,
    this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(73);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 73,
      flexibleSpace: SafeArea(
        bottom: safeAreaBottom,
        top: safeAreaTop ?? true,
        child: Container(
          color: Get.theme.scaffoldBackgroundColor,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left side: Back Button Button
              Bounceable(
                onTap: onBack ?? () => Get.back(),
                child: Container(
                  width: 33,
                  height: 33,
                  margin: const EdgeInsets.only(left: 15, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? colors.surface
                        : AppColors.noteChipBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? colors.outline.withValues(alpha: 0.7)
                          : AppColors.noteChipBorder,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.arrowBack,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        colors.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // Middle: Title Header Row text segment wrapper
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5),
                    Text(
                      upText!.tr,
                      style: AppFonts.appStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1,
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    Text(
                      title.tr.replaceAll("\n", ""),
                      style: AppFonts.appStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Right side: Optional dynamic layout configuration lists
              if (actions != null) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
