import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../medicine_reminder/provider/medicine_reminder_provider.dart';
import '../models/health_habit_model.dart';
import '../repository/health_habit_repository.dart';

String habitDateString(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

final healthHabitRepositoryProvider = Provider<HealthHabitRepository>((ref) => HealthHabitRepository());

final activeHealthHabitsProvider = FutureProvider<List<HealthHabitModel>>((ref) async {
  return ref.watch(healthHabitRepositoryProvider).getActiveHabits();
});

final todayCompletedHabitIdsProvider = FutureProvider<Set<int>>((ref) async {
  return ref.watch(healthHabitRepositoryProvider).getCompletedHabitIds(habitDateString(DateTime.now()));
});

final weeklyHabitCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final today = DateTime.now();
  final dates = List.generate(7, (index) => habitDateString(today.subtract(Duration(days: 6 - index))));
  return ref.watch(healthHabitRepositoryProvider).getDailyCompletedCounts(dates);
});

class HealthHabitNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> toggle(int habitId, bool completed) async {
    await ref.read(healthHabitRepositoryProvider).setCompleted(
          habitId: habitId,
          date: habitDateString(DateTime.now()),
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
    ref.invalidate(weeklyHabitCountsProvider);
  }
}

final healthHabitNotifierProvider = NotifierProvider<HealthHabitNotifier, void>(HealthHabitNotifier.new);

final medicineAdherenceSummaryProvider = FutureProvider<Map<String, int>>((ref) async {
  final reminders = await ref.watch(activeRemindersProvider.future);
  final adherence = await ref.watch(todayAdherenceMapProvider.future);
  var total = 0;
  var taken = 0;
  for (final reminder in reminders) {
    if (reminder.id == null) continue;
    for (final slot in reminder.activeSlots) {
      total++;
      if (adherence['${reminder.id}_$slot'] == true) taken++;
    }
  }
  return {'taken': taken, 'total': total};
});
