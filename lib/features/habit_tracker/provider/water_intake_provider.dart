import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterIntakeNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    _loadAll();
    return {};
  }

  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('rxdigi_water_'));
    final map = <String, int>{};
    for (final k in keys) {
      final date = k.replaceFirst('rxdigi_water_', '');
      map[date] = prefs.getInt(k) ?? 0;
    }
    state = map;
  }

  Future<void> setGlasses(String dateStr, int count) async {
    final clamped = count.clamp(0, 16);
    state = {...state, dateStr: clamped};
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rxdigi_water_$dateStr', clamped);
  }

  Future<void> increment(String dateStr) async {
    final current = state[dateStr] ?? 0;
    await setGlasses(dateStr, current + 1);
  }

  Future<void> decrement(String dateStr) async {
    final current = state[dateStr] ?? 0;
    if (current > 0) {
      await setGlasses(dateStr, current - 1);
    }
  }
}

final waterIntakeNotifierProvider = NotifierProvider<WaterIntakeNotifier, Map<String, int>>(
  WaterIntakeNotifier.new,
);

final waterIntakeForDateProvider = Provider.family<int, String>((ref, dateStr) {
  final map = ref.watch(waterIntakeNotifierProvider);
  return map[dateStr] ?? 0;
});

