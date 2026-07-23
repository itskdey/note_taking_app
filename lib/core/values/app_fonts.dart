import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppFontFamily {
  brier('Brier'),
  mona('Mona'),
  niradeiRegular('Niradei'),
  niradeiSemiBold('Niradei'),
  niradeiBold('Niradei'),
  romneaItalic('Romnea'),
  rosela('Rosela');

  const AppFontFamily(this.family);

  final String family;
}

class AppFonts {
  static TextStyle appStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    bool keepEnglish = false,
    List<FontFeature>? fontFeatures,
    AppFontFamily? appFontFamily,
    Paint? background,
  }) {
    final isKhmer = Get.locale?.languageCode == 'km' && !keepEnglish;

    /// Default font
    TextStyle style = isKhmer
        ? GoogleFonts.googleSans(
            fontSize: fontSize,

            fontWeight: fontWeight,
            height: height ?? 1.4,
            fontFeatures: fontFeatures,
            background: background,
          )
        : GoogleFonts.spaceGrotesk(
            fontSize: fontSize,
            fontWeight: fontWeight,
            height: height ?? 1.2,
            background: background,
            fontFeatures: fontFeatures,
          );

    /// Custom local font override
    if (appFontFamily != null) {
      style = style.copyWith(fontFamily: appFontFamily.family);

      /// Optional automatic weight handling
      switch (appFontFamily) {
        case AppFontFamily.niradeiRegular:
          style = style.copyWith(fontWeight: FontWeight.w400);
          break;

        case AppFontFamily.niradeiSemiBold:
          style = style.copyWith(fontWeight: FontWeight.w600);
          break;

        case AppFontFamily.niradeiBold:
          style = style.copyWith(fontWeight: FontWeight.w700);
          break;

        case AppFontFamily.romneaItalic:
          style = style.copyWith(fontStyle: FontStyle.italic);
          break;

        default:
          break;
      }
    }

    return style.copyWith(
      color: color,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  static List<InlineSpan> buildMixedTextSpans(
    String text,
    FontWeight fontWeight, {
    double fontSize = 15,
    double height = 1.2,
    bool isHeader = false,
    Color? color,
    AppFontFamily? englishFamily,
  }) {
    final khmerRegex = RegExp(r'[\u1780-\u17FF]+');

    final matches = RegExp(
      r'[\u1780-\u17FF]+|[^\u1780-\u17FF]+',
    ).allMatches(text);

    return matches.map((m) {
      final part = m.group(0)!;
      final isKhmer = khmerRegex.hasMatch(part);

      return TextSpan(
        text: part,

        /// Khmer → Google Sans
        style: isKhmer
            ? GoogleFonts.googleSans(
                fontSize: fontSize,
                fontWeight: fontWeight,
                height: 1.4,
                color: color,
              )
            /// English → Customizable font
            : appStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                height: height,
                color: color,
                keepEnglish: true,
                appFontFamily: isHeader ? AppFontFamily.mona : englishFamily,
              ),
      );
    }).toList();
  }
}
