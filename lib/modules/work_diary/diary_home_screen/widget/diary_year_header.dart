part of '../diary_home_screen_view.dart';

class DiaryYearHeader extends StatelessWidget {
  const DiaryYearHeader({
    super.key,
    required this.greetingName,
    required this.year,
  });

  final String greetingName;
  final int year;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hello there 👋',
                        style: AppFonts.appStyle(
                          color: AppColors.noteTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${'diary_greeting'.trParams({'username': greetingName.split(' ').last})} ',
                  style: AppFonts.appStyle(
                    color: AppColors.noteTextSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40),
          Text(
            KhmerDateUtils.toKhmerNumber(year),
            style: AppFonts.appStyle(
              color: AppColors.noteYearWatermark,
              fontSize: 44,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
