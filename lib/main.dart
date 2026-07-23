import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_taking_app/core/localization/translation_service.dart';
import 'package:note_taking_app/core/theme/app_theme.dart';
import 'package:note_taking_app/core/theme/theme_service.dart';
import 'package:note_taking_app/routes/app_pages.dart';
import 'package:note_taking_app/routes/app_routes.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeService().theme,
      initialRoute: Routes.diaryHome,
      defaultTransition: Transition.fade,
      getPages: AppPages.routes,
      translations: TranslationService(),
      locale: TranslationService.getLocale(),
      fallbackLocale: TranslationService.fallbackLocale,
    );
  }
}
