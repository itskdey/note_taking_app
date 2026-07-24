import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_taking_app/core/values/app_colors.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';
import 'package:note_taking_app/core/values/app_images.dart';
import 'package:note_taking_app/widget/animation/animated_widget.dart';
import 'package:note_taking_app/widget/animation/big_brand_text.dart';
import 'package:note_taking_app/widget/button/animated_submit_button.dart';

class AppNameSheet {
  static void show({
    required String title,
    String? subTitle,
    VoidCallback? onTap,
    VoidCallback? secondaryOnTap,
    RxString? submitState,
    String successText = "Success",
    bool badge = false,

    /// Sheet
    Color? backgroundColor,
    Color? barrierColor,
    double borderRadius = 25,
    bool isDismissible = true,
    bool enableDrag = true,

    /// Handle
    bool showHandle = true,
    Color? handleColor,

    /// Header
    String brandText = "komnottra.",
    String sinceText = "since 2026",
    String authorText = "by Mean Pheakdey",
    bool showHeader = true,
    double rightHeaderPadding = 100,

    /// Button
    String buttonText = "OK",
    String? secondaryButtonText,
    Widget? buttonIcon,
    Widget? secondaryButtonIcon,
    Color? buttonColor,
    Color? buttonTextColor,
    double buttonHeight = 50,

    /// Text style
    TextStyle? titleStyle,
    TextStyle? subTitleStyle,
    TextStyle? brandStyle,
    TextStyle? metaStyle,

    /// Layout
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 24,
    ),
    EdgeInsetsGeometry headerPadding = EdgeInsets.zero,

    /// Content
    Widget? content,

    /// Animation
    int delay = 300,
  }) {
    Get.bottomSheet(
      AppNameSheetWidget(
        rightHeaderPadding: rightHeaderPadding,
        badge: badge,
        successText: successText,
        submitState: submitState ?? "idle".obs,
        title: title,
        subTitle: subTitle,
        onTap: onTap,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        showHandle: showHandle,
        handleColor: handleColor,
        brandText: brandText,
        sinceText: sinceText,
        authorText: authorText,
        showHeader: showHeader,
        buttonText: buttonText,
        buttonIcon: buttonIcon,
        buttonColor: buttonColor,
        buttonTextColor: buttonTextColor,
        buttonHeight: buttonHeight,
        titleStyle: titleStyle,
        subTitleStyle: subTitleStyle,
        brandStyle: brandStyle,
        metaStyle: metaStyle,
        contentPadding: contentPadding,
        headerPadding: headerPadding,
        delay: delay,
        secondaryOnTap: secondaryOnTap,
        secondaryButtonText: secondaryButtonText,
        secondaryButtonIcon: secondaryButtonIcon,
        content: content,
      ),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      barrierColor: barrierColor,
    );
  }
}

class AppNameSheetWidget extends StatelessWidget {
  final Widget? content;

  final RxString submitState;
  final int delay;
  final VoidCallback? onTap;
  final VoidCallback? secondaryOnTap;
  final bool badge;

  final String title;
  final String? subTitle;

  final Color? backgroundColor;
  final double borderRadius;

  final bool showHandle;
  final Color? handleColor;

  final bool showHeader;
  final String brandText;
  final String sinceText;
  final String successText;
  final String authorText;

  final String buttonText;
  final String? secondaryButtonText;
  final Widget? buttonIcon;
  final Widget? secondaryButtonIcon;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final double buttonHeight;

  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final TextStyle? brandStyle;
  final TextStyle? metaStyle;

  final EdgeInsetsGeometry contentPadding;
  final EdgeInsetsGeometry headerPadding;
  final double rightHeaderPadding;

  const AppNameSheetWidget({
    this.content,
    this.badge = false,
    super.key,
    required this.title,
    required this.successText,
    this.subTitle,
    this.onTap,
    this.delay = 300,
    this.backgroundColor,
    this.borderRadius = 25,
    this.showHandle = true,
    this.handleColor,
    this.showHeader = true,
    this.brandText = "komnottra.",
    this.sinceText = "since 2026",
    this.authorText = "by Mean Pheakdey",
    this.buttonText = "Change language",
    this.buttonIcon,
    this.buttonColor,
    this.buttonTextColor,
    this.buttonHeight = 50,
    this.titleStyle,
    required this.submitState,
    this.subTitleStyle,
    this.brandStyle,
    this.metaStyle,
    this.secondaryButtonText,
    this.secondaryOnTap,
    this.secondaryButtonIcon,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 24,
    ),
    this.headerPadding = EdgeInsets.zero,
    this.rightHeaderPadding = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.appBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
      ),
      child: CustomAnimatedWidget(
        delay: delay,
        from: SlideFrom.bottom,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHandle) ...[const SizedBox(height: 10), _buildHandle()],

