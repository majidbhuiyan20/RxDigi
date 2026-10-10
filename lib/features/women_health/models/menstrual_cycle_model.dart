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

  String name(bool isBn) => isBn ? nameBn : nameEn;

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

  String get pregnancyChanceEn {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Chance of Pregnancy: Very Low';
      case CyclePhase.follicular:
        return 'Chance of Pregnancy: Low';
      case CyclePhase.fertileOvulation:
        return 'Chance of Pregnancy: High (Peak)';
      case CyclePhase.luteal:
        return 'Chance of Pregnancy: Low';
    }
  }

  String pregnancyChance(bool isBn) => isBn ? pregnancyChanceBn : pregnancyChanceEn;

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

  String get adviceEn {
    switch (this) {
      case CyclePhase.menstrual:
        return 'Rest adequately, stay warm, hydrate well, and eat iron-rich foods (lentils, spinach, pomegranate).';
      case CyclePhase.follicular:
        return 'Estrogen is rising, energy levels peak. Optimal window for aerobic workouts and nutrient-rich meals.';
      case CyclePhase.fertileOvulation:
        return 'Peak fertility window. Keep your body well-hydrated, manage stress, and do gentle movement.';
      case CyclePhase.luteal:
        return 'Progesterone rises, which can trigger PMS or fatigue. Magnesium-rich foods (bananas, almonds) help.';
    }
  }

  String advice(bool isBn) => isBn ? adviceBn : adviceEn;
}

/// A logged past cycle record for historical cycle tracking & doctor summary
class HistoricalCycleEntry {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength; // Length in days compared to previous cycle
  final int periodDuration; // Bleeding days (e.g. 5)
  final String? notes;

  const HistoricalCycleEntry({
    required this.id,
    required this.startDate,
    this.endDate,
    required this.cycleLength,
    this.periodDuration = 5,
    this.notes,
  });

  /// FIGO / ACOG criteria: Normal menstrual cycle is 21 to 35 days
  bool get isIrregular => cycleLength < 21 || cycleLength > 35;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'notes': notes,
    };
  }

  factory HistoricalCycleEntry.fromJson(Map<String, dynamic> map) {
    return HistoricalCycleEntry(
      id: map['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      startDate: DateTime.tryParse(map['startDate'] as String? ?? '') ?? DateTime.now(),
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate'] as String) : null,
      cycleLength: map['cycleLength'] as int? ?? 28,
      periodDuration: map['periodDuration'] as int? ?? 5,
      notes: map['notes'] as String?,
    );
  }

  HistoricalCycleEntry copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodDuration,
    String? notes,
  }) {
    return HistoricalCycleEntry(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      notes: notes ?? this.notes,
    );
  }
}

/// Birth Control (Oral Contraceptive Pill - OCP) Tracker State
class OCPTrackerState {
  final bool isEnabled;
  final String pillBrand; // e.g., 'Femicon', 'Ovostat-Gold', 'Marvelon'
  final int packDays; // 21 or 28 pills pack
  final DateTime? packStartDate;
  final String pillTime; // e.g. '09:00 PM'
  final String lastTakenDateKey; // YYYY-MM-DD when pill was marked taken

  const OCPTrackerState({
    this.isEnabled = false,
    this.pillBrand = 'Femicon',
    this.packDays = 28,
    this.packStartDate,
    this.pillTime = '09:00 PM',
    this.lastTakenDateKey = '',
  });

  /// Day in current active pill pack (1 to 21 or 28)
  int get currentPackDay {
    if (packStartDate == null) return 1;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(packStartDate!.year, packStartDate!.month, packStartDate!.day);
    final diff = today.difference(start).inDays;
    return (diff % packDays) + 1;
  }

  bool get isTakenToday {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastTakenDateKey == todayKey;
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'pillBrand': pillBrand,
      'packDays': packDays,
      'packStartDate': packStartDate?.toIso8601String(),
      'pillTime': pillTime,
      'lastTakenDateKey': lastTakenDateKey,
    };
  }

  factory OCPTrackerState.fromJson(Map<String, dynamic> map) {
    return OCPTrackerState(
      isEnabled: map['isEnabled'] as bool? ?? false,
      pillBrand: map['pillBrand'] as String? ?? 'Femicon',
      packDays: map['packDays'] as int? ?? 28,
      packStartDate: map['packStartDate'] != null ? DateTime.tryParse(map['packStartDate'] as String) : null,
      pillTime: map['pillTime'] as String? ?? '09:00 PM',
      lastTakenDateKey: map['lastTakenDateKey'] as String? ?? '',
    );
  }

  OCPTrackerState copyWith({
    bool? isEnabled,
    String? pillBrand,
    int? packDays,
    DateTime? packStartDate,
    String? pillTime,
    String? lastTakenDateKey,
  }) {
    return OCPTrackerState(
      isEnabled: isEnabled ?? this.isEnabled,
      pillBrand: pillBrand ?? this.pillBrand,
      packDays: packDays ?? this.packDays,
      packStartDate: packStartDate ?? this.packStartDate,
      pillTime: pillTime ?? this.pillTime,
      lastTakenDateKey: lastTakenDateKey ?? this.lastTakenDateKey,
    );
  }
}

/// Iron & Folic Acid Supplement State (Crucial for anemia prevention during menstruation)
class IronSupplementState {
  final bool isEnabled;
  final String supplementName; // e.g. 'Fefol-CI', 'I-Car'
  final String supplementTime; // e.g. '01:30 PM' (After Lunch)
  final String lastTakenDateKey;

