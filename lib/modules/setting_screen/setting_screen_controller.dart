part of 'setting_screen_view.dart';

class SettingScreenViewController extends GetxController {
  final ThemeService _themeService = ThemeService();

  final RxBool isDarkMode = false.obs;
  final RxString languageCode = 'km'.obs;

  String get languageLabel =>
      languageCode.value == 'en' ? 'English' : 'ភាសាខ្មែរ';

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _themeService.theme == ThemeMode.dark;
    languageCode.value = TranslationService.getLocale().languageCode;
  }

  void setDarkMode(bool enabled) {
    if (isDarkMode.value == enabled) return;
    isDarkMode.value = enabled;
    _themeService.switchTheme();
  }

  void setLanguage(String code) {
    if (languageCode.value == code) return;
    languageCode.value = code;
    TranslationService.changeLocale(code);
  }
}
