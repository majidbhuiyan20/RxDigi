/// Utility functions for authentic Bengali and English date and number formatting in Women's Health.
class WomenHealthFormatters {
  static const Map<String, String> _bnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  static const List<String> _bnMonths = [
    'জানুয়ারি',
    'ফেব্রুয়ারি',
    'মার্চ',
    'এপ্রিল',
    'মে',
    'জুন',
    'জুলাই',
    'আগস্ট',
    'সেপ্টেম্বর',
    'অক্টোবর',
    'নভেম্বর',
    'ডিসেম্বর',
  ];

  static const List<String> _enMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static const List<String> _enMonthsFull = [
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

  static const List<String> _bnWeekdays = [
    'সোম',
    'মঙ্গল',
    'বুধ',
    'বৃহঃ',
    'শুক্র',
    'শনি',
    'রবি',
  ];

  static const List<String> _enWeekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Convert any integer/string digits into Bengali or English digits based on locale
  static String formatDigits(dynamic input, {bool isBn = true}) {
    final str = input.toString();
    if (!isBn) return str;
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_bnDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Backward compatible Bengali digits converter
  static String toBengaliDigits(dynamic input) => formatDigits(input, isBn: true);

  /// Format as '১৪ অক্টোবর' or '14 Oct'
  static String formatDayMonth(DateTime date, {bool isBn = true}) {
    final monthIdx = (date.month - 1).clamp(0, 11);
    if (isBn) {
      final day = toBengaliDigits(date.day);
      final month = _bnMonths[monthIdx];
      return '$day $month';
    } else {
      final month = _enMonths[monthIdx];
      return '${date.day} $month';
    }
  }

  /// Backward compatible '১৪ অক্টোবর'
  static String formatDayMonthBn(DateTime date) => formatDayMonth(date, isBn: true);

  /// Format as '১৪ অক্টোবর, ২০২৬' or '14 October, 2026'
  static String formatFullDate(DateTime date, {bool isBn = true}) {
    final monthIdx = (date.month - 1).clamp(0, 11);
    if (isBn) {
      final day = toBengaliDigits(date.day);
      final month = _bnMonths[monthIdx];
      final year = toBengaliDigits(date.year);
      return '$day $month, $year';
    } else {
      final month = _enMonthsFull[monthIdx];
      return '${date.day} $month, ${date.year}';
    }
  }

  /// Backward compatible '১৪ অক্টোবর, ২০২৬'
  static String formatFullDateBn(DateTime date) => formatFullDate(date, isBn: true);

  /// Return short weekday: 'সোম' or 'Mon'
  static String getWeekday(DateTime date, {bool isBn = true}) {
    final idx = (date.weekday - 1).clamp(0, 6);
    return isBn ? _bnWeekdays[idx] : _enWeekdays[idx];
  }

  /// Backward compatible 'সোম'
  static String getBengaliWeekday(DateTime date) => getWeekday(date, isBn: true);

  /// Format days count: '২৮ দিন' or '28 days'
  static String formatDaysCount(int count, {bool isBn = true}) {
    if (isBn) {
      return '${formatDigits(count, isBn: true)} দিন';
    }
    return count == 1 ? '1 day' : '$count days';
  }

  /// Format date key as 'YYYY-MM-DD'
  static String toDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if two DateTimes are the exact same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
