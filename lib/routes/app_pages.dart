import 'package:get/get.dart';
import 'package:note_taking_app/modules/setting_screen/setting_screen_view.dart';
import 'package:note_taking_app/modules/work_diary/diary_entry_screen/diary_entry_screen_view.dart';
import 'package:note_taking_app/modules/work_diary/diary_home_screen/diary_home_screen_view.dart';

import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.diaryHome,
      page: () => DiaryHomeScreen(),
      binding: DiaryHomeBinding(),
    ),
    GetPage(
      name: Routes.diaryEntry,
      page: () => DiaryEntryScreen(),
      binding: DiaryEntryBinding(),
    ),
    GetPage(
      name: Routes.settingScreen,
      page: () => SettingScreenView(),
      binding: SettingScreenViewBinding(),
    ),
  ];
}
