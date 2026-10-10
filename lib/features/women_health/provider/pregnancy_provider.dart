import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pregnancy_model.dart';

// ─── 1. Core Pregnancy State Notifier ───
class PregnancyNotifier extends Notifier<PregnancyModel> {
  static const String _prefsKey = 'rxdigi_pregnancy_state_v2';

  @override
  PregnancyModel build() {
    _loadFromPrefs();
    // Default unconfigured state for brand-new users
    final defaultLmp = DateTime.now().subtract(const Duration(days: 28));
    final defaultEdd = defaultLmp.add(const Duration(days: 280));
    return PregnancyModel(
      isConfigured: false,
      lastPeriodDate: defaultLmp,
      estimatedDueDate: defaultEdd,
      babyNickname: 'সোনামণি',
      isNotificationEnabled: true,
      notificationHour: 9,
      notificationMinute: 0,
    );
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        state = PregnancyModel.fromJson(map);
      } catch (_) {}
    }
  }

  Future<void> _saveToPrefs(PregnancyModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(model.toJson()));
  }

  Future<void> setupFromLmp(
    DateTime lmp, {
    String nickname = 'সোনামণি',
    bool notifications = true,
  }) async {
    final edd = lmp.add(const Duration(days: 280));
    final updated = state.copyWith(
      isConfigured: true,
      lastPeriodDate: lmp,
      estimatedDueDate: edd,
      babyNickname: nickname,
      isNotificationEnabled: notifications,
    );
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> setupFromEdd(
    DateTime edd, {
    String nickname = 'সোনামণি',
    bool notifications = true,
  }) async {
    final lmp = edd.subtract(const Duration(days: 280));
    final updated = state.copyWith(
      isConfigured: true,
      lastPeriodDate: lmp,
      estimatedDueDate: edd,
      babyNickname: nickname,
      isNotificationEnabled: notifications,
    );
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> updateNickname(String nickname) async {
    final updated = state.copyWith(babyNickname: nickname);
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> toggleNotifications(bool enabled) async {
    final updated = state.copyWith(isNotificationEnabled: enabled);
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> updateNotificationTime(int hour, int minute) async {
    final updated = state.copyWith(
      notificationHour: hour,
      notificationMinute: minute,
    );
    state = updated;
    await _saveToPrefs(updated);
  }

  Future<void> reset() async {
    final defaultLmp = DateTime.now().subtract(const Duration(days: 28));
    final defaultEdd = defaultLmp.add(const Duration(days: 280));
    final initial = PregnancyModel(
      isConfigured: false,
      lastPeriodDate: defaultLmp,
      estimatedDueDate: defaultEdd,
      babyNickname: 'সোনামণি',
      isNotificationEnabled: true,
      notificationHour: 9,
      notificationMinute: 0,
    );
    state = initial;
    await _saveToPrefs(initial);
  }
}

final pregnancyProvider =
    NotifierProvider<PregnancyNotifier, PregnancyModel>(() {
  return PregnancyNotifier();
});

// ─── 2. Selected Week for Carousel Inspection ───
class SelectedPregnancyWeekNotifier extends Notifier<int> {
  @override
  int build() {
    final preg = ref.watch(pregnancyProvider);
    return preg.currentWeek;
  }

  void selectWeek(int week) {
    state = week.clamp(1, 40);
  }
}

final selectedPregnancyWeekProvider =
    NotifierProvider<SelectedPregnancyWeekNotifier, int>(() {
  return SelectedPregnancyWeekNotifier();
});

// ─── 3. Fetal Kick Counter History Notifier ───
class KickCounterLogsNotifier extends Notifier<List<KickCounterLog>> {
  static const String _prefsKey = 'rxdigi_kick_counter_logs_v2';

  @override
  List<KickCounterLog> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state = list
            .map((e) => KickCounterLog.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
  }

  Future<void> addLog(KickCounterLog log) async {
    final updated = [log, ...state];
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> deleteLog(String id) async {
    final updated = state.where((e) => e.id != id).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }
}

final kickCounterLogsProvider =
    NotifierProvider<KickCounterLogsNotifier, List<KickCounterLog>>(() {
  return KickCounterLogsNotifier();
});

/// ─── 4. Asynchronous JSON Catalog Provider ───
final pregnancyWeeksCatalogProvider =
    FutureProvider<List<PregnancyWeekInfo>>((ref) async {
  return await PregnancyWeekCatalog.loadAllWeeks();
});

// ─── 5. Antenatal Care (ANC) Visits & Ultrasound Tracker Notifier ───
class ANCVisitsNotifier extends Notifier<List<ANCVisitItem>> {
  static const String _prefsKey = 'rxdigi_anc_visits_v2';
  static const String _assetPath = 'assets/data/anc_visits.json';

  @override
  List<ANCVisitItem> build() {
    _loadVisits();
    return _fallbackVisits;
  }

  static const List<ANCVisitItem> _fallbackVisits = [
    ANCVisitItem(
      visitNumber: 1,
      weekRange: '৮-১২ সপ্তাহ',
      titleBn: '১ম চেকআপ ও ডেটিং আল্ট্রাসাউন্ড',
      titleEn: '1st ANC Visit & Dating Scan',
      descriptionBn: 'রক্তের গ্রুপ, হিমোগ্লোবিন, সুগার, ইউরিন আর/ই টেস্ট এবং ইডিডি (EDD) নিশ্চিতকরণ।',
      descriptionEn: 'Blood grouping, Hb, blood glucose, urine R/E, and gestational dating confirmation.',
      isCompleted: false,
    ),
    ANCVisitItem(
      visitNumber: 2,
      weekRange: '১৮-২২ সপ্তাহ',
      titleBn: '২য় চেকআপ ও এনোমালি স্ক্যান',
      titleEn: '2nd ANC Visit & Anomaly Scan',
      descriptionBn: 'শিশুর শরীরের সমস্ত অঙ্গপ্রত্যঙ্গের পূর্ণাঙ্গ বিকাশ নিরীক্ষণ এবং টিটি (TT) টিকা গ্রহণ।',
      descriptionEn: 'Level II detailed anatomical scan for congenital markers, plus Tetanus Toxoid (TT).',
      isCompleted: false,
    ),
    ANCVisitItem(
      visitNumber: 3,
      weekRange: '২৮-৩২ সপ্তাহ',
      titleBn: '৩য় চেকআপ ও ডায়াবেটিস স্ক্রিনিং',
      titleEn: '3rd ANC Visit & GDM Screen',
      descriptionBn: 'রক্তচাপ, প্রি-এক্লাম্পসিয়া পরীক্ষা, ওজিটিটি (OGTT) ডায়াবেটিস টেস্ট ও বাচ্চার গ্রোথ স্ক্যান।',
      descriptionEn: 'Blood pressure, pre-eclampsia screening, OGTT glucose test, and fetal growth curve.',
      isCompleted: false,
    ),
    ANCVisitItem(
      visitNumber: 4,
      weekRange: '৩৬-৩৮ সপ্তাহ',
      titleBn: '৪র্থ চেকআপ ও ডেলিভারি পরিকল্পনা',
      titleEn: '4th ANC Visit & Birth Plan',
      descriptionBn: 'শিশুর মাথা নিচে (Cephalic) অবস্থান নিশ্চিতকরণ, প্লাসেন্টার পজিশন ও নরমাল/সিজারিয়ান বার্থ প্ল্যান।',
      descriptionEn: 'Presentation (cephalic check), placental grading, hospital bag, and birth plan.',
      isCompleted: false,
    ),
  ];

  Future<void> _loadVisits() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr != null) {
      try {
        final list = jsonDecode(jsonStr) as List;
        state = list
            .map((e) => ANCVisitItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return;
      } catch (_) {}
    }

    // Load defaults from JSON asset if not found in SharedPreferences
    try {
      final assetJson = await rootBundle.loadString(_assetPath);
      final list = jsonDecode(assetJson) as List;
      state = list
          .map((e) => ANCVisitItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  Future<void> toggleVisit(int visitNumber, {DateTime? date}) async {
    final updated = state.map((v) {
      if (v.visitNumber == visitNumber) {
        final nextStatus = !v.isCompleted;
        return v.copyWith(
          isCompleted: nextStatus,
          completedDate: nextStatus ? (date ?? DateTime.now()) : null,
        );
      }
      return v;
    }).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(updated.map((e) => e.toJson()).toList()),
    );
  }
}

final ancVisitsProvider =
    NotifierProvider<ANCVisitsNotifier, List<ANCVisitItem>>(() {
  return ANCVisitsNotifier();
});

