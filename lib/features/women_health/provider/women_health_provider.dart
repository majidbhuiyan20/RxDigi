import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menstrual_cycle_model.dart';
import '../models/daily_symptom_log.dart';

enum CycleGoalMode {
  trackCycle,
  tryToConceive,
}

class WomenCycleNotifier extends Notifier<MenstrualCycleModel> {
  static const String _prefsKey = 'rxdigi_menstrual_cycle_settings_v1';

  @override
  MenstrualCycleModel build() {
    _loadFromPrefs();
    // Sensible default: last period 10 days ago, cycle 28 days
    return MenstrualCycleModel(
      cycleLength: 28,
      periodDuration: 5,
      lastPeriodStartDate: DateTime.now().subtract(const Duration(days: 10)),
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = MenstrualCycleModel.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> updateCycleSettings({
    required int cycleLength,
    required int periodDuration,
    required DateTime lastPeriodStartDate,
  }) async {
    final updated = MenstrualCycleModel(
      cycleLength: cycleLength,
      periodDuration: periodDuration,
      lastPeriodStartDate: lastPeriodStartDate,
    );
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(updated.toJson()));
  }

  /// 1-Tap Quick Action: Mark today (or any date) as Period Start Day
  Future<void> recordPeriodStarted(DateTime date) async {
    final updated = state.copyWith(
      lastPeriodStartDate: date,
    );
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(updated.toJson()));
  }

  /// 1-Tap Quick Action: Mark today as Period Ended
  Future<void> recordPeriodEnded(DateTime date) async {
    final diff = date.difference(state.lastPeriodStartDate).inDays + 1;
    final newDuration = diff.clamp(3, 9);
    final updated = state.copyWith(
      periodDuration: newDuration,
    );
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(updated.toJson()));
  }
}

final womenCycleProvider =
    NotifierProvider<WomenCycleNotifier, MenstrualCycleModel>(() {
  return WomenCycleNotifier();
});

/// Interactive Selected Date Provider (allows navigating to past/future days)
class SelectedCycleDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void selectDate(DateTime date) {
    state = date;
  }

  void resetToToday() {
    state = DateTime.now();
  }
}

final selectedCycleDateProvider =
    NotifierProvider<SelectedCycleDateNotifier, DateTime>(() {
  return SelectedCycleDateNotifier();
});

/// Cycle Goal Mode Notifier (Track Cycle vs Trying To Conceive)
class CycleGoalModeNotifier extends Notifier<CycleGoalMode> {
  static const String _prefsKey = 'rxdigi_cycle_goal_mode_v1';

  @override
  CycleGoalMode build() {
    _loadFromPrefs();
    return CycleGoalMode.trackCycle;
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_prefsKey);
    if (modeStr != null) {
      state = modeStr == 'tryToConceive'
          ? CycleGoalMode.tryToConceive
          : CycleGoalMode.trackCycle;
    }
  }

  Future<void> toggleMode() async {
    final next = state == CycleGoalMode.trackCycle
        ? CycleGoalMode.tryToConceive
        : CycleGoalMode.trackCycle;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      next == CycleGoalMode.tryToConceive ? 'tryToConceive' : 'trackCycle',
    );
  }

  Future<void> setMode(CycleGoalMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      mode == CycleGoalMode.tryToConceive ? 'tryToConceive' : 'trackCycle',
    );
  }
}

final cycleGoalModeProvider =
    NotifierProvider<CycleGoalModeNotifier, CycleGoalMode>(() {
  return CycleGoalModeNotifier();
});

class DailySymptomNotifier extends Notifier<Map<String, DailySymptomLog>> {
  static const String _prefsKey = 'rxdigi_menstrual_symptom_logs_v1';

  @override
  Map<String, DailySymptomLog> build() {
    _loadFromPrefs();
    return {};
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        final result = <String, DailySymptomLog>{};
        map.forEach((k, v) {
          result[k] = DailySymptomLog.fromJson(v as Map<String, dynamic>);
        });
        state = result;
      } catch (_) {}
    }
  }

  Future<void> saveLog(DailySymptomLog log) async {
    final updated = {...state, log.dateKey: log};
    state = updated;

    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(updated.map((k, v) => MapEntry(k, v.toJson())));
    await prefs.setString(_prefsKey, encoded);
  }
}

final dailySymptomProvider =
    NotifierProvider<DailySymptomNotifier, Map<String, DailySymptomLog>>(() {
  return DailySymptomNotifier();
});

String getTodayKey() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}
