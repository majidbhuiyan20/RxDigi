import 'package:flutter/material.dart';

class DailyHabitStat {
  final DateTime date;
  final String dateString;
  final String dayNameBn;
  final String dayNameEn;
  final int totalHabits;
  final int completedCount;

  const DailyHabitStat({
    required this.date,
    required this.dateString,
    required this.dayNameBn,
    required this.dayNameEn,
    required this.totalHabits,
    required this.completedCount,
  });

  double get rate => totalHabits > 0 ? (completedCount / totalHabits).clamp(0.0, 1.0) : 0.0;
  int get percentage => (rate * 100).round();
  bool get isPerfect => totalHabits > 0 && completedCount >= totalHabits;
  bool get isGood => rate >= 0.8;
  bool get isMedium => rate >= 0.5 && rate < 0.8;
  bool get isLow => rate < 0.5 && completedCount > 0;
  bool get isEmpty => completedCount == 0;
}

class HabitCategoryStat {
  final String category;
  final String nameBn;
  final String nameEn;
  final int total;
  final int completed;
  final Color color;

  const HabitCategoryStat({
    required this.category,
    required this.nameBn,
    required this.nameEn,
    required this.total,
    required this.completed,
    required this.color,
  });

  double get rate => total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
  int get percentage => (rate * 100).round();
}

class HabitAnalyticsReport {
  final List<DailyHabitStat> dailyStats;
  final int currentStreak;
  final double averageRate;
  final int perfectDaysCount;
  final List<HabitCategoryStat> categoryStats;
  final int todayCompleted;
  final int todayTotal;

  const HabitAnalyticsReport({
    required this.dailyStats,
    required this.currentStreak,
    required this.averageRate,
    required this.perfectDaysCount,
    required this.categoryStats,
    required this.todayCompleted,
    required this.todayTotal,
  });

  int get averagePercentage => (averageRate * 100).round();
  int get totalCompletedThisWeek => dailyStats.fold(0, (sum, e) => sum + e.completedCount);
}

