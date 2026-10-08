import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum DayPeriod {
  morning,
  afternoon,
  evening,
  night,
}

class TimeContextHelper {
  TimeContextHelper._();

  static DayPeriod getCurrentPeriod() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return DayPeriod.morning;
    } else if (hour >= 12 && hour < 17) {
      return DayPeriod.afternoon;
    } else if (hour >= 17 && hour < 21) {
      return DayPeriod.evening;
    } else {
      return DayPeriod.night;
    }
  }

  static String getGreeting(bool isBn) {
    switch (getCurrentPeriod()) {
      case DayPeriod.morning:
        return isBn ? 'শুভ সকাল' : 'Good Morning';
      case DayPeriod.afternoon:
        return isBn ? 'শুভ অপরাহ্ন' : 'Good Afternoon';
      case DayPeriod.evening:
        return isBn ? 'শুভ সন্ধ্যা' : 'Good Evening';
      case DayPeriod.night:
        return isBn ? 'শুভ রাত্রি' : 'Good Night';
    }
  }

  static String getContextPrompt(bool isBn) {
    switch (getCurrentPeriod()) {
      case DayPeriod.morning:
        return isBn
            ? '☀️ সকালের ওষুধের সময় ও খালি পেটের সুগার চেক'
            : '☀️ Morning dose time & fasting sugar log';
      case DayPeriod.afternoon:
        return isBn
            ? '💧 দুপুরের ডোজ ও পর্যাপ্ত পানি পান নিশ্চিত করুন'
            : '💧 Afternoon medication & hydration focus';
      case DayPeriod.evening:
        return isBn
            ? '🚶 ডিনার-পূর্ব হালকা হাঁটা ও সান্ধ্য রুটিন'
            : '🚶 Pre-dinner evening walk & routine';
      case DayPeriod.night:
        return isBn
            ? '🌙 রাতের শেষ ওষুধ সেবন ও শান্তির ঘুম'
            : '🌙 Night doses & restful restorative sleep';
    }
  }

  static IconData getPeriodIcon() {
    switch (getCurrentPeriod()) {
      case DayPeriod.morning:
        return PhosphorIconsFill.sun;
      case DayPeriod.afternoon:
        return PhosphorIconsFill.sunHorizon;
      case DayPeriod.evening:
        return PhosphorIconsFill.cloudSun;
      case DayPeriod.night:
        return PhosphorIconsFill.moonStars;
    }
  }

  static List<Color> getPeriodGradient() {
    switch (getCurrentPeriod()) {
      case DayPeriod.morning:
        return const [
          Color(0xFF0F766E), // Clinical Deep Teal
          Color(0xFF0D9488),
          Color(0xFF14B8A6),
        ];
      case DayPeriod.afternoon:
        return const [
          Color(0xFF0F766E),
          Color(0xFF0D9488),
          Color(0xFF0284C7), // Sky touch in afternoon
        ];
      case DayPeriod.evening:
        return const [
          Color(0xFF115E59),
          Color(0xFF0F766E),
          Color(0xFF4338CA), // Deep Indigo Dusk
        ];
      case DayPeriod.night:
        return const [
          Color(0xFF042F2E), // Midnight Emerald Teal
          Color(0xFF0F766E),
          Color(0xFF1E1B4B), // Night Navy
        ];
    }
  }
}
