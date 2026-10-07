import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../provider/medicine_reminder_provider.dart';
import 'add_reminder_sheet.dart';
import '../widgets/adherence_progress_card.dart';
import '../widgets/medicine_reminder_card.dart';
import '../widgets/reminder_empty_state.dart';

class MedicineReminderScreen extends ConsumerWidget {
  const MedicineReminderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final remindersAsync = ref.watch(allRemindersProvider);
    final adherenceAsync = ref.watch(todayAdherenceMapProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          isBn ? 'মেডিসিন রিমাইন্ডার' : 'Medicine Reminder',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 26),
            tooltip: isBn ? 'নতুন যোগ করুন' : 'Add Reminder',
            onPressed: () => AddReminderSheet.show(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddReminderSheet.show(context),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isBn ? 'নতুন রিমাইন্ডার' : 'Add Medication',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: remindersAsync.when(
        data: (reminders) {
          if (reminders.isEmpty) {
            return ReminderEmptyState(isBn: isBn);
          }

          final activeReminders = reminders.where((r) => r.isActive).toList();
          final adherenceMap = adherenceAsync.value ?? {};

          // Calculate today's adherence
          int totalDosesToday = 0;
          int takenTodayDoses = 0;
          for (final r in activeReminders) {
            if (r.id != null) {
              if (r.morning) {
                totalDosesToday++;
                if (adherenceMap['${r.id}_morning'] == true) takenTodayDoses++;
              }
              if (r.noon) {
                totalDosesToday++;
                if (adherenceMap['${r.id}_noon'] == true) takenTodayDoses++;
              }
              if (r.evening) {
                totalDosesToday++;
                if (adherenceMap['${r.id}_evening'] == true) takenTodayDoses++;
              }
              if (r.night) {
                totalDosesToday++;
                if (adherenceMap['${r.id}_night'] == true) takenTodayDoses++;
              }
            }
          }

          final percent = totalDosesToday > 0 ? (takenTodayDoses / totalDosesToday) : 0.0;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // 1. Daily Summary Progress Card
              AdherenceProgressCard(
                activeCount: activeReminders.length,
                takenCount: takenTodayDoses,
                totalCount: totalDosesToday,
                progress: percent,
                isBn: isBn,
              ),
              const SizedBox(height: 20),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'আপনার ঔষধের তালিকা' : 'Your Medication List',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isBn ? '${reminders.length} টি ঔষধ' : '${reminders.length} Meds',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Medication Cards
              ...reminders.map((reminder) => MedicineReminderCard(reminder: reminder, isBn: isBn)),
              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