            if (showHeader)
              AppNameHeader(
                delay: delay,
                padding: headerPadding,
                brandText: brandText,
                sinceText: sinceText,
                authorText: authorText,
                brandStyle: brandStyle,
                metaStyle: metaStyle,
                rightHeaderPadding: rightHeaderPadding,
              ),

            Padding(
              padding: contentPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAnimatedWidget(
                    delay: delay + 200,
                    from: SlideFrom.left,
                    child: Row(
                      spacing: 10,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style:
                                titleStyle ??
                                GoogleFonts.googleSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                          ),
                        ),

                        if (badge) ...[
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),

                            child: Center(
                              child: Text(
                                "Experimental / Beta",
                                style: AppFonts.appStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (subTitle != null && subTitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    CustomAnimatedWidget(
                      delay: delay + 300,
                      from: SlideFrom.left,
                      child: Text(
                        subTitle!,
                        style:
                            subTitleStyle ??
                            AppFonts.appStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                      ),
                    ),
                  ],

                  if (content != null) ...[
                    const SizedBox(height: 24),
                    CustomAnimatedWidget(
                      delay: delay + 300,
                      from: SlideFrom.left,
                      child: content!,
                    ),
                  ],

                  const SizedBox(height: 24),

                  Obx(() {
                    final hideSecondary =
                        submitState.value == ButtonState.loading;

                    return Row(
                      children: [
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOutCubic,
                          child: (hideSecondary || secondaryButtonText == null)
                              ? const SizedBox.shrink()
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: (Get.width - 40) / 2,
                                      child: AppNameSheetButton(
                                        text: secondaryButtonText!,
                                        onTap:
                                            secondaryOnTap ?? () => Get.back(),
                                        height: buttonHeight,
                                        color: Colors.grey.withValues(
                                          alpha: 0.12,
                                        ),
                                        textColor:
                                            AppColors.darkBackgroundColor,
                                        icon: secondaryButtonIcon,
                                        showDefaultIcon:
                                            secondaryButtonIcon != null,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                ),
                        ),

                        Expanded(
                          child: CustomAnimatedWidget(
                            delay: delay + 400,
                            from: SlideFrom.bottom,
                            child: AnimatedSubmitButton(
                              text: buttonText,
                              successText: successText,
                              onTap: onTap ?? () => Get.back(),
                              submitState: submitState,
                              textColor: buttonTextColor,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: handleColor ?? AppColors.darkBorderColor,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class AppNameHeader extends StatelessWidget {
  final int delay;
  final EdgeInsetsGeometry? padding;

  final String brandText;
  final String sinceText;
  final String authorText;

  final TextStyle? brandStyle;
  final TextStyle? metaStyle;
  final double rightHeaderPadding;

  const AppNameHeader({
    super.key,
    this.delay = 300,
    this.padding,
    this.brandText = "komnottra.",
    this.sinceText = "since 2026",
    this.authorText = "by Mean Pheakdey",
    this.brandStyle,
    this.metaStyle,
    this.rightHeaderPadding = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: BigBrandReveal(
            delay: Duration(milliseconds: delay),
            child: SizedBox(
              width: Get.width,
              child: FittedBox(
                child: Text(
                  brandText,
                  style:
                      brandStyle ??
                      AppFonts.appStyle(
                        appFontFamily: AppFontFamily.brier,
                        height: 1.2,
                      ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 3),

        CustomAnimatedWidget(
          delay: delay + 100,
          from: SlideFrom.left,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Text(
                sinceText,
                style:
                    metaStyle ??
                    AppFonts.appStyle(
                      fontSize: 12,
                      height: -1.5,
                      fontStyle: FontStyle.normal,
                      appFontFamily: AppFontFamily.brier,
                    ),
              ),
              const Spacer(),
              Text(
                authorText,
                style:
                    metaStyle ??
                    AppFonts.appStyle(
                      fontSize: 12,
                      height: -1.5,
                      fontStyle: FontStyle.normal,
                      appFontFamily: AppFontFamily.brier,
                    ),
              ),
              SizedBox(width: rightHeaderPadding),
            ],
          ),
        ),
      ],
    );
  }
}

class AppNameSheetButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Widget? icon;
  final Color? color;
  final Color? textColor;
  final double height;
  final bool showDefaultIcon;
  final Color? iconColor;

  const AppNameSheetButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.color,
    this.textColor,
    this.height = 50,
    this.showDefaultIcon = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Bounceable(
      onTap: onTap,
      child: Container(
        width: Get.width,
        height: height,
        padding: const EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: color ?? AppColors.primaryColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: AppFonts.appStyle(
                color: textColor ?? context.appBackgroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            icon != null
                ? Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iconColor ?? Colors.white,
                      // border: Border.all(color: AppColors.lightBorderColor),
                    ),
                    child: Center(child: icon!),
                  )
                : showDefaultIcon
                ? _defaultIcon()
                : const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  Widget _defaultIcon() {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AppColors.lightBorderColor),
      ),
      child: Center(child: Image.asset(AppImages.khm, width: 24, height: 24)),
    );
  }
}
