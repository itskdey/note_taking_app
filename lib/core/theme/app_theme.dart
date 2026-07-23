import 'package:flutter/material.dart';
import 'package:note_taking_app/core/values/app_colors.dart';

class AppTheme {
  static final ColorScheme _lightScheme =
      ColorScheme.fromSeed(
        primary: AppColors.primaryColor,
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        surface: AppColors.lightBoxColor,
        outline: AppColors.lightBorderColor,
      ).copyWith(
        primary: AppColors.primaryColor,
        onPrimary: AppColors.darkTextColor,
        secondary: AppColors.accent,
        onSecondary: AppColors.darkTextColor,
        tertiary: AppColors.sage,
        surface: AppColors.lightCardColor,
        onSurface: AppColors.lightTextColor,
        error: AppColors.danger,
        outline: AppColors.lightBorderColor,
        shadow: AppColors.warmShadow,
      );

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(
        primary: AppColors.accent,
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
        surface: AppColors.darkBoxColor,
        outline: AppColors.darkBorderColor,
      ).copyWith(
        primary: const Color(0xFFD99078),
        onPrimary: AppColors.darkBackgroundColor,
        secondary: const Color(0xFFC6A47B),
        tertiary: const Color(0xFFA8B49A),
        surface: AppColors.darkCardColor,
        onSurface: AppColors.darkTextColor,
        error: const Color(0xFFFFB4A9),
        outline: AppColors.darkBorderColor,
      );

  static final light = _buildTheme(
    scheme: _lightScheme,
    background: AppColors.lightBackgroundColor,
  );

  static final dark = _buildTheme(
    scheme: _darkScheme,
    background: AppColors.darkBackgroundColor,
  );

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color background,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      scaffoldBackgroundColor: background,
      colorScheme: scheme,
    );

    return base.copyWith(
      canvasColor: background,
      dividerColor: scheme.outline,
      splashColor: scheme.secondary.withValues(alpha: 0.10),
      highlightColor: scheme.secondary.withValues(alpha: 0.06),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: const Color(0x00000000),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: const Color(0x00000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: scheme.outline.withValues(alpha: 0.75)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 3,
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        shape: const CircleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: scheme.onSurface.withValues(alpha: 0.48)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.secondary, width: 1.4),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: const Color(0x00000000),
        modalBarrierColor: AppColors.primaryColor.withValues(alpha: 0.24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: TextStyle(color: scheme.surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
