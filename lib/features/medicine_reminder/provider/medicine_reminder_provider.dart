import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/medicine_reminder_model.dart';
import '../repository/medicine_reminder_repository.dart';

final medicineReminderRepoProvider = Provider<MedicineReminderRepository>((ref) {
  return MedicineReminderRepository();
});

// All active reminders
final activeRemindersProvider = FutureProvider<List<MedicineReminderModel>>((ref) async {
  final repo = ref.watch(medicineReminderRepoProvider);
  return await repo.getActiveReminders();
});

// All reminders (active + paused)
final allRemindersProvider = FutureProvider<List<MedicineReminderModel>>((ref) async {
  final repo = ref.watch(medicineReminderRepoProvider);
  return await repo.getAllReminders();
});

// Selected or today's date for adherence check
String getTodayDateString() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
}

// Adherence map for today: Map<"${reminderId}_${slot}", bool>
final todayAdherenceMapProvider = FutureProvider<Map<String, bool>>((ref) async {
  final repo = ref.watch(medicineReminderRepoProvider);
  final today = getTodayDateString();
  return await repo.getAdherenceMapForDate(today);
});

// Notifier to handle adherence toggling and reminder operations
class MedicineReminderNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addReminder(MedicineReminderModel reminder) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await repo.insertReminder(reminder);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(todayAdherenceMapProvider);
  }

  Future<void> toggleReminderActive(int id, bool isActive) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await repo.toggleReminderActive(id, isActive);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(todayAdherenceMapProvider);
  }

  Future<void> deleteReminder(int id) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await repo.deleteReminder(id);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(todayAdherenceMapProvider);
  }

  Future<void> toggleAdherence({
    required int reminderId,
    required String slot,
    required bool isCurrentlyTaken,
  }) async {
    final repo = ref.read(medicineReminderRepoProvider);
    final today = getTodayDateString();
    final becomingTaken = !isCurrentlyTaken;

    await repo.setAdherence(
      reminderId: reminderId,
      date: today,
      slot: slot,
      isTaken: becomingTaken,
    );

    // Automatically update remaining medicine stock
    if (becomingTaken) {
      await repo.decrementStock(reminderId);
    } else {
      await repo.incrementStock(reminderId);
    }

    ref.invalidate(todayAdherenceMapProvider);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
  }

  Future<void> refillStock(int reminderId, int addedStock) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await repo.refillStock(reminderId, addedStock);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
  }
}

final medicineReminderNotifierProvider =
    NotifierProvider<MedicineReminderNotifier, void>(() {
  return MedicineReminderNotifier();
});
