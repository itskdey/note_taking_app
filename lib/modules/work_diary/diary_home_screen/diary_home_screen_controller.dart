part of 'diary_home_screen_view.dart';

class DiaryHomeController extends GetxController {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final RxList<DiaryEntryModel> entries = <DiaryEntryModel>[].obs;
  final RxInt selectedYear = DateTime.now().year.obs;

  /// The month currently selected in the timeline navigation.
  final Rxn<int> selectedMonth = Rxn<int>();
  final RxString greetingName = 'Mean Pheakdey'.obs;

  // Animation status
  final RxBool showSplash = true.obs;

  @override
  void onInit() {
    super.onInit();

    fetchEntries();

    Future.delayed(const Duration(milliseconds: 3500), () {
      showSplash.value = false;
    });
  }

  /// Months (1-12) that currently have at least one entry, newest first.
  List<int> get monthsWithEntries {
    final months = entries
        .where((e) => e.date.year == selectedYear.value)
        .map((e) => e.date.month)
        .toSet()
        .toList();
    months.sort((a, b) => b.compareTo(a));
    return months;
  }

  List<DiaryEntryModel> get visibleEntries {
    final list = entries
        .where((e) => e.date.year == selectedYear.value)
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Entries grouped by month, preserving descending date order within
  /// each group, for the sectioned timeline list.
  Map<int, List<DiaryEntryModel>> get groupedByMonth {
    final map = <int, List<DiaryEntryModel>>{};
    for (final entry in visibleEntries) {
      map.putIfAbsent(entry.date.month, () => []).add(entry);
    }
    return map;
  }

  bool get isEmpty => visibleEntries.isEmpty;

  Future<void> fetchEntries() async {
    entries.assignAll(await DiaryDatabaseService.instance.getEntries());
  }

  void selectMonth(int month) {
    selectedMonth.value = month;
  }

  Future<void> toggleBookmark(String id) async {
    final index = entries.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final updated = entries[index].copyWith(
      isBookmarked: !entries[index].isBookmarked,
    );
    entries[index] = updated;
    await DiaryDatabaseService.instance.upsertEntry(updated);
  }

  Future<void> deleteEntry(String id) async {
    entries.removeWhere((e) => e.id == id);
    await DiaryDatabaseService.instance.deleteEntry(id);
  }

  Future<void> openNewEntry() async {
    final result = await Get.toNamed(Routes.diaryEntry);
    if (result is DiaryEntryModel) {
      entries.add(result);
    }
  }

  Future<void> openEntry(DiaryEntryModel entry) async {
    if (entry.isLocked && !await _authenticateLockedEntry()) return;

    final result = await Get.toNamed(Routes.diaryEntry, arguments: entry);
    if (result is DiaryEntryModel) {
      final index = entries.indexWhere((e) => e.id == result.id);
      if (index != -1) entries[index] = result;
    }
  }

  Future<bool> _authenticateLockedEntry() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics && !isDeviceSupported) {
        _showAuthMessage(
          'diary_lock_unavailable_title'.tr,
          'diary_lock_unavailable_message'.tr,
        );
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: 'diary_unlock_auth_reason'.tr,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (error) {
      _showAuthMessage(
        'diary_lock_auth_failed_title'.tr,
        error.message ?? 'diary_lock_auth_failed_message'.tr,
      );
      return false;
    } catch (e) {
      debugPrint('LocalAuth error: $e');
      return false;
    }
  }

  void _showAuthMessage(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }
}