  const IronSupplementState({
    this.isEnabled = false,
    this.supplementName = 'Fefol-CI (আয়রন + ফলিক এসিড)',
    this.supplementTime = '01:30 PM',
    this.lastTakenDateKey = '',
  });

  bool get isTakenToday {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return lastTakenDateKey == todayKey;
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'supplementName': supplementName,
      'supplementTime': supplementTime,
      'lastTakenDateKey': lastTakenDateKey,
    };
  }

  factory IronSupplementState.fromJson(Map<String, dynamic> map) {
    return IronSupplementState(
      isEnabled: map['isEnabled'] as bool? ?? false,
      supplementName: map['supplementName'] as String? ?? 'Fefol-CI (আয়রন + ফলিক এসিড)',
      supplementTime: map['supplementTime'] as String? ?? '01:30 PM',
      lastTakenDateKey: map['lastTakenDateKey'] as String? ?? '',
    );
  }

  IronSupplementState copyWith({
    bool? isEnabled,
    String? supplementName,
    String? supplementTime,
    String? lastTakenDateKey,
  }) {
    return IronSupplementState(
      isEnabled: isEnabled ?? this.isEnabled,
      supplementName: supplementName ?? this.supplementName,
      supplementTime: supplementTime ?? this.supplementTime,
      lastTakenDateKey: lastTakenDateKey ?? this.lastTakenDateKey,
    );
  }
}

class MenstrualCycleModel {
  final bool isConfigured;
  final int cycleLength; // e.g., 28 days (standard 21-35)
  final int periodDuration; // e.g., 5 days (standard 3-7)
  final DateTime lastPeriodStartDate;

  const MenstrualCycleModel({
    this.isConfigured = false,
    this.cycleLength = 28,
    this.periodDuration = 5,
    required this.lastPeriodStartDate,
  });

  /// Check if cycle is clinically irregular (< 21 or > 35 days - FIGO criteria)
  bool get isIrregularCycle => cycleLength < 21 || cycleLength > 35;

  /// Clinical regularity status description
  String cycleRegularityDescription(bool isBn) {
    if (cycleLength < 21) {
      return isBn
          ? 'স্বল্পমেয়াদী অনিয়মিত সাইকেল (< ২১ দিন - পলিমেনোরিয়া)'
          : 'Short Irregular Cycle (< 21 days - Polymenorrhea)';
    } else if (cycleLength > 35) {
      return isBn
          ? 'দীর্ঘমেয়াদী অনিয়মিত সাইকেল (> ৩৫ দিন - অলিগোমেনোরিয়া / PCOS ঝুঁকি)'
          : 'Prolonged Irregular Cycle (> 35 days - Suspected PCOS / Oligomenorrhea)';
    } else {
      return isBn
          ? 'স্বাভাবিক ও নিয়মিত সাইকেল (২১-৩৫ দিন)'
          : 'Regular Normal Cycle (21-35 days)';
    }
  }

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

  /// Day in the cycle for ANY specified date (past, today, or future)
  int getCycleDayFor(DateTime targetDate) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final start = DateTime(
      lastPeriodStartDate.year,
      lastPeriodStartDate.month,
      lastPeriodStartDate.day,
    );
    final diff = target.difference(start).inDays;
    final mod = diff % cycleLength;
    return mod >= 0 ? (mod + 1) : ((mod + cycleLength) % cycleLength + 1);
  }

  /// Phase for ANY specified date
  CyclePhase getPhaseFor(DateTime targetDate) {
    final day = getCycleDayFor(targetDate);
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

  /// Check if date is a period bleeding day
  bool isPeriodDay(DateTime targetDate) {
    return getCycleDayFor(targetDate) <= periodDuration;
  }

  /// Check if date is inside the fertile window
  bool isFertileDay(DateTime targetDate) {
    final day = getCycleDayFor(targetDate);
    return day >= (ovulationDay - 4) && day <= (ovulationDay + 1);
  }

  /// Check if date is the peak ovulation day
  bool isOvulationDay(DateTime targetDate) {
    return getCycleDayFor(targetDate) == ovulationDay;
  }

  /// Progress of current cycle (0.0 to 1.0)
  double get cycleProgress => (currentCycleDay / cycleLength).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() {
    return {
      'isConfigured': isConfigured,
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'lastPeriodStartDate': lastPeriodStartDate.toIso8601String(),
    };
  }

  factory MenstrualCycleModel.fromJson(Map<String, dynamic> map) {
    return MenstrualCycleModel(
      isConfigured: map['isConfigured'] as bool? ?? false,
      cycleLength: map['cycleLength'] as int? ?? 28,
      periodDuration: map['periodDuration'] as int? ?? 5,
      lastPeriodStartDate: DateTime.tryParse(map['lastPeriodStartDate'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  MenstrualCycleModel copyWith({
    bool? isConfigured,
    int? cycleLength,
    int? periodDuration,
    DateTime? lastPeriodStartDate,
  }) {
    return MenstrualCycleModel(
      isConfigured: isConfigured ?? this.isConfigured,
      cycleLength: cycleLength ?? this.cycleLength,
      periodDuration: periodDuration ?? this.periodDuration,
      lastPeriodStartDate: lastPeriodStartDate ?? this.lastPeriodStartDate,
    );
  }
}
