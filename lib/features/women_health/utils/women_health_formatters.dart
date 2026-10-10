/// Utility functions for authentic Bengali date and number formatting in Women's Health.
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

  static const List<String> _bnWeekdays = [
    'সোম',
    'মঙ্গল',
    'বুধ',
    'বৃহঃ',
    'শুক্র',
    'শনি',
    'রবি',
  ];

  /// Convert any integer/string digits into Bengali digits
  static String toBengaliDigits(dynamic input) {
    final str = input.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_bnDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Format as '১৪ অক্টোবর'
  static String formatDayMonthBn(DateTime date) {
    final day = toBengaliDigits(date.day);
    final month = _bnMonths[date.month - 1];
    return '$day $month';
  }

  /// Format as '১৪ অক্টোবর, ২০২৬'
  static String formatFullDateBn(DateTime date) {
    final day = toBengaliDigits(date.day);
    final month = _bnMonths[date.month - 1];
    final year = toBengaliDigits(date.year);
    return '$day $month, $year';
  }

  /// Return short Bengali weekday: 'সোম', 'মঙ্গল', etc.
  static String getBengaliWeekday(DateTime date) {
    // DateTime.weekday: 1 = Monday, 7 = Sunday
    return _bnWeekdays[(date.weekday - 1).clamp(0, 6)];
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

