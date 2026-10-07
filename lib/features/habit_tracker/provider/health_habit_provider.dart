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
  }
}

final healthHabitNotifierProvider = NotifierProvider<HealthHabitNotifier, void>(HealthHabitNotifier.new);

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
