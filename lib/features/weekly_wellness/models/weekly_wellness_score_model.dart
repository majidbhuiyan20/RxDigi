class WellnessBadge {
  final String titleBn;
  final String titleEn;
  final String emoji;
  final String descBn;
  final bool isUnlocked;

  const WellnessBadge({
    required this.titleBn,
    required this.titleEn,
    required this.emoji,
    required this.descBn,
    this.isUnlocked = true,
  });
}

class WeeklyWellnessScoreModel {
  final int score; // 0 - 100
  final String grade; // A+, A, B, C
  final int medicinePercent;
  final int medicineTakenCount;
  final int medicineTotalCount;
  final int waterDaysAchieved;
  final int waterTotalDays;
  final int vitalsLoggedCount;
  final int streakDays;
  final String headlineBn;
  final String headlineEn;
  final String summaryBn;
  final List<WellnessBadge> badges;

  const WeeklyWellnessScoreModel({
    required this.score,
    required this.grade,
    required this.medicinePercent,
    required this.medicineTakenCount,
    required this.medicineTotalCount,
    required this.waterDaysAchieved,
    this.waterTotalDays = 7,
    required this.vitalsLoggedCount,
    required this.streakDays,
    required this.headlineBn,
    required this.headlineEn,
    required this.summaryBn,
    required this.badges,
  });

  bool get isExcellent => score >= 90;
  bool get isGood => score >= 75 && score < 90;
}

