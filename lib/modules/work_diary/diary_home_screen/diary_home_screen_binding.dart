part of 'diary_home_screen_view.dart';

class DiaryHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiaryHomeController>(() => DiaryHomeController());
  }
}
