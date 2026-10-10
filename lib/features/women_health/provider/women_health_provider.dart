import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../medicine_reminder/models/medicine_reminder_model.dart';
import '../../medicine_reminder/provider/medicine_reminder_provider.dart';
import '../models/menstrual_cycle_model.dart';
import '../models/daily_symptom_log.dart';

enum CycleGoalMode {
  trackCycle,
  tryToConceive,
  pregnancy,
}

class WomenCycleNotifier extends Notifier<MenstrualCycleModel> {
  static const String _prefsKey = 'rxdigi_menstrual_cycle_settings_v2';

  @override
  MenstrualCycleModel build() {
    _loadFromPrefs();
    // Brand new user: not configured until user sets their actual period date
    return MenstrualCycleModel(
      isConfigured: false,
      cycleLength: 28,
      periodDuration: 5,
      lastPeriodStartDate: DateTime.now(),
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
      isConfigured: true,
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
      isConfigured: true,
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

/// Past Recorded Cycles History Notifier
class WomenCycleHistoryNotifier extends Notifier<List<HistoricalCycleEntry>> {
  static const String _prefsKey = 'rxdigi_menstrual_cycle_history_v2';

  @override
  List<HistoricalCycleEntry> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state = list.map((e) => HistoricalCycleEntry.fromJson(e as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
  }

  Future<void> addCycle(HistoricalCycleEntry cycle) async {
    final updated = [cycle, ...state];
    state = updated;
    await _save(updated);
  }

  Future<void> deleteCycle(String id) async {
    final updated = state.where((c) => c.id != id).toList();
    state = updated;
    await _save(updated);
  }

  Future<void> _save(List<HistoricalCycleEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, jsonStr);
  }
}

final womenCycleHistoryProvider =
    NotifierProvider<WomenCycleHistoryNotifier, List<HistoricalCycleEntry>>(() {
  return WomenCycleHistoryNotifier();
});

/// Birth Control (OCP) Notifier
class WomenOCPNotifier extends Notifier<OCPTrackerState> {
  static const String _prefsKey = 'rxdigi_ocp_tracker_v1';

  @override
  OCPTrackerState build() {
    _loadFromPrefs();
    return const OCPTrackerState();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = OCPTrackerState.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> toggleTakenToday() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final isAlreadyTaken = state.lastTakenDateKey == todayKey;
    final updated = state.copyWith(
      lastTakenDateKey: isAlreadyTaken ? '' : todayKey,
    );
    state = updated;
    await _save(updated);
  }

  Future<void> updateConfig({
    required bool isEnabled,
    required String pillBrand,
    required int packDays,
    required String pillTime,
    DateTime? packStartDate,
  }) async {
    final updated = state.copyWith(
      isEnabled: isEnabled,
      pillBrand: pillBrand,
      packDays: packDays,
      pillTime: pillTime,
      packStartDate: packStartDate ?? state.packStartDate ?? DateTime.now(),
    );
    state = updated;
    await _save(updated);
  }

  Future<void> _save(OCPTrackerState data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data.toJson()));
  }

  /// Syncs with main Medicine Reminder Database
  Future<void> syncWithMedicationRoutine(WidgetRef ref) async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final reminder = MedicineReminderModel(
      medicineName: '${state.pillBrand} (OCP - জন্মনিয়ন্ত্রণ পিল)',
      dosageForm: 'Tablet',
      dosageStrength: 'Daily',
      instructions: 'After Meal',
      morning: false,
      noon: false,
      evening: false,
      night: true,
      nightTime: state.pillTime,
      startDate: todayStr,
      durationDays: state.packDays,
      totalStock: state.packDays,
      currentStock: state.packDays,
      createdAt: DateTime.now().toIso8601String(),
    );
    await ref.read(medicineReminderNotifierProvider.notifier).addReminder(reminder);
  }
}

final womenOCPProvider =
    NotifierProvider<WomenOCPNotifier, OCPTrackerState>(() {
  return WomenOCPNotifier();
});

/// Iron & Folic Acid Supplement Notifier
class WomenIronNotifier extends Notifier<IronSupplementState> {
  static const String _prefsKey = 'rxdigi_iron_supplement_v1';

  @override
  IronSupplementState build() {
    _loadFromPrefs();
    return const IronSupplementState();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = IronSupplementState.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> toggleTakenToday() async {
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final isAlreadyTaken = state.lastTakenDateKey == todayKey;
    final updated = state.copyWith(
      lastTakenDateKey: isAlreadyTaken ? '' : todayKey,
    );
    state = updated;
    await _save(updated);
  }

  Future<void> updateConfig({
    required bool isEnabled,
    required String supplementName,
    required String supplementTime,
  }) async {
    final updated = state.copyWith(
      isEnabled: isEnabled,
      supplementName: supplementName,
      supplementTime: supplementTime,
    );
    state = updated;
    await _save(updated);
  }

  Future<void> _save(IronSupplementState data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(data.toJson()));
  }

  /// Syncs with main Medicine Reminder Database
  Future<void> syncWithMedicationRoutine(WidgetRef ref) async {
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final reminder = MedicineReminderModel(
      medicineName: state.supplementName,
      dosageForm: 'Capsule',
      dosageStrength: 'Daily',
      instructions: 'After Meal',
      morning: false,
      noon: true,
      evening: false,
      night: false,
      noonTime: state.supplementTime,
      startDate: todayStr,
      durationDays: 30,
      totalStock: 30,
      currentStock: 30,
      createdAt: DateTime.now().toIso8601String(),
    );
    await ref.read(medicineReminderNotifierProvider.notifier).addReminder(reminder);
  }
}

final womenIronProvider =
    NotifierProvider<WomenIronNotifier, IronSupplementState>(() {
  return WomenIronNotifier();
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
      if (modeStr == 'pregnancy') {
        state = CycleGoalMode.pregnancy;
      } else if (modeStr == 'tryToConceive') {
        state = CycleGoalMode.tryToConceive;
      } else {
        state = CycleGoalMode.trackCycle;
      }
    }
  }

  Future<void> toggleMode() async {
    final next = state == CycleGoalMode.trackCycle
        ? CycleGoalMode.tryToConceive
        : (state == CycleGoalMode.tryToConceive
            ? CycleGoalMode.pregnancy
            : CycleGoalMode.trackCycle);
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, next.name);
  }

  Future<void> setMode(CycleGoalMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
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
