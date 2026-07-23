import 'package:flutter/material.dart';
import 'package:flutter_bounceable/flutter_bounceable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:note_taking_app/core/values/app_fonts.dart';
import 'package:note_taking_app/core/values/app_images.dart';

class SliverAppBarCustom extends StatelessWidget {
  final String title;
  final String? upText;
  final List<Widget>? actions;

  const SliverAppBarCustom({
    super.key,
    required this.title,
    this.actions,
    this.upText,
  });

  @override
  Widget build(BuildContext context) {
    return _buildHeader(title: title, actions: actions);
  }

  SliverAppBar _buildHeader({required String title, List<Widget>? actions}) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      snap: false,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: Get.theme.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 73,
      flexibleSpace: SafeArea(
        bottom: false,
        child: Container(
          color: Get.theme.scaffoldBackgroundColor,
          child: Row(
            children: [
              Bounceable(
                onTap: () => Get.back(),
                child: Container(
                  width: 33,
                  height: 33,
                  margin: const EdgeInsets.only(left: 15, top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppImages.arrowBack,
                      width: 22,
                      height: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      upText ?? "khtextify.ai",
                      style: AppFonts.appStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    Text(
                      title.tr.replaceAll("\n", ""),
                      style: AppFonts.appStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              if (actions != null) ...[
                const SizedBox(width: 8),
                Row(mainAxisSize: MainAxisSize.min, children: actions),
                const SizedBox(width: 15),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
