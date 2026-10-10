import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../models/medicine_reminder_model.dart';
import '../models/medicine_adherence_model.dart';
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
  final repo = ref.read(medicineReminderRepoProvider);
  final today = getTodayDateString();
  return await repo.getAdherenceMapForDate(today);
});

// Weekly Adherence Report for Analytics & Consistency tracking
final weeklyAdherenceReportProvider = FutureProvider<WeeklyAdherenceReport>((ref) async {
  final repo = ref.read(medicineReminderRepoProvider);
  return await repo.getWeeklyAdherenceReport();
});

// Notifier to handle adherence toggling and reminder operations
class MedicineReminderNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> addReminder(MedicineReminderModel reminder) async {
    final repo = ref.read(medicineReminderRepoProvider);
    final id = await repo.insertReminder(reminder);
    final savedReminder = reminder.copyWith(id: id);
    if (savedReminder.isActive) {
      await NotificationService().scheduleMedicineReminder(savedReminder);
    }
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(todayAdherenceMapProvider);
    ref.invalidate(weeklyAdherenceReportProvider);
  }

  Future<void> updateReminder(MedicineReminderModel reminder) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await repo.updateReminder(reminder);
    if (reminder.id != null) {
      await NotificationService().cancelMedicineReminders(reminder.id!);
      if (reminder.isActive) {
        await NotificationService().scheduleMedicineReminder(reminder);
      }
    }
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(todayAdherenceMapProvider);
    ref.invalidate(weeklyAdherenceReportProvider);
  }

  Future<void> toggleReminderActive(int id, bool isActive) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await repo.toggleReminderActive(id, isActive);
    if (isActive) {
      final all = await repo.getAllReminders();
      final match = all.where((r) => r.id == id).firstOrNull;
      if (match != null) {
        await NotificationService().scheduleMedicineReminder(match);
      }
    } else {
      await NotificationService().cancelMedicineReminders(id);
    }
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(todayAdherenceMapProvider);
    ref.invalidate(weeklyAdherenceReportProvider);
  }

  Future<void> deleteReminder(int id) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await NotificationService().cancelMedicineReminders(id);
    await repo.deleteReminder(id);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(todayAdherenceMapProvider);
    ref.invalidate(weeklyAdherenceReportProvider);
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
      final all = await repo.getAllReminders();
      final match = all.where((r) => r.id == reminderId).firstOrNull;
      if (match != null &&
          match.isRefillAlertEnabled &&
          match.hasStockTracking &&
          match.currentStock <= match.lowStockThreshold) {
        await NotificationService().showRefillAlert(
          medicineName: match.medicineName,
          remainingStock: match.currentStock,
        );
      }
    } else {
      await repo.incrementStock(reminderId);
    }

    ref.invalidate(todayAdherenceMapProvider);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(weeklyAdherenceReportProvider);
  }

  Future<void> refillStock(int reminderId, int addedStock) async {
    final repo = ref.read(medicineReminderRepoProvider);
    await repo.refillStock(reminderId, addedStock);
    ref.invalidate(activeRemindersProvider);
    ref.invalidate(allRemindersProvider);
    ref.invalidate(weeklyAdherenceReportProvider);
  }
}

final medicineReminderNotifierProvider =
    NotifierProvider<MedicineReminderNotifier, void>(() {
  return MedicineReminderNotifier();
});
