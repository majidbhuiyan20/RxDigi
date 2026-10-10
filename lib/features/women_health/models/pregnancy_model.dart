import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Trimester of pregnancy
enum PregnancyTrimester {
  first,
  second,
  third,
}

extension PregnancyTrimesterExt on PregnancyTrimester {
  String name(bool isBn) {
    switch (this) {
      case PregnancyTrimester.first:
        return isBn ? '১ম ট্রাইমেস্টার (১-১৩ সপ্তাহ)' : '1st Trimester (Weeks 1-13)';
      case PregnancyTrimester.second:
        return isBn ? '২য় ট্রাইমেস্টার (১৪-২৭ সপ্তাহ)' : '2nd Trimester (Weeks 14-27)';
      case PregnancyTrimester.third:
        return isBn ? '৩য় ট্রাইমেস্টার (২৮-৪০ সপ্তাহ)' : '3rd Trimester (Weeks 28-40+)';
    }
  }

  String shortName(bool isBn) {
    switch (this) {
      case PregnancyTrimester.first:
        return isBn ? '১ম ট্রাইমেস্টার' : '1st Trimester';
      case PregnancyTrimester.second:
        return isBn ? '২য় ট্রাইমেস্টার' : '2nd Trimester';
      case PregnancyTrimester.third:
        return isBn ? '৩য় ট্রাইমেস্টার' : '3rd Trimester';
    }
  }
}

/// Core Pregnancy State Model
class PregnancyModel {
  final DateTime lastPeriodDate; // LMP
  final DateTime estimatedDueDate; // EDD (usually LMP + 280 days)
  final String babyNickname;
  final bool isNotificationEnabled;
  final int notificationHour;
  final int notificationMinute;

  const PregnancyModel({
    required this.lastPeriodDate,
    required this.estimatedDueDate,
    this.babyNickname = 'সোনামণি',
    this.isNotificationEnabled = true,
    this.notificationHour = 9,
    this.notificationMinute = 0,
  });

  /// Factory from LMP (Naegele's rule: LMP + 280 days)
  factory PregnancyModel.fromLmp(
    DateTime lmp, {
    String nickname = 'সোনামণি',
    bool isNotificationEnabled = true,
  }) {
    final edd = lmp.add(const Duration(days: 280));
    return PregnancyModel(
      lastPeriodDate: lmp,
      estimatedDueDate: edd,
      babyNickname: nickname,
      isNotificationEnabled: isNotificationEnabled,
    );
  }

  /// Factory from known ultrasound EDD
  factory PregnancyModel.fromEdd(
    DateTime edd, {
    String nickname = 'সোনামণি',
    bool isNotificationEnabled = true,
  }) {
    final lmp = edd.subtract(const Duration(days: 280));
    return PregnancyModel(
      lastPeriodDate: lmp,
      estimatedDueDate: edd,
      babyNickname: nickname,
      isNotificationEnabled: isNotificationEnabled,
    );
  }

  /// Current gestational age calculations based on today
  int get totalDaysElapsed {
    final diff = DateTime.now().difference(lastPeriodDate).inDays;
    return diff.clamp(0, 300);
  }

  int get currentWeek {
    final w = (totalDaysElapsed / 7).floor() + 1;
    return w.clamp(1, 42);
  }

  int get currentDayOfWeek {
    final d = (totalDaysElapsed % 7) + 1;
    return d.clamp(1, 7);
  }

