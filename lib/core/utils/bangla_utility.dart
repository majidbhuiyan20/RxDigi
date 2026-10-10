/// Global Bengali Utility for Numbers, Dates, and Time Formatting
class BanglaUtility {
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
    'সোমবার',
    'মঙ্গলবার',
    'বুধবার',
    'বৃহস্পতিবার',
    'শুক্রবার',
    'শনিবার',
    'রবিবার',
  ];

  /// Convert any number or string with digits to Bengali digits
  static String toBn(dynamic input) {
    if (input == null) return '';
    final str = input.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_bnDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Format date as: 'শনিবার, ১০ অক্টোবর'
  static String formatFullDateBn(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final weekday = _bnWeekdays[(date.weekday - 1).clamp(0, 6)];
    final day = toBn(date.day);
    final month = _bnMonths[date.month - 1];
    return '$weekday, $day $month';
  }

  /// Format date as: '১০ অক্টোবর'
  static String formatDayMonthBn(DateTime date) {
    final day = toBn(date.day);
    final month = _bnMonths[date.month - 1];
    return '$day $month';
  }

  /// Convert time string like '08:00 AM' or '02:30 PM' to natural Bengali time
  static String formatTimeBn(String timeStr) {
    if (timeStr.isEmpty) return '';
    final parts = timeStr.trim().split(' ');
    if (parts.length < 2) return toBn(timeStr);

    final time = parts[0];
    final period = parts[1].toUpperCase();

    final timeBn = toBn(time);
    if (period == 'AM') {
      final hour = int.tryParse(time.split(':').first) ?? 0;
      if (hour < 5 || hour == 12) {
        return 'রাত $timeBn';
      } else if (hour < 11) {
        return 'সকাল $timeBn';
      } else {
        return 'দুপুর $timeBn';
      }
    } else {
      final hour = int.tryParse(time.split(':').first) ?? 0;
      if (hour < 4 || hour == 12) {
        return 'দুপুর $timeBn';
      } else if (hour < 7) {
        return 'বিকাল $timeBn';
      } else {
        return 'রাত $timeBn';
      }
    }
  }
}
