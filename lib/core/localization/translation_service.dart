import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:note_taking_app/core/localization/languages/en_us.dart';
import 'package:note_taking_app/core/localization/languages/km_kh.dart';

class TranslationService extends Translations {
  static const locale = Locale('km', 'KH');
  static const fallbackLocale = Locale('km', 'KH');

  static final languages = ['English', 'Khmer'];

  static final locales = [const Locale('en', 'US'), const Locale('km', 'KH')];

  @override
  Map<String, Map<String, String>> get keys => {'en_US': enUs, 'km_KH': kmKh};

  static final box = GetStorage();

  static void changeLocale(String lang) {
    box.write('lang', lang);
    Get.updateLocale(Locale(lang));
  }

  static Locale getLocale() {
    final savedLocale = box.read<String>('lang') ?? 'km';

    if (savedLocale == 'en' || savedLocale == 'en_US') {
      return const Locale('en', 'US');
    }

    return const Locale('km', 'KH');
  }
}
