part of '../diary_home_screen_view.dart';

class DiaryEmptyState extends StatelessWidget {
  const DiaryEmptyState({super.key, required this.year, this.onTap});

  final int year;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 15,
                    color: context.noteTextPrimaryColor,
                    height: 1.6,
                  ),
                  children: [
                    TextSpan(text: '${'diary_empty_tap'.tr} '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.edit_rounded,
                        size: 15,
                        color: context.noteTextPrimaryColor,
                      ),
                    ),
                    TextSpan(
                      text:
                          ' ${'diary_empty_suffix'.trParams({'year': KhmerDateUtils.toKhmerNumber(year)})}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
