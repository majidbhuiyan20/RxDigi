import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../medicine_reminder/provider/medicine_reminder_provider.dart';
import '../models/health_habit_model.dart';
import '../models/habit_analytics_model.dart';
import '../repository/health_habit_repository.dart';

String habitDateString(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

final healthHabitRepositoryProvider = Provider<HealthHabitRepository>((ref) => HealthHabitRepository());

final activeHealthHabitsProvider = FutureProvider<List<HealthHabitModel>>((ref) async {
  return ref.watch(healthHabitRepositoryProvider).getActiveHabits();
});

class SelectedHabitDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) => state = date;
  void resetToToday() => state = DateTime.now();
}

final selectedHabitDateProvider =
    NotifierProvider<SelectedHabitDateNotifier, DateTime>(SelectedHabitDateNotifier.new);

final todayCompletedHabitIdsProvider = FutureProvider<Set<int>>((ref) async {
  return ref.watch(healthHabitRepositoryProvider).getCompletedHabitIds(habitDateString(DateTime.now()));
});

final completedHabitIdsForSelectedDateProvider = FutureProvider<Set<int>>((ref) async {
  final selectedDate = ref.watch(selectedHabitDateProvider);
  return ref.watch(healthHabitRepositoryProvider).getCompletedHabitIds(habitDateString(selectedDate));
});

final weeklyHabitCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final today = DateTime.now();
  final dates = List.generate(14, (index) => habitDateString(today.subtract(Duration(days: 13 - index))));
  return ref.watch(healthHabitRepositoryProvider).getDailyCompletedCounts(dates);
});

class HealthHabitNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(int habitId, bool completed) async {
    final selectedDate = ref.read(selectedHabitDateProvider);
    await ref.read(healthHabitRepositoryProvider).setCompleted(
          habitId: habitId,
          date: habitDateString(selectedDate),
          completed: !completed,
        );
    _invalidate();
  }

  Future<void> add(HealthHabitModel habit) async {
    await ref.read(healthHabitRepositoryProvider).insertHabit(habit);
    _invalidate();
  }

  Future<void> delete(int habitId) async {
    await ref.read(healthHabitRepositoryProvider).deleteHabit(habitId);
    _invalidate();
  }

  void _invalidate() {
    ref.invalidate(activeHealthHabitsProvider);
    ref.invalidate(todayCompletedHabitIdsProvider);
    ref.invalidate(completedHabitIdsForSelectedDateProvider);
    ref.invalidate(weeklyHabitCountsProvider);
    ref.invalidate(habitAnalyticsReportProvider);
  }
}

final healthHabitNotifierProvider = NotifierProvider<HealthHabitNotifier, void>(HealthHabitNotifier.new);

final habitAnalyticsReportProvider = FutureProvider<HabitAnalyticsReport>((ref) async {
  final repo = ref.watch(healthHabitRepositoryProvider);
  final habits = await ref.watch(activeHealthHabitsProvider.future);
  final totalHabits = habits.length;

  final now = DateTime.now();
  final bnDays = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
  final enDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final dates = <String>[];
  final dateObjs = <DateTime>[];
  for (int i = 6; i >= 0; i--) {
    final d = now.subtract(Duration(days: i));
    dateObjs.add(d);
    dates.add(habitDateString(d));
  }

  final countsMap = await repo.getDailyCompletedCounts(dates);
  final logsList = await repo.getCompletedLogsForDates(dates);

  final dailyStats = <DailyHabitStat>[];
  int perfectDaysCount = 0;
  double sumRates = 0;

  for (int i = 0; i < dates.length; i++) {
    final d = dateObjs[i];
    final dateStr = dates[i];
    final completed = countsMap[dateStr] ?? 0;
    final weekdayIdx = (d.weekday - 1) % 7;

    final stat = DailyHabitStat(
      date: d,
      dateString: dateStr,
      dayNameBn: bnDays[weekdayIdx],
      dayNameEn: enDays[weekdayIdx],
      totalHabits: totalHabits,
      completedCount: completed,
    );
    dailyStats.add(stat);

    if (stat.isPerfect) perfectDaysCount++;
    sumRates += stat.rate;
  }

  // Calculate Streak
  int streak = 0;
  for (int i = dailyStats.length - 1; i >= 0; i--) {
    final stat = dailyStats[i];
    if (i == dailyStats.length - 1) {
      if (stat.completedCount > 0) {
        streak++;
      }
    } else {
      if (stat.completedCount > 0 && stat.rate >= 0.5) {
        streak++;
      } else {
        break;
      }
    }
  }

  // Calculate Category Stats
  final habitById = {for (final h in habits) if (h.id != null) h.id!: h};
  final catTotals = <String, int>{};
  for (final h in habits) {
    catTotals[h.category] = (catTotals[h.category] ?? 0) + 7;
  }

  final catCompleted = <String, int>{};
  for (final row in logsList) {
    final hId = row['habitId'] as int?;
    final habit = habitById[hId];
    if (habit != null) {
      catCompleted[habit.category] = (catCompleted[habit.category] ?? 0) + 1;
    }
  }

  const catMeta = {
    'Nutrition': {'bn': 'পুষ্টি ও পানি', 'en': 'Nutrition', 'color': Color(0xFF10B981)},
    'Exercise': {'bn': 'ব্যায়াম ও হাঁটা', 'en': 'Exercise', 'color': Color(0xFF3B82F6)},
    'Sleep': {'bn': 'পরিমিত ঘুম', 'en': 'Sleep', 'color': Color(0xFF8B5CF6)},
    'Vitals': {'bn': 'স্বাস্থ্য চেকআপ', 'en': 'Vitals', 'color': Color(0xFFEF4444)},
    'Medicine': {'bn': 'ওষুধ সেবন', 'en': 'Medicine', 'color': Color(0xFF0D9488)},
    'Wellness': {'bn': 'সুস্থ জীবনধারা', 'en': 'Wellness', 'color': Color(0xFFF59E0B)},
  };

  final categoryStats = <HabitCategoryStat>[];
  catTotals.forEach((cat, totalWeekly) {
    final completed = catCompleted[cat] ?? 0;
    final meta = catMeta[cat] ?? {'bn': cat, 'en': cat, 'color': const Color(0xFF64748B)};
    categoryStats.add(HabitCategoryStat(
      category: cat,
      nameBn: meta['bn'] as String,
      nameEn: meta['en'] as String,
      total: totalWeekly,
      completed: completed,
      color: meta['color'] as Color,
    ));
  });

  final todayStr = habitDateString(now);
  final todayCompleted = countsMap[todayStr] ?? 0;

  return HabitAnalyticsReport(
    dailyStats: dailyStats,
    currentStreak: streak,
    averageRate: dailyStats.isNotEmpty ? (sumRates / dailyStats.length) : 0.0,
    perfectDaysCount: perfectDaysCount,
    categoryStats: categoryStats,
    todayCompleted: todayCompleted,
    todayTotal: totalHabits,
  );
});

final medicineAdherenceSummaryProvider = FutureProvider<Map<String, int>>((ref) async {
  final reminders = await ref.watch(activeRemindersProvider.future);
  final adherence = await ref.watch(todayAdherenceMapProvider.future);
  var total = 0;
  var taken = 0;
  for (final reminder in reminders) {
    for (final slot in reminder.activeSlots) {
      total++;
      if (adherence['${reminder.id}_$slot'] == true) {
        taken++;
      }
    }
  }
  return {'taken': taken, 'total': total};
});
