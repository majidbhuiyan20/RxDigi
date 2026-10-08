import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                PhosphorIconsFill.alarm,
                size: 18,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isBn ? 'মেডিসিন রিমাইন্ডার' : 'Medicine Reminder',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => AddReminderSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsBold.plus, size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'নতুন ঔষধ' : 'Add Med',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            physics: const BouncingScrollPhysics(),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isBn ? '${reminders.length} টি ঔষধ' : '${reminders.length} Meds',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Medication Cards
              ...reminders.map((reminder) => MedicineReminderCard(reminder: reminder, isBn: isBn)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