  int get daysRemaining {
    final diff = estimatedDueDate.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  double get progressFraction {
    return (totalDaysElapsed / 280.0).clamp(0.0, 1.0);
  }

  int get progressPercent {
    return (progressFraction * 100).round();
  }

  PregnancyTrimester get currentTrimester {
    final w = currentWeek;
    if (w <= 13) return PregnancyTrimester.first;
    if (w <= 27) return PregnancyTrimester.second;
    return PregnancyTrimester.third;
  }

  TimeOfDay get notificationTime =>
      TimeOfDay(hour: notificationHour, minute: notificationMinute);

  PregnancyModel copyWith({
    DateTime? lastPeriodDate,
    DateTime? estimatedDueDate,
    String? babyNickname,
    bool? isNotificationEnabled,
    int? notificationHour,
    int? notificationMinute,
  }) {
    return PregnancyModel(
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      estimatedDueDate: estimatedDueDate ?? this.estimatedDueDate,
      babyNickname: babyNickname ?? this.babyNickname,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
    );
  }

  Map<String, dynamic> toJson() => {
        'lastPeriodDate': lastPeriodDate.toIso8601String(),
        'estimatedDueDate': estimatedDueDate.toIso8601String(),
        'babyNickname': babyNickname,
        'isNotificationEnabled': isNotificationEnabled,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
      };

  factory PregnancyModel.fromJson(Map<String, dynamic> json) {
    return PregnancyModel(
      lastPeriodDate: DateTime.parse(json['lastPeriodDate'] as String),
      estimatedDueDate: DateTime.parse(json['estimatedDueDate'] as String),
      babyNickname: json['babyNickname'] as String? ?? 'সোনামণি',
      isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? true,
      notificationHour: json['notificationHour'] as int? ?? 9,
      notificationMinute: json['notificationMinute'] as int? ?? 0,
    );
  }
}

/// Fetal Kick Counter Session Log
class KickCounterLog {
  final String id;
  final DateTime timestamp;
  final int durationMinutes;
  final int kickCount;
  final String? notes;

  const KickCounterLog({
    required this.id,
    required this.timestamp,
    required this.durationMinutes,
    required this.kickCount,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'durationMinutes': durationMinutes,
        'kickCount': kickCount,
        'notes': notes,
      };

  factory KickCounterLog.fromJson(Map<String, dynamic> json) => KickCounterLog(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        durationMinutes: json['durationMinutes'] as int? ?? 0,
        kickCount: json['kickCount'] as int? ?? 10,
        notes: json['notes'] as String?,
      );
}

/// Antenatal Care (ANC) Protocol Visit Item
class ANCVisitItem {
  final int visitNumber;
  final String weekRange;
  final String titleBn;
  final String titleEn;
  final String descriptionBn;
  final String descriptionEn;
  final bool isCompleted;
  final DateTime? completedDate;

  const ANCVisitItem({
    required this.visitNumber,
    required this.weekRange,
    required this.titleBn,
    required this.titleEn,
    required this.descriptionBn,
    required this.descriptionEn,
    this.isCompleted = false,
    this.completedDate,
  });

