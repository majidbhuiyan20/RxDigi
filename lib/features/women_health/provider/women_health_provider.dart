import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/menstrual_cycle_model.dart';
import '../models/daily_symptom_log.dart';

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
}

final womenCycleProvider =
    NotifierProvider<WomenCycleNotifier, MenstrualCycleModel>(() {
  return WomenCycleNotifier();
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

