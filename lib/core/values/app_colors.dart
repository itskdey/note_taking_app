import 'dart:ui';

class AppColors {
  AppColors._();

  // Core cozy palette: fog grey, slate blue, dusty teal, and frosted lavender.
  static const Color primaryColor = Color(0xFF3F4E5C);
  static const Color accent = Color(0xFF5B7C99);
  static const Color sage = Color(0xFF6E8E86);
  static const Color honey = Color(
    0xFF8C7FA8,
  ); // cool counterpart to old "honey" accent

  static const Color lightBackgroundColor = Color(0xFFEEF2F5);
  static const Color darkBackgroundColor = Color(0xFF171C21);

  static const Color lightTextColor = Color(0xFF2A333B);
  static const Color darkTextColor = Color(0xFFE9EEF2);

  static const Color lightCardColor = Color(0xFFFAFCFD);
  static const Color darkCardColor = Color(0xFF232A30);

  static const Color lightBoxColor = Color(0xFFFAFCFD);
  static const Color darkBoxColor = Color(0xFF232A30);

  static const Color lightBorderColor = Color(0xFFD6E0E6);
  static const Color darkBorderColor = Color(0xFF3B454E);

  // Kept for backwards compatibility; the app's action color is slate blue.
  static const Color appRed = accent;
  static const Color danger = Color(
    0xFFC2564C,
  ); // kept warm on purpose so alerts still stand out
  static const Color success = sage;
  static const Color info = Color(0xFF6F8494);

  static const Color bg = lightBackgroundColor;
  static const Color ink = primaryColor;
  static const Color inkSoft = Color(0xA65C6B78);
  static const Color card = lightCardColor;
  static const Color border = lightBorderColor;
  static const Color star = honey;

  static const Color noteSurface = lightCardColor;
  static const Color noteTextPrimary = lightTextColor;
  static const Color noteTextSecondary = inkSoft;
  static const Color noteDivider = lightBorderColor;
  static const Color noteChipBackground = Color(0xFFE1E9EE);
  static const Color noteChipBorder = lightBorderColor;
  static const Color notePill = primaryColor;
  static const Color noteYearWatermark = Color(0x243F4E5C);
  static const Color noteEmptyIcon = Color(0x4D3F4E5C);

  static const Color timeline = Color(0xFFC5D2DA);
  static const Color timelineBadge = sage;
  static const Color warmShadow = Color(
    0x1F3F4E5C,
  ); // name kept for compatibility, now a cool slate shadow
}
