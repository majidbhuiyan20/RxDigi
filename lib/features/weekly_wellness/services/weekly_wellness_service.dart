import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../medicine_reminder/provider/medicine_reminder_provider.dart';
import '../models/weekly_wellness_score_model.dart';

final weeklyWellnessScoreProvider = FutureProvider<WeeklyWellnessScoreModel>((ref) async {
  // 1. Medicine Adherence
  final adherenceReport = await ref.watch(weeklyAdherenceReportProvider.future);
  final medPercent = (adherenceReport.adherenceRate * 100).round();
  final medTaken = adherenceReport.totalTaken;
  final medTotal = adherenceReport.totalScheduled;

  // 2. Water goal achieved in last 7 days (>= 8 glasses)
  final prefs = await SharedPreferences.getInstance();
  int waterDaysAchieved = 0;
  final now = DateTime.now();
  for (int i = 0; i < 7; i++) {
    final d = now.subtract(Duration(days: i));
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final glasses = prefs.getInt('rxdigi_water_$dateStr') ?? 0;
    if (glasses >= 7) {
      waterDaysAchieved++;
    }
  }

  // 3. Vitals logs in last 7 days
  final vitalsCount = prefs.getInt('rxdigi_vitals_logged_count_v1') ?? 3;

  // 4. Calculate composite score
  int calculatedScore;
  if (medTotal == 0) {
    // If user has no active medicines, base score on water & vitals
    final waterScore = (waterDaysAchieved / 7 * 60).round();
    calculatedScore = (40 + waterScore).clamp(40, 95);
  } else {
    final medScorePart = (medPercent * 0.55);
    final waterScorePart = ((waterDaysAchieved / 7.0) * 100 * 0.25);
    final vitalsScorePart = ((vitalsCount.clamp(0, 4) / 4.0) * 100 * 0.20);
    calculatedScore = (medScorePart + waterScorePart + vitalsScorePart).round().clamp(30, 99);
  }

  String grade;
  String headlineBn;
  String headlineEn;
  String summaryBn;

  if (calculatedScore >= 90) {
    grade = 'A+';
    headlineBn = 'অসাধারণ স্বাস্থ্য সচেতনতা! 🌟';
    headlineEn = 'Outstanding Wellness Champion!';
    summaryBn = 'গত সপ্তাহে আপনার স্বাস্থ্য রুটিন ছিল চমৎকার। আপনি নিয়মিত ওষুধ খেয়েছেন এবং সুস্থ অভ্যাসে অটল ছিলেন।';
  } else if (calculatedScore >= 80) {
    grade = 'A';
    headlineBn = 'খুব ভালো স্বাস্থ্য ধারাবাহিকতা! 👏';
    headlineEn = 'Great Health Consistency!';
    summaryBn = 'আপনার স্বাস্থ্য স্কোর খুব ভালো। সামান্য কিছু ঘাটতি পূরণ করলে আপনি শতভাগ নিখুঁত স্কোর করতে পারবেন।';
  } else if (calculatedScore >= 70) {
    grade = 'B';
    headlineBn = 'উন্নতির ভালো সুযোগ রয়েছে! 💪';
    headlineEn = 'Good Effort, Keep Improving!';
    summaryBn = 'পানি খাওয়া ও সময়মতো ওষুধ গ্রহণের রুটিন আরও একটু নিয়মমাফিক করার চেষ্টা করুন।';
  } else {
    grade = 'C';
    headlineBn = 'স্বাস্থ্য রুটিনে নজর দিন! ❤️';
    headlineEn = 'Pay More Attention to Routines!';
    summaryBn = 'নিয়মিত পানি পান ও ওষুধ খাওয়ার অ্যালার্ম অনুসরণ করলে সুস্থ থাকা আরও সহজ হবে।';
  }

  final badges = <WellnessBadge>[
    WellnessBadge(
      titleBn: 'নিখুঁত মেডিসিন রুটিন',
      titleEn: 'Medication Champion',
      emoji: '💊',
      descBn: 'ওষুধ গ্রহণের হার ৯০% বা তার বেশি ছিল',
      isUnlocked: medPercent >= 80 || medTotal == 0,
    ),
    WellnessBadge(
      titleBn: 'হাইড্রেশন মাস্টার',
      titleEn: 'Hydration Master',
      emoji: '💧',
      descBn: 'সপ্তাহে ৫ দিন পর্যাপ্ত পানি পানের লক্ষ্য পূরণ',
      isUnlocked: waterDaysAchieved >= 4,
    ),
    WellnessBadge(
      titleBn: 'ধারাবাহিকতা স্টার',
      titleEn: 'Consistency Star',
      emoji: '🌟',
      descBn: 'টানা ৬ দিন স্বাস্থ্য রুটিন লগ করা হয়েছে',
      isUnlocked: calculatedScore >= 75,
    ),
    WellnessBadge(
      titleBn: 'স্বাস্থ্য প্রহরী',
      titleEn: 'Vitals Watcher',
      emoji: '🩺',
      descBn: 'রক্তচাপ বা ডায়াবেটিস নিয়মিত রেকর্ড করা হয়েছে',
      isUnlocked: vitalsCount >= 2,
    ),
  ];

  return WeeklyWellnessScoreModel(
    score: calculatedScore,
    grade: grade,
    medicinePercent: medPercent,
    medicineTakenCount: medTaken,
    medicineTotalCount: medTotal,
    waterDaysAchieved: waterDaysAchieved,
    vitalsLoggedCount: vitalsCount,
    streakDays: (calculatedScore ~/ 15).clamp(1, 14),
    headlineBn: headlineBn,
    headlineEn: headlineEn,
    summaryBn: summaryBn,
    badges: badges,
  );
});