  ANCVisitItem copyWith({
    bool? isCompleted,
    DateTime? completedDate,
  }) {
    return ANCVisitItem(
      visitNumber: visitNumber,
      weekRange: weekRange,
      titleBn: titleBn,
      titleEn: titleEn,
      descriptionBn: descriptionBn,
      descriptionEn: descriptionEn,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'visitNumber': visitNumber,
        'weekRange': weekRange,
        'titleBn': titleBn,
        'titleEn': titleEn,
        'descriptionBn': descriptionBn,
        'descriptionEn': descriptionEn,
        'isCompleted': isCompleted,
        'completedDate': completedDate?.toIso8601String(),
      };

  factory ANCVisitItem.fromJson(Map<String, dynamic> json) => ANCVisitItem(
        visitNumber: json['visitNumber'] as int,
        weekRange: json['weekRange'] as String,
        titleBn: json['titleBn'] as String,
        titleEn: json['titleEn'] as String,
        descriptionBn: json['descriptionBn'] as String,
        descriptionEn: json['descriptionEn'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
        completedDate: json['completedDate'] != null
            ? DateTime.parse(json['completedDate'] as String)
            : null,
      );
}

/// Week-by-Week Clinical Database Entry
class PregnancyWeekInfo {
  final int week;
  final String fruitEmoji;
  final String fruitNameBn;
  final String fruitNameEn;
  final double lengthCm;
  final double weightGrams;
  final String babyDevelopmentBn;
  final String babyDevelopmentEn;
  final String motherChangesBn;
  final String motherChangesEn;
  final String careTipBn;
  final String careTipEn;
  final String notificationTextBn;
  final String notificationTextEn;

  const PregnancyWeekInfo({
    required this.week,
    required this.fruitEmoji,
    required this.fruitNameBn,
    required this.fruitNameEn,
    required this.lengthCm,
    required this.weightGrams,
    required this.babyDevelopmentBn,
    required this.babyDevelopmentEn,
    required this.motherChangesBn,
    required this.motherChangesEn,
    required this.careTipBn,
    required this.careTipEn,
    required this.notificationTextBn,
    required this.notificationTextEn,
  });

  factory PregnancyWeekInfo.fromJson(Map<String, dynamic> json) =>
      PregnancyWeekInfo(
        week: json['week'] as int,
        fruitEmoji: json['fruitEmoji'] as String? ?? '🌱',
        fruitNameBn: json['fruitNameBn'] as String? ?? '',
        fruitNameEn: json['fruitNameEn'] as String? ?? '',
        lengthCm: (json['lengthCm'] as num?)?.toDouble() ?? 0.0,
        weightGrams: (json['weightGrams'] as num?)?.toDouble() ?? 0.0,
        babyDevelopmentBn: json['babyDevelopmentBn'] as String? ?? '',
        babyDevelopmentEn: json['babyDevelopmentEn'] as String? ?? '',
        motherChangesBn: json['motherChangesBn'] as String? ?? '',
        motherChangesEn: json['motherChangesEn'] as String? ?? '',
        careTipBn: json['careTipBn'] as String? ?? '',
        careTipEn: json['careTipEn'] as String? ?? '',
        notificationTextBn: json['notificationTextBn'] as String? ?? '',
        notificationTextEn: json['notificationTextEn'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'week': week,
        'fruitEmoji': fruitEmoji,
        'fruitNameBn': fruitNameBn,
        'fruitNameEn': fruitNameEn,
        'lengthCm': lengthCm,
        'weightGrams': weightGrams,
        'babyDevelopmentBn': babyDevelopmentBn,
        'babyDevelopmentEn': babyDevelopmentEn,
        'motherChangesBn': motherChangesBn,
        'motherChangesEn': motherChangesEn,
        'careTipBn': careTipBn,
        'careTipEn': careTipEn,
        'notificationTextBn': notificationTextBn,
        'notificationTextEn': notificationTextEn,
      };
}

/// Clinical Week-by-Week Catalog (Loaded dynamically from assets/data/pregnancy_weeks.json)
class PregnancyWeekCatalog {
  PregnancyWeekCatalog._();

  static const String assetPath = 'assets/data/pregnancy_weeks.json';
  static List<PregnancyWeekInfo> _cachedWeeks = [];
  static bool _isLoaded = false;

  /// Loads all week records from JSON asset and caches them in memory
  static Future<List<PregnancyWeekInfo>> loadAllWeeks() async {
    if (_isLoaded && _cachedWeeks.isNotEmpty) {
      return _cachedWeeks;
    }

    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
      _cachedWeeks = list
          .map((e) => PregnancyWeekInfo.fromJson(e as Map<String, dynamic>))
          .toList();
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading pregnancy weeks json from $assetPath: $e');
    }

    return weeks;
  }

  /// Sets weeks directly (useful for tests or mocking)
  @visibleForTesting
  static void setMockWeeks(List<PregnancyWeekInfo> mockWeeks) {
    _cachedWeeks = mockWeeks;
    _isLoaded = true;
  }

  /// Synchronous getter with safe fallback if not yet loaded
  static List<PregnancyWeekInfo> get weeks {
    if (_cachedWeeks.isNotEmpty) {
      return _cachedWeeks;
    }
    return _fallbackWeeks;
  }

  static bool get isLoaded => _isLoaded;

  /// Baseline fallback entry so UI never crashes before async load finishes
  static const List<PregnancyWeekInfo> _fallbackWeeks = [
    PregnancyWeekInfo(
      week: 4,
      fruitEmoji: '🌱',
      fruitNameBn: 'একটি পোস্তদানার সমান',
      fruitNameEn: 'a tiny Poppy Seed',
      lengthCm: 0.1,
      weightGrams: 0.1,
      babyDevelopmentBn: 'ব্লাস্টোসিস্ট জরায়ুর দেয়ালে প্রতিস্থাপিত হয়েছে। প্লাসেন্টা ও অ্যামনিওটিক থলির গঠন শুরু হচ্ছে।',
      babyDevelopmentEn: 'The blastocyst implants into the uterine lining. The placenta and amniotic sac begin development.',
      motherChangesBn: 'মাসিক মিস হওয়া প্রথম লক্ষণ। মৃদু বমিভাব বা স্তনে ভারি অনুভূতি হতে পারে।',
      motherChangesEn: 'Missed period is the primary clue. Mild breast tenderness and fatigue may appear.',
      careTipBn: 'প্রতিদিন ৪০০ মাইক্রোগ্রাম ফলিক এসিড নিশ্চিত করুন। ধূমপান ও কাঁচা খাবার বর্জন করুন।',
      careTipEn: 'Take 400 mcg daily folic acid. Avoid unpasteurized foods and all alcohol.',
      notificationTextBn: '🌸 শুভ সকাল! ৪ সপ্তাহ শুরু হয়েছে। আপনার সোনামণি এখন একটি ছোট্ট বীজের মতো। ফলিক এসিড খেতে ভুলবেন না!',
      notificationTextEn: '🌸 Good morning! Week 4 has begun. Your baby is the size of a poppy seed. Remember your daily folic acid!',
    ),
    PregnancyWeekInfo(
      week: 40,
      fruitEmoji: '🍉',
      fruitNameBn: 'একটি গোলগাল মিষ্টি তরমুজের সমান',
      fruitNameEn: 'a sweet Watermelon',
      lengthCm: 51.2,
      weightGrams: 3400.0,
      babyDevelopmentBn: 'আপনার ডিউ ডেট সপ্তাহ! শিশু তার সমস্ত অঙ্গপ্রত্যঙ্গ, চুল ও সুন্দর নখ নিয়ে মায়ের কোলে আসার অপেক্ষায়।',
      babyDevelopmentEn: 'Due date arrival week! Your beautiful newborn is fully grown and awaiting birth.',
      motherChangesBn: 'প্রসবের শুভক্ষণ সমাগত। জরায়ুর মুখ খুলতে শুরু করেছে। মানসিক শক্তি ও ধৈর্য বজায় রাখুন।',
      motherChangesEn: 'Labor onset is imminent. Maintain calm, steady breathing and lean on your support partner.',
      careTipBn: 'শান্ত থাকুন, গভীর শ্বাস নিন এবং ডাক্তারের নির্দেশিত হসপিটালে যোগাযোগ রাখুন। শুভকামনা!',
      careTipEn: 'Stay calm, breathe mindfully, and maintain close contact with your delivery care team. Best wishes!',
      notificationTextBn: '🎉 ৪০তম সপ্তাহ: প্রসবের শুভক্ষণ উপস্থিত! আপনার এবং আপনার নবজাতক সোনামণির জন্য অফুরন্ত শুভকামনা।',
      notificationTextEn: '🎉 Week 40: Due Date is here! Sending love and warm blessings for a safe and joyful delivery.',
    ),
  ];

  static PregnancyWeekInfo getWeekInfo(int week) {
    final list = weeks;
    if (week < list.first.week) return list.first;
    if (week >= list.last.week) return list.last;
    PregnancyWeekInfo closest = list.first;
    for (final w in list) {
      if (w.week <= week) {
        closest = w;
      }
    }
    return closest;
  }
}


