import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Locale-aware date, time, and number formatting for the diary UI.
class KhmerDateUtils {
  KhmerDateUtils._();

  static bool get _isKhmer => Get.locale?.languageCode == 'km';

  static const List<String> digits = [
    '០',
    '១',
    '២',
    '៣',
    '៤',
    '៥',
    '៦',
    '៧',
    '៨',
    '៩',
  ];

  static const List<String> months = [
    'មករា',
    'កុម្ភៈ',
    'មីនា',
    'មេសា',
    'ឧសភា',
    'មិថុនា',
    'កក្កដា',
    'សីហា',
    'កញ្ញា',
    'តុលា',
    'វិច្ឆិកា',
    'ធ្នូ',
  ];

  static const List<String> monthsEnglish = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  /// Short weekday labels, Monday-first, matching DateTime.weekday (1-7).
  static const List<String> weekdaysShort = [
    'ចន្ទ',
    'អង្គារ',
    'ពុធ',
    'ព្រហ',
    'សុក្រ',
    'សៅរ៍',
    'អាទិត្យ',
  ];

  static const List<String> weekdaysShortEnglish = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static String monthName(int month) {
    final index = (month - 1).clamp(0, 11);
    return (_isKhmer ? months : monthsEnglish)[index];
  }

  static String weekdayShort(DateTime date) {
    final index = (date.weekday - 1).clamp(0, 6);
    return (_isKhmer ? weekdaysShort : weekdaysShortEnglish)[index];
  }

  static String toKhmerNumber(Object? value) {
    if (value == null) return '';
    final text = value.toString();
    if (!_isKhmer) {
      return text.replaceAllMapped(RegExp('[០១២៣៤៥៦៧៨៩]'), (match) {
        return digits.indexOf(match.group(0)!).toString();
      });
    }
    return text.replaceAllMapped(RegExp(r'\d'), (match) {
      return digits[int.parse(match.group(0)!)];
    });
  }

  static String formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    if (!_isKhmer) {
      final period = dt.hour < 12 ? 'AM' : 'PM';
      return '$hour:$minute $period';
    }

    final period = switch (dt.hour) {
      >= 0 && < 6 || >= 18 => 'យប់',
      >= 12 => 'ល្ងាច',
      _ => 'ព្រឹក',
    };
    return '${toKhmerNumber(hour)}:${toKhmerNumber(minute)} $period';
  }

  static String dayNumber(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    return toKhmerNumber(day);
  }

  static final TextInputFormatter khmerDigitFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final converted = toKhmerNumber(newValue.text);
        if (converted == newValue.text) return newValue;
        return newValue.copyWith(text: converted);
      });
}
