part of 'diary_entry_screen_view.dart';

class DiaryEntryBinding extends Bindings {
  @override
  void dependencies() {
    final DiaryEntryModel? entry = Get.arguments is DiaryEntryModel
        ? Get.arguments
        : null;
    Get.lazyPut<DiaryEntryController>(
      () => DiaryEntryController(initialEntry: entry),
    );
  }
}
