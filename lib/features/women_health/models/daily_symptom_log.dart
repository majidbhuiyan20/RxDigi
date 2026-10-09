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

class DailySymptomLog {
  final String dateKey; // YYYY-MM-DD
  final FlowLevel flow;
  final CrampLevel cramp;
  final MoodType mood;
  final List<String> physicalSymptoms; // e.g. 'মাথাব্যথা', 'পেট ফাঁপা', 'ব্রণ'

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

