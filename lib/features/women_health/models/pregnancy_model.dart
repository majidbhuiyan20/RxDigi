import 'package:flutter/material.dart';

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
}

/// Clinical Week-by-Week Catalog (Weeks 1 to 40)
class PregnancyWeekCatalog {
  PregnancyWeekCatalog._();

  static const List<PregnancyWeekInfo> weeks = [
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
      week: 6,
      fruitEmoji: '🫘',
      fruitNameBn: 'একটি মিষ্টি মটরদানার সমান',
      fruitNameEn: 'a sweet Sweet Pea',
      lengthCm: 0.5,
      weightGrams: 0.3,
      babyDevelopmentBn: 'শিশুর ক্ষুদ্র হৃৎপিণ্ড প্রতি মিনিটে ১০০-১৬০ বার স্পন্দিত হতে শুরু করেছে। চোখ ও কানের সূক্ষ্ম খাঁজ তৈরি হচ্ছে।',
      babyDevelopmentEn: 'The tiny heart begins beating at 100-160 BPM. Tiny facial features and optic vesicles start forming.',
      motherChangesBn: 'মর্নিং সিকনেস ও গন্ধের প্রতি তীব্র সংবেদনশীলতা দেখা দিতে পারে। ঘন ঘন প্রস্রাবের বেগ হতে পারে।',
      motherChangesEn: 'Morning sickness and heightened sense of smell peak. Frequent urination is very common.',
      careTipBn: 'সকালে বিছানা ছাড়ার আগে ড্রাই টোস্ট বা বিস্কুট খান। একবারে বেশি না খেয়ে অল্প অল্প করে বারবার খান।',
      careTipEn: 'Eat dry crackers before rising. Eat small, frequent meals to soothe gastric nausea.',
      notificationTextBn: '🌸 ৬ষ্ঠ সপ্তাহ: আপনার সোনামণির ছোট্ট হৃৎস্পন্দন শুরু হয়েছে! হালকা নাস্তা ও পর্যাপ্ত পানি পান করুন।',
      notificationTextEn: '🌸 Week 6: Baby\'s tiny heartbeat is active! Sip water often and enjoy gentle nourishing snacks.',
    ),
    PregnancyWeekInfo(
      week: 8,
      fruitEmoji: '🍇',
      fruitNameBn: 'একটি লাল আঙ্গুরের সমান',
      fruitNameEn: 'a plump Kidney Bean / Grape',
      lengthCm: 1.6,
      weightGrams: 1.0,
      babyDevelopmentBn: 'হাত ও পায়ের পাতা ও ক্ষুদ্র আঙুলগুলো স্পষ্ট হচ্ছে। স্নায়ুতন্ত্র ও মস্তিষ্কের কোষ দ্রুত বিভাজিত হচ্ছে।',
      babyDevelopmentEn: 'Tiny webbed fingers and toes develop. Nerve pathways in the brain branch out rapidly.',
      motherChangesBn: 'জরায়ু এখন একটি লেবুর মতো বড়। হরমোনের কারণে অতিরিক্ত ক্লান্তি ও মেজাজের পরিবর্তন হতে পারে।',
      motherChangesEn: 'Your uterus is the size of a lemon. Fatigue, vivid dreams, and mood swings are frequent.',
      careTipBn: 'প্রথম এএনসি (ANC) ডাক্তারের ভিজিট ও ডেটিং আল্ট্রাসাউন্ড করানোর এটি মোক্ষম সময়।',
      careTipEn: 'Ideal timing for your 1st Antenatal Care doctor visit and baseline dating ultrasound.',
      notificationTextBn: '🌸 ৮ম সপ্তাহ: শিশুর হাতের আঙুলগুলো তৈরি হচ্ছে! ডাক্তারের সাথে প্রথম ভিজিটের অ্যাপয়েন্টমেন্ট নিশ্চিত করুন।',
      notificationTextEn: '🌸 Week 8: Baby\'s fingers are forming! A great time for your first dating ultrasound appointment.',
    ),
    PregnancyWeekInfo(
      week: 10,
      fruitEmoji: '🍓',
      fruitNameBn: 'একটি মিষ্টি স্ট্রবেরির সমান',
      fruitNameEn: 'a fresh Strawberry',
      lengthCm: 3.1,
      weightGrams: 4.0,
      babyDevelopmentBn: 'ভ্রূণ পর্যায় পেরিয়ে শিশু এখন চিকিৎসাবিজ্ঞানে পূর্ণাঙ্গ "ফিটাস" (Fetus)। সকল প্রধান অঙ্গ গঠিত হয়ে কাজ শুরু করেছে।',
      babyDevelopmentEn: 'The embryo is now officially a fetus! All vital organs are formed and beginning to function.',
      motherChangesBn: 'রক্তের পরিমাণ প্রায় ৫০% বৃদ্ধি পেতে শুরু করায় ত্বকে শিরার রেখা স্পষ্ট হতে পারে।',
      motherChangesEn: 'Blood volume expands significantly. You may notice visible veins on chest and belly.',
      careTipBn: 'আয়রন ও ভিটামিন সি সমৃদ্ধ খাবার (যেমন শাক, ডাল, পেয়ারা) গ্রহণ করুন যাতে রক্তস্বল্পতা না হয়।',
      careTipEn: 'Prioritize iron-rich foods combined with vitamin C (lentils, amla, guava) to support blood volume.',
      notificationTextBn: '🌸 ১০ম সপ্তাহ: আপনার শিশু এখন পূর্ণাঙ্গ ফিটাস! শরীরে রক্তের ঘাটতি রোধে পুষ্টিকর দেশি খাবার খান।',
      notificationTextEn: '🌸 Week 10: Your baby has graduated to fetus! Support circulation with fresh fruit and hydration.',
    ),
    PregnancyWeekInfo(
      week: 12,
      fruitEmoji: '🍋',
      fruitNameBn: 'একটি রসালো কাগজি লেবুর সমান',
      fruitNameEn: 'a juicy Lime',
      lengthCm: 5.4,
      weightGrams: 14.0,
      babyDevelopmentBn: 'শিশুর নখের গঠন শুরু হয়েছে। কিডনি অ্যামনিওটিক ফ্লুইড ফিল্টার করে মূত্র তৈরি করছে এবং শিশু ঢোক গিলতে পারে।',
      babyDevelopmentEn: 'Tiny fingernails form. Kidneys produce amniotic fluid and the baby practice-swallows.',
      motherChangesBn: '১ম ট্রাইমেস্টারের শেষ প্রান্তে বমিভাব কমতে পারে এবং কর্মশক্তি ধীরে ধীরে ফিরে আসবে।',
      motherChangesEn: 'Morning sickness typically starts subsiding as placenta takes over hormone synthesis.',
      careTipBn: '১১-১৩ সপ্তাহের NT স্ক্যান (Nuchal Translucency) আল্ট্রাসাউন্ড করিয়ে জেনে নিন শিশুর বিকাশ স্বাভাবিক কিনা।',
      careTipEn: 'Schedule your NT ultrasound scan to evaluate fetal genetic and chromosomal markers.',
      notificationTextBn: '🌸 ১২তম সপ্তাহ: ১ম ট্রাইমেস্টারের দ্বারপ্রান্তে! বমিভাব কমবে, শিশুর জন্য সুষম ডায়েট বজায় রাখুন।',
      notificationTextEn: '🌸 Week 12: Approaching the second trimester! Energy will return; keep eating wholesome foods.',
    ),
    PregnancyWeekInfo(
      week: 14,
      fruitEmoji: '🍋',
      fruitNameBn: 'একটি পাকা লেবুর সমান',
      fruitNameEn: 'a ripe Lemon',
      lengthCm: 8.7,
      weightGrams: 43.0,
      babyDevelopmentBn: '২য় ট্রাইমেস্টারে স্বাগতম! শিশু মুখে হাসি, ভ্রু কুঁচকানো বা আঙুল চোষার মতো রিফ্লেক্স প্র্যাকটিস করছে।',
      babyDevelopmentEn: 'Welcome to the 2nd trimester! Baby can squint, frown, and make facial grimaces.',
      motherChangesBn: 'পেট হালকা উঁচু হতে শুরু করেছে। "প্রেগন্যান্সি গ্লো" ও ত্বকে রক্তসঞ্চালন বৃদ্ধি পায়।',
      motherChangesEn: 'Your baby bump begins to show gently. Increased blood circulation brings the pregnancy glow.',
      careTipBn: 'ঢিলেঢালা আরামদায়ক পোশাক পরিধান করুন এবং পিঠব্যথা এড়াতে আরামদায়ক পাদুকা বেছে নিন।',
      careTipEn: 'Switch to comfortable maternity clothing and supportive flat shoes to support posture.',
      notificationTextBn: '🌸 ১৪তম সপ্তাহ: ২য় ট্রাইমেস্টারে পদার্পণ! শিশুর হাত-পা এখন দারুণ কর্মক্ষম। মা ও শিশুর যত্ন নিন।',
      notificationTextEn: '🌸 Week 14: Welcome to the energetic 2nd Trimester! Baby is practicing tiny hand and mouth movements.',
    ),
    PregnancyWeekInfo(
      week: 16,
      fruitEmoji: '🥑',
      fruitNameBn: 'একটি মাঝারি অ্যাভোকাডোর সমান',
      fruitNameEn: 'an Avocado',
      lengthCm: 11.6,
      weightGrams: 100.0,
      babyDevelopmentBn: 'শিশুর ক্ষুদ্র কানের গঠন সম্পন্ন হয়েছে—সে এখন মায়ের হৃৎস্পন্দন ও কণ্ঠস্বর শুনতে পায়!',
      babyDevelopmentEn: 'Baby\'s inner ear bones are hardened; baby can now hear your voice and heartbeat!',
      motherChangesBn: 'পেটের ভেতর মৃদু প্রজাপতির পাখার মতো নড়াচড়া (Quickening) প্রথম অনুভব হতে পারে।',
      motherChangesEn: 'You might feel tiny fluttery sensations known as quickening for the first time.',
      careTipBn: 'শিশুর সাথে মিষ্টি সুরে কথা বলুন বা গান শোনান। ক্যালসিয়াম ও আয়রন ট্যাবলেট নিয়মিত চালু রাখুন।',
      careTipEn: 'Talk and hum to your baby! Ensure your prenatal calcium and iron supplements are taken on time.',
      notificationTextBn: '🌸 ১৬তম সপ্তাহ: আপনার সোনামণি এখন আপনার কণ্ঠ শুনতে পায়! তার সাথে কথা বলুন ও গান শোনান।',
      notificationTextEn: '🌸 Week 16: Your baby can hear your voice now! Talk, read, and hum gentle melodies to your bump.',
    ),
    PregnancyWeekInfo(
      week: 18,
      fruitEmoji: '🫑',
      fruitNameBn: 'একটি বড় মিষ্টি ক্যাপসিকামের সমান',
      fruitNameEn: 'a Bell Pepper',
      lengthCm: 14.2,
      weightGrams: 190.0,
      babyDevelopmentBn: 'শিশুর স্নায়ুগুলোর ওপর মায়োলিন প্রলেপ তৈরি হচ্ছে। আঙুলের ডগায় অনন্য ও স্থায়ী ফিঙ্গারপ্রিন্ট বসে গেছে।',
      babyDevelopmentEn: 'Myelin forms around nerves. Unique, permanent fingerprints are fully set on tiny fingers.',
      motherChangesBn: 'হঠাৎ দাঁড়ালে মাথা ঘোরা বা পিঠের নিচের অংশে টান লাগতে পারে। ঘুমানোর সময় বাম কাতে শোয়া শুরু করুন।',
      motherChangesEn: 'Lower back strain or mild postural dizziness may occur. Sleep on your left side with pillows.',
      careTipBn: '১৮-২২ সপ্তাহের মধ্যে অত্যন্ত গুরুত্বপূর্ণ "এনোমালি স্ক্যান" (Anomaly Ultrasound) সম্পন্ন করুন।',
      careTipEn: 'Schedule your comprehensive mid-pregnancy Level II Anomaly Ultrasound Scan this week.',
      notificationTextBn: '🌸 ১৮তম সপ্তাহ: এনোমালি স্ক্যান করানোর গুরুত্বপূর্ণ সময়। শিশুর অঙ্গ-প্রত্যঙ্গের গঠন আল্ট্রাসাউন্ডে দেখে নিন।',
      notificationTextEn: '🌸 Week 18: Time for the detailed Anomaly Scan. Verify your baby\'s anatomical milestones with your doctor.',
    ),
    PregnancyWeekInfo(
      week: 20,
      fruitEmoji: '🍌',
      fruitNameBn: 'একটি মিষ্টি কলার সমান',
      fruitNameEn: 'a ripe Banana',
      lengthCm: 25.6,
      weightGrams: 300.0,
      babyDevelopmentBn: 'অভিনন্দন! আপনি গর্ভাবস্থার ঠিক অর্ধেক পথ অতিক্রম করেছেন (২০/৪০ সপ্তাহ)। শিশু এখন নিয়মিত ঘুমানো ও জাগার চক্র তৈরি করছে।',
      babyDevelopmentEn: 'Halfway milestone (20/40 weeks)! Baby has established circadian sleep and wake cycles.',
      motherChangesBn: 'নাভি সামান্য বাইরের দিকে আসতে পারে। পেট এখন সুনির্দিষ্ট ও সুন্দরভাবে দৃশ্যমান।',
      motherChangesEn: 'Your belly button may pop outward gently. Uterus reaches right up to belly-button level.',
      careTipBn: 'হাফওয়ে মাইলস্টোন উদযাপন করুন! পর্যাপ্ত প্রোটিন (ডিম, মাছ, দুধ) ও সবুজ শাকসবজি খান।',
      careTipEn: 'Celebrate the halfway mark! Nourish with balanced proteins, milk, lentils, and fresh fruits.',
      notificationTextBn: '🎉 ২০তম সপ্তাহ: গর্ভাবস্থার ঠিক অর্ধেক পথ সম্পন্ন! আপনার সোনামণি এখন ২৫ সেমি দীর্ঘ। অভিনন্দন!',
      notificationTextEn: '🎉 Week 20: Halfway there! Baby is ~25 cm long. Celebrate this milestone with nutritious nourishment.',
    ),
    PregnancyWeekInfo(
      week: 22,
      fruitEmoji: '🥥',
      fruitNameBn: 'একটি রসালো পাকা পেঁপের সমান',
      fruitNameEn: 'a Papaya',
      lengthCm: 27.8,
      weightGrams: 430.0,
      babyDevelopmentBn: 'শিশুর চোখের পাতা ও ভ্রুর স্পষ্ট গঠন তৈরি হয়েছে। স্বাদগ্রন্থি (Taste buds) কাজ শুরু করেছে।',
      babyDevelopmentEn: 'Eyelashes and distinct eyebrows form. Baby taste buds are active in amniotic fluid.',
      motherChangesBn: 'পায়ে বা গোড়ালিতে মৃদু পানি আসা (Edema) বা রাতে পায়ে টান লাগতে পারে।',
      motherChangesEn: 'Mild ankle swelling and nighttime leg cramps may surface due to pelvic pressure.',
      careTipBn: 'লবণের অতিরিক্ত ব্যবহার এড়িয়ে চলুন, পা উঁচু করে রাখুন এবং ম্যাগনেসিয়াম সমৃদ্ধ খাবার খান।',
      careTipEn: 'Limit processed salt, elevate legs while seated, and consume bananas or nuts for magnesium.',
      notificationTextBn: '🌸 ২২তম সপ্তাহ: শিশুর চোখের ভ্রু ও পাপড়ি ফুটে উঠছে! পায়ে টান লাগলে সামান্য পা উঁচু করে বিশ্রাম নিন।',
      notificationTextEn: '🌸 Week 22: Baby has eyebrows and eyelashes! Rest with your feet slightly elevated after meals.',
    ),
    PregnancyWeekInfo(
      week: 24,
      fruitEmoji: '🌽',
      fruitNameBn: 'একটি বড় ভুট্টার মোচার সমান',
      fruitNameEn: 'an Ear of Corn',
      lengthCm: 30.0,
      weightGrams: 600.0,
      babyDevelopmentBn: 'শিশুর ফুসফুসে সারফ্যাকট্যান্ট (Surfactant) তৈরি শুরু হচ্ছে যা জন্মের পর শ্বাস নিতে সাহায্য করবে।',
      babyDevelopmentEn: 'Surfactant production initiates in tiny lungs, paving the way for eventual breathing.',
      motherChangesBn: 'গর্ভকালীন ডায়াবেটিস (GDM) স্ক্রিনিং ও ওজিটিটি (OGTT) ব্লাড টেস্টের আদর্শ সময়।',
      motherChangesEn: 'Window for the Oral Glucose Tolerance Test (OGTT) to screen for gestational diabetes.',
      careTipBn: 'ডাক্তারের পরামর্শে ওজিটিটি রক্তের সুগার টেস্ট করান। মিষ্টি ও অতিরিক্ত চিনিযুক্ত পানীয় পরিহার করুন।',
      careTipEn: 'Get your OGTT blood glucose test done. Avoid sweetened drinks and refined sugars.',
      notificationTextBn: '🌸 ২৪তম সপ্তাহ: ডায়াবেটিস স্ক্রিনিং করানোর সময়। রক্তের সুগার নিয়ন্ত্রণে পুষ্টিকর ও লো-জিআই খাবার খান।',
      notificationTextEn: '🌸 Week 24: Ideal time for gestational diabetes screening. Keep sugars balanced with fiber-rich carbs.',
    ),
    PregnancyWeekInfo(
      week: 26,
      fruitEmoji: '🥬',
      fruitNameBn: 'একটি তাজা লাল বাঁধাকপির সমান',
      fruitNameEn: 'a Red Cabbage',
      lengthCm: 35.6,
      weightGrams: 760.0,
      babyDevelopmentBn: 'শিশু প্রথমবারের মতো চোখের পাতা খুলতে ও বন্ধ করতে পারে। শব্দের তীব্রতায় শিশু চমকে প্রতিক্রিয়া জানাতে পারে।',
      babyDevelopmentEn: 'Baby opens eyes for the first time. Baby responds with startle kicks to loud external sounds.',
      motherChangesBn: 'পেটের চামড়ায় টান ধরা বা চুলকানি (Stretch marks) হতে পারে। পিঠে হালকা ব্যথা হতে পারে।',
      motherChangesEn: 'Stretching abdominal skin can cause itching. Warm coconut oil or gentle lotion helps immensely.',
      careTipBn: 'পেটে খাঁটি নারিকেল তেল বা ময়েশ্চারাইজার লাগান। ভারী জিনিস তোলা পরিহার করুন।',
      careTipEn: 'Moisturize your belly with pure coconut oil or shea butter. Never lift heavy loads.',
      notificationTextBn: '🌸 ২৬তম সপ্তাহ: শিশু এখন চোখ খুলতে পারে! পেটের চামড়ায় টান লাগলে ময়েশ্চারাইজার ব্যবহার করুন।',
      notificationTextEn: '🌸 Week 26: Baby can open tiny eyes! Keep your belly skin moisturized with gentle nourishing oils.',
    ),
    PregnancyWeekInfo(
      week: 28,
      fruitEmoji: '🍆',
      fruitNameBn: 'একটি বড় মিষ্টি বেগুন বা কপির সমান',
      fruitNameEn: 'a large Eggplant',
      lengthCm: 37.6,
      weightGrams: 1000.0,
      babyDevelopmentBn: '৩য় ও চূড়ান্ত ট্রাইমেস্টারে পদার্পণ! শিশুর ওজন ১ কেজি স্পর্শ করেছে। মস্তিষ্কে বিলিয়ন বিলিয়ন নিউরোন সক্রিয়।',
      babyDevelopmentEn: 'Welcome to the 3rd Trimester! Baby weighs over 1 kg. Billions of active neurons develop.',
      motherChangesBn: 'শিশুর লাথি ও নড়াচড়া এখন পেট বাইরে থেকেও স্পষ্টভাবে দেখা যায়। দ্রুত হাঁপিয়ে উঠতে পারেন।',
      motherChangesEn: 'Kicks and rolls are distinct from outside. Shortness of breath occurs as uterus presses diaphragm.',
      careTipBn: 'এখন থেকে প্রতিদিন "ফিটাল কিক কাউন্টার" (Baby Kick Counter) ব্যবহার করে শিশুর নড়াচড়া ট্র্যাক করা শুরু করুন।',
      careTipEn: 'Start daily baby kick counting sessions! A minimum of 10 movements in 2 hours is expected.',
      notificationTextBn: '👣 ২৮তম সপ্তাহ: ৩য় ট্রাইমেস্টার শুরু! প্রতিদিন অ্যাপের কিক কাউন্টারে শিশুর নড়াচড়া রেকর্ড করুন।',
      notificationTextEn: '👣 Week 28: 3rd Trimester milestone! Track your baby\'s daily movements with RxDigi Kick Counter.',
    ),
    PregnancyWeekInfo(
      week: 30,
      fruitEmoji: '🥬',
      fruitNameBn: 'একটি বড় ফুলকপির সমান',
      fruitNameEn: 'a Cabbage / Cauliflower',
      lengthCm: 39.9,
      weightGrams: 1320.0,
      babyDevelopmentBn: 'শিশুর অস্থিমজ্জা (Bone marrow) এখন নিজে থেকেই লোহিত রক্তকণিকা তৈরিতে সক্ষম। দৃষ্টিশক্তি পরিপক্ক হচ্ছে।',
      babyDevelopmentEn: 'Bone marrow completely takes over RBC production. Vision sharpens to track light through the belly.',
      motherChangesBn: 'বুকে জ্বালাপোড়া (Heartburn) এবং ঘুমের ব্যাঘাত হতে পারে। পেটের ওপর বেশি চাপ অনুভব হতে পারে।',
      motherChangesEn: 'Heartburn and restless sleep are common. Use pregnancy pillows between legs and under belly.',
      careTipBn: 'রাতে খাওয়ার অন্তত ২ ঘণ্টা পর ঘুমাতে যান এবং মসলাযুক্ত বা অতিরিক্ত তৈলাক্ত খাবার এড়িয়ে চলুন।',
      careTipEn: 'Dine 2 hours before bedtime. Avoid spicy, heavy greasy curries to minimize nocturnal reflux.',
      notificationTextBn: '🌸 ৩০তম সপ্তাহ: শিশুর অস্থিমজ্জা রক্তকণিকা তৈরি করছে। রাতে মসলা কম খেয়ে আরামদায়ক ঘুম নিশ্চিত করুন।',
      notificationTextEn: '🌸 Week 30: Baby is growing fast! Support digestion with early light dinner and pregnancy pillow rest.',
    ),
    PregnancyWeekInfo(
      week: 32,
      fruitEmoji: '🍍',
      fruitNameBn: 'একটি বড় রসালো আনারসের সমান',
      fruitNameEn: 'a Pineapple',
      lengthCm: 42.4,
      weightGrams: 1700.0,
      babyDevelopmentBn: 'শিশুর নখ আঙুলের ডগা পর্যন্ত পৌঁছেছে। শিশু এখন মায়ের পেটের ভেতর নিয়মিত মাথা নিচে (Cephalic) ঘুরানোর প্রস্তুতি নিচ্ছে।',
      babyDevelopmentEn: 'Toenails and fingernails are complete. Baby typically rotates into the head-down cephalic position.',
      motherChangesBn: 'ব্র্যাক্সটন হিকস (Braxton Hicks) বা মৃদু অনিয়মিত পেট শক্ত হওয়ার অনুভূতি হতে পারে।',
      motherChangesEn: 'Braxton Hicks false labor contractions may tighten the uterus irregularly. Hydration eases them.',
      careTipBn: '৩য় এএনসি চেকআপ ও গ্রোথ আল্ট্রাসাউন্ড করানোর সময় হয়েছে। পর্যাপ্ত পানি পান পেট টানটান হওয়া কমায়।',
      careTipEn: 'Visit your obstetrician for the 3rd trimester growth ultrasound and blood pressure checkup.',
      notificationTextBn: '🌸 ৩২তম সপ্তাহ: শিশু মাথা নিচের দিকে ঘুরাচ্ছে। পেট শক্ত হলে পানি খেয়ে বিশ্রাম নিন।',
      notificationTextEn: '🌸 Week 32: Baby is practicing delivery positioning. Sip water and relax if Braxton Hicks tighten.',
    ),
    PregnancyWeekInfo(
      week: 34,
      fruitEmoji: '🍈',
      fruitNameBn: 'একটি মিষ্টি খরমুজ বা বাঙ্গির সমান',
      fruitNameEn: 'a Cantaloupe Melon',
      lengthCm: 45.0,
      weightGrams: 2150.0,
      babyDevelopmentBn: 'শিশুর রোগপ্রতিরোধ ক্ষমতা (Immune system) মায়ের শরীর থেকে অ্যান্টিবডি গ্রহণের মাধ্যমে শক্তিশালী হচ্ছে।',
      babyDevelopmentEn: 'Maternal antibodies actively cross the placenta, building baby\'s innate immune defense.',
      motherChangesBn: 'শ্রোণিচক্র বা পেলভিক অংশে চাপ বৃদ্ধি পায়। বারবার টয়লেটে যাওয়ার প্রয়োজন হতে পারে।',
      motherChangesEn: 'Pelvic heaviness increases as baby drops into the pelvic inlet. Frequent bathroom trips continue.',
      careTipBn: 'হাসপাতালে যাওয়ার ব্যাগ (Hospital Bag) গুছিয়ে রাখা শুরু করুন এবং জরুরি যোগাযোগের নম্বর লিখে রাখুন।',
      careTipEn: 'Begin packing your Hospital Delivery Bag with baby clothes, blankets, pads, and medical files.',
      notificationTextBn: '🌸 ৩৪তম সপ্তাহ: হাসপাতালের প্রয়োজনীয় ফাইল ও ব্যাগ প্রস্তুত করা শুরু করার দারুণ সময়!',
      notificationTextEn: '🌸 Week 34: Time to pack your delivery bag! Keep medical records and baby essentials ready.',
    ),
    PregnancyWeekInfo(
      week: 36,
      fruitEmoji: '🥥',
      fruitNameBn: 'একটি পাকা পেঁপে বা ডাবের সমান',
      fruitNameEn: 'a large Papaya',
      lengthCm: 47.4,
      weightGrams: 2620.0,
      babyDevelopmentBn: 'শিশুর ফুসফুস ও পরিপাকতন্ত্র প্রায় সম্পূর্ণ পরিপক্ক! শিশু প্রতিদিন প্রায় ৩০ গ্রাম করে চর্বি জমাচ্ছে।',
      babyDevelopmentEn: 'Lungs and digestive system are almost fully mature! Baby gains about 30 grams of fat daily.',
      motherChangesBn: 'শিশু শ্রোণিগহ্বরে নিচে নেমে যাওয়ায় (Lightening) শ্বাস নেওয়া আগের চেয়ে কিছুটা সহজ মনে হতে পারে।',
      motherChangesEn: 'Lightening occurs as baby descends, easing breathing slightly while increasing bladder pressure.',
      careTipBn: 'এখন থেকে প্রতি সপ্তাহে একবার ডাক্তারের কাছে ভিজিট করা জরুরি। প্রসবের লক্ষণগুলো জেনে নিন।',
      careTipEn: 'Weekly obstetrician visits begin now. Learn to distinguish true labor pains from false alarms.',
      notificationTextBn: '🌸 ৩৬তম সপ্তাহ: শিশু এখন প্রায় পূর্ণাঙ্গ! প্রতি সপ্তাহে চিকিৎসকের পরামর্শ ও প্রেশার চেক করুন।',
      notificationTextEn: '🌸 Week 36: Baby is almost full term! Weekly checkups start now to monitor BP and baby drops.',
    ),
    PregnancyWeekInfo(
      week: 38,
      fruitEmoji: '🎃',
      fruitNameBn: 'একটি মিষ্টি কুমড়ার সমান',
      fruitNameEn: 'a Winter Melon',
      lengthCm: 49.8,
      weightGrams: 3080.0,
      babyDevelopmentBn: 'শিশু এখন ফুল-টার্ম (Full Term)! শিশু যেকোনো দিন পৃথিবীতে আসার জন্য সম্পূর্ণ শারীরিকভাবে প্রস্তুত।',
      babyDevelopmentEn: 'Full term milestone! Baby is physically ready for life outside the womb at any moment.',
      motherChangesBn: 'মিউকাস প্লাগ নির্গমন বা পানির মতো তরল নির্গত হতে পারে। অনিয়মিত প্রসববেদনা অনুভূত হতে পারে।',
      motherChangesEn: 'Loss of the mucus plug and nesting instinct peak. Contractions may become rhythmic.',
      careTipBn: 'নিয়মিত ৫ মিনিট পরপর সংকোচন বা পানি ভেঙে গেলে কালবিলম্ব না করে দ্রুত হাসপাতালে রওনা হন।',
      careTipEn: 'If contractions occur every 5 mins or water breaks, head straight to your hospital.',
      notificationTextBn: '🌸 ৩৮তম সপ্তাহ: পূর্ণ মেয়াদের গর্ব! সোনামণি যেকোনো দিন কোলে আসতে পারে। মানসিকভাবে শান্ত থাকুন।',
      notificationTextEn: '🌸 Week 38: Full term! Baby can arrive any day now. Keep your hospital bag and transport ready.',
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
    if (week < 4) return weeks.first;
    if (week >= 40) return weeks.last;
    // Find closest or exact
    PregnancyWeekInfo closest = weeks.first;
    for (final w in weeks) {
      if (w.week <= week) {
        closest = w;
      }
    }
    return closest;
  }
}
