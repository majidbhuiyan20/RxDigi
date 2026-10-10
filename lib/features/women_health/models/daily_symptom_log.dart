enum FlowLevel { none, spotting, light, medium, heavy }

extension FlowLevelExtension on FlowLevel {
  String get labelBn {
    switch (this) {
      case FlowLevel.none:
        return 'নেই';
      case FlowLevel.spotting:
        return 'স্পটিং (সামান্য দাগ)';
      case FlowLevel.light:
        return 'হালকা ফ্লো';
      case FlowLevel.medium:
        return 'মাঝারি ফ্লো';
      case FlowLevel.heavy:
        return 'ভারী ফ্লো';
    }
  }

  String get labelEn {
    switch (this) {
      case FlowLevel.none:
        return 'None';
      case FlowLevel.spotting:
        return 'Spotting';
      case FlowLevel.light:
        return 'Light Flow';
      case FlowLevel.medium:
        return 'Medium Flow';
      case FlowLevel.heavy:
        return 'Heavy Flow';
    }
  }

  String label(bool isBn) => isBn ? labelBn : labelEn;

  String get emoji {
    switch (this) {
      case FlowLevel.none:
        return '⚪';
      case FlowLevel.spotting:
        return '🌸';
      case FlowLevel.light:
        return '💧';
      case FlowLevel.medium:
        return '🩸';
      case FlowLevel.heavy:
        return '🔴';
    }
  }
}

enum CrampLevel { none, mild, moderate, severe }

extension CrampLevelExtension on CrampLevel {
  String get labelBn {
    switch (this) {
      case CrampLevel.none:
        return 'কোনো ব্যথা নেই';
      case CrampLevel.mild:
        return 'হালকা অস্বস্তি';
      case CrampLevel.moderate:
        return 'মাঝারি ব্যথা';
      case CrampLevel.severe:
        return 'তীব্র ক্র্যাম্প';
    }
  }

  String get labelEn {
    switch (this) {
      case CrampLevel.none:
        return 'No Cramps';
      case CrampLevel.mild:
        return 'Mild Discomfort';
      case CrampLevel.moderate:
        return 'Moderate Cramps';
      case CrampLevel.severe:
        return 'Severe Cramps';
    }
  }

  String label(bool isBn) => isBn ? labelBn : labelEn;
}

enum MoodType { happy, calm, tired, irritable, anxious, sad }

extension MoodTypeExtension on MoodType {
  String get labelBn {
    switch (this) {
      case MoodType.happy:
        return 'খুশি ও ফুরফুরে';
      case MoodType.calm:
        return 'শান্ত';
      case MoodType.tired:
        return 'ক্লান্ত / ঘুম ঘুম ভাব';
      case MoodType.irritable:
        return 'বিরক্তিকর / রাগ';
      case MoodType.anxious:
        return 'উদ্বেগ / অস্থিরতা';
      case MoodType.sad:
        return 'মন খারাপ';
    }
  }

  String get labelEn {
    switch (this) {
      case MoodType.happy:
        return 'Happy & Energetic';
      case MoodType.calm:
        return 'Calm & Balanced';
      case MoodType.tired:
        return 'Tired / Drowsy';
      case MoodType.irritable:
        return 'Irritable / Moody';
      case MoodType.anxious:
        return 'Anxious / Restless';
      case MoodType.sad:
        return 'Low / Sad';
    }
  }

  String label(bool isBn) => isBn ? labelBn : labelEn;

  String get emoji {
    switch (this) {
      case MoodType.happy:
        return '😊';
      case MoodType.calm:
        return '😌';
      case MoodType.tired:
        return '😴';
      case MoodType.irritable:
        return '😤';
      case MoodType.anxious:
        return '😰';
      case MoodType.sad:
        return '🥺';
    }
  }
}

class SymptomItem {
  final String id;
  final String nameBn;
  final String nameEn;

  const SymptomItem({
    required this.id,
    required this.nameBn,
    required this.nameEn,
  });

  String label(bool isBn) => isBn ? nameBn : nameEn;
}

class SymptomCatalog {
  static const List<SymptomItem> items = [
    SymptomItem(id: 'headache', nameBn: 'মাথাব্যথা', nameEn: 'Headache'),
    SymptomItem(id: 'bloating', nameBn: 'পেট ফাঁপা', nameEn: 'Bloating'),
    SymptomItem(id: 'backache', nameBn: 'কোমর ব্যথা', nameEn: 'Lower Back Pain'),
    SymptomItem(id: 'acne', nameBn: 'ব্রণ / র‍্যাশ', nameEn: 'Acne / Breakouts'),
    SymptomItem(id: 'tender_breasts', nameBn: 'স্তন সংবেদনশীলতা', nameEn: 'Breast Tenderness'),
    SymptomItem(id: 'insomnia', nameBn: 'অনিদ্রা', nameEn: 'Insomnia / Sleep Disturbance'),
    SymptomItem(id: 'cravings', nameBn: 'মিষ্টি খাওয়ার তীব্র ইচ্ছা', nameEn: 'Sugar / Food Cravings'),
    SymptomItem(id: 'nausea', nameBn: 'বমি ভাব', nameEn: 'Nausea'),
  ];

  static String getLabel(String raw, bool isBn) {
    for (final item in items) {
      if (item.id == raw || item.nameBn == raw || item.nameEn == raw) {
        return item.label(isBn);
      }
    }
    return raw;
  }
}

class DailySymptomLog {
  final String dateKey; // YYYY-MM-DD
  final FlowLevel flow;
  final CrampLevel cramp;
  final MoodType mood;
  final List<String> physicalSymptoms; // e.g. 'headache' or 'মাথাব্যথা'

  const DailySymptomLog({
    required this.dateKey,
    this.flow = FlowLevel.none,
    this.cramp = CrampLevel.none,
    this.mood = MoodType.calm,
    this.physicalSymptoms = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'dateKey': dateKey,
      'flow': flow.index,
      'cramp': cramp.index,
      'mood': mood.index,
      'physicalSymptoms': physicalSymptoms,
    };
  }

  factory DailySymptomLog.fromJson(Map<String, dynamic> json) {
    return DailySymptomLog(
      dateKey: json['dateKey'] as String? ?? '',
      flow: FlowLevel.values[(json['flow'] as int? ?? 0).clamp(0, FlowLevel.values.length - 1)],
      cramp: CrampLevel.values[(json['cramp'] as int? ?? 0).clamp(0, CrampLevel.values.length - 1)],
      mood: MoodType.values[(json['mood'] as int? ?? 1).clamp(0, MoodType.values.length - 1)],
      physicalSymptoms: List<String>.from(json['physicalSymptoms'] as List? ?? []),
    );
  }

  DailySymptomLog copyWith({
    String? dateKey,
    FlowLevel? flow,
    CrampLevel? cramp,
    MoodType? mood,
    List<String>? physicalSymptoms,
  }) {
    return DailySymptomLog(
      dateKey: dateKey ?? this.dateKey,
      flow: flow ?? this.flow,
      cramp: cramp ?? this.cramp,
      mood: mood ?? this.mood,
      physicalSymptoms: physicalSymptoms ?? this.physicalSymptoms,
    );
  }
}
