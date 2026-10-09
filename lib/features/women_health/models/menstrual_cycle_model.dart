enum CyclePhase {
  menstrual,
  follicular,
  fertileOvulation,
  luteal,
}

extension CyclePhaseExtension on CyclePhase {
  String get nameBn {
    switch (this) {
      case CyclePhase.menstrual:
        return 'পিরিয়ড ফেজ (মাসিক)';
      case CyclePhase.follicular:
        return 'ফলিকুলার ফেজ (শক্তি বৃদ্ধি)';
      case CyclePhase.fertileOvulation:
        return 'উর্বর সময় ও ডিম্বস্ফোটন (ওভুলেশন)';
      case CyclePhase.luteal:
        return 'লুটিয়াল ফেজ (বিশ্রাম ও প্রস্তুতি)';
    }
  }

  String get nameEn {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.fertileOvulation:
        return 'Fertile & Ovulation Window';
      case CyclePhase.luteal:
        return 'Luteal Phase';
    }
  }

  String get pregnancyChanceBn {
    switch (this) {
      case CyclePhase.menstrual:
        return 'গর্ভধারণের সম্ভাবনা: অত্যন্ত কম';
      case CyclePhase.follicular:
        return 'গর্ভধারণের সম্ভাবনা: কম';
      case CyclePhase.fertileOvulation:
        return 'গর্ভধারণের সম্ভাবনা: সর্বোচ্চ (High)';
      case CyclePhase.luteal:
        return 'গর্ভধারণের সম্ভাবনা: কম';
    }
  }

  String get adviceBn {
    switch (this) {
      case CyclePhase.menstrual:
        return 'পর্যাপ্ত বিশ্রাম নিন, কুসুম গরম পানি পান করুন এবং আয়রনসমৃদ্ধ খাবার (ডাল, পালং শাক, বেদানা) গ্রহণ করুন।';
      case CyclePhase.follicular:
        return 'শরীরে এস্ট্রোজেন হরমোন বাড়ে, কর্মশক্তি বেশি থাকে। ব্যায়াম ও পুষ্টিকর খাবার গ্রহণের আদর্শ সময়।';
      case CyclePhase.fertileOvulation:
        return 'গর্ভধারণের পরিকল্পনা থাকলে এটি সবচেয়ে অনুকূল সময়। শরীর হাইড্রেটেড রাখুন ও হালকা স্ট্রেচিং করুন।';
      case CyclePhase.luteal:
        return 'প্রজেস্টেরন বাড়ায় ক্লান্তি বা মুড সুইং হতে পারে। ম্যাগনেসিয়াম সমৃদ্ধ খাবার (কলা, বাদাম) ও হালকা হাঁটাচলা উপকারী।';
    }
  }
}

class MenstrualCycleModel {
  final int cycleLength; // e.g., 28 days (standard 21-35)
  final int periodDuration; // e.g., 5 days (standard 3-7)
  final DateTime lastPeriodStartDate;

  const MenstrualCycleModel({
    this.cycleLength = 28,
    this.periodDuration = 5,
    required this.lastPeriodStartDate,
  });

  /// Days passed since the start of the last recorded period
  int get daysSinceStart {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      lastPeriodStartDate.year,
      lastPeriodStartDate.month,
      lastPeriodStartDate.day,
    );
    final diff = today.difference(start).inDays;
    return diff >= 0 ? diff : 0;
  }

  /// Day in the current cycle (1 to cycleLength)
  int get currentCycleDay {
    final day = (daysSinceStart % cycleLength) + 1;
    return day;
  }

  /// Estimated ovulation day (typically 14 days before the next period starts)
  int get ovulationDay => cycleLength - 14;

  /// Current biological phase
  CyclePhase get currentPhase {
    final day = currentCycleDay;
    if (day <= periodDuration) {
      return CyclePhase.menstrual;
    } else if (day < (ovulationDay - 4)) {
      return CyclePhase.follicular;
    } else if (day <= (ovulationDay + 1)) {
      return CyclePhase.fertileOvulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  /// Days remaining until next predicted period
  int get daysUntilNextPeriod {
    final remaining = cycleLength - (currentCycleDay - 1);
    return remaining > 0 ? remaining : cycleLength;
  }

  /// Predicted date of next period
  DateTime get nextPeriodDate {
    final cyclesPassed = daysSinceStart ~/ cycleLength;
    return lastPeriodStartDate.add(Duration(days: (cyclesPassed + 1) * cycleLength));
  }

  /// Predicted ovulation date
  DateTime get nextOvulationDate {
    final nextPeriod = nextPeriodDate;
    return nextPeriod.subtract(const Duration(days: 14));
  }

  /// Progress of current cycle (0.0 to 1.0)
  double get cycleProgress => (currentCycleDay / cycleLength).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() {
    return {
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'lastPeriodStartDate': lastPeriodStartDate.toIso8601String(),
    };
  }

  factory MenstrualCycleModel.fromJson(Map<String, dynamic> map) {
    return MenstrualCycleModel(
      cycleLength: map['cycleLength'] as int? ?? 28,
      periodDuration: map['periodDuration'] as int? ?? 5,
      lastPeriodStartDate: DateTime.tryParse(map['lastPeriodStartDate'] as String? ?? '') ??
          DateTime.now().subtract(const Duration(days: 10)),
    );
  }

  MenstrualCycleModel copyWith({
    int? cycleLength,
    int? periodDuration,
    DateTime? lastPeriodStartDate,
  }) {
    return MenstrualCycleModel(
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
    );
  }
}

