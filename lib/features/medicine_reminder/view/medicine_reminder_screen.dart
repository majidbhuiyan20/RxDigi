import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../models/medicine_reminder_model.dart';
import '../provider/medicine_reminder_provider.dart';
import 'add_reminder_sheet.dart';

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
            return _buildEmptyState(context, isBn);
          }

          final activeReminders = reminders.where((r) => r.isActive).toList();
          final adherenceMap = adherenceAsync.value ?? {};

          // Calculate today's adherence
          int totalDosesToday = 0;
          int takenDosesToday = 0;
          for (final r in activeReminders) {
            if (r.id != null) {
              if (r.morning) {
                totalDosesToday++;
                if (adherenceMap['${r.id}_morning'] == true) takenDosesToday++;
              }
              if (r.noon) {
                totalDosesToday++;
                if (adherenceMap['${r.id}_noon'] == true) takenDosesToday++;
              }
              if (r.night) {
                totalDosesToday++;
                if (adherenceMap['${r.id}_night'] == true) takenDosesToday++;
              }
            }
          }

          final percent = totalDosesToday > 0 ? (takenDosesToday / totalDosesToday) : 0.0;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // 📊 Daily Summary Card
              _buildProgressCard(context, isBn, activeReminders.length, takenDosesToday, totalDosesToday, percent),
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

              // Medication Cards
              ...reminders.map((reminder) => _buildReminderCard(context, ref, reminder, isBn)),
              const SizedBox(height: 80), // spacing for FAB
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProgressCard(
    BuildContext context,
    bool isBn,
    int activeCount,
    int takenCount,
    int totalCount,
    double progress,
  ) {
    final percentInt = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'আজকের ঔষধ গ্রহণের অগ্রগতি' : "Today's Adherence",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      isBn
                          ? '$totalCount টি ডোজের মধ্যে $takenCount টি গ্রহণ সম্পন্ন ($percentInt%)'
                          : '$takenCount of $totalCount doses taken today ($percentInt%)',
                      style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'মোট সক্রিয় ঔষধ: $activeCount টি' : 'Active prescriptions: $activeCount',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              Text(
                percentInt == 100
                    ? (isBn ? '🎉 সকল ডোজ সম্পন্ন!' : '🎉 All Done!')
                    : (isBn ? 'সময়মত ঔষধ গ্রহণ করুন' : 'Keep it up!'),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    WidgetRef ref,
    MedicineReminderModel reminder,
    bool isBn,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Form Icon Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: reminder.isActive
                        ? AppColors.primaryColor.withOpacity(0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getFormIcon(reminder.dosageForm),
                    color: reminder.isActive ? AppColors.primaryColor : Colors.grey,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Form
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              reminder.medicineName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: reminder.isActive ? Colors.black87 : Colors.grey.shade600,
                              ),
                            ),
                          ),
                          if (reminder.dosageStrength.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                reminder.dosageStrength,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${reminder.dosageForm} • ${reminder.instructions}',
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // Switch / Menu
                Switch(
                  value: reminder.isActive,
                  activeColor: AppColors.primaryColor,
                  onChanged: (val) {
                    if (reminder.id != null) {
                      ref.read(medicineReminderNotifierProvider.notifier).toggleReminderActive(reminder.id!, val);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Times Slots Row
            Row(
              children: [
                if (reminder.morning)
                  _buildSlotBadge(
                    '🌅 ${isBn ? "সকাল" : "Morning"}',
                    reminder.morningTime,
                    reminder.isActive,
                  ),
                if (reminder.noon) ...[
                  const SizedBox(width: 8),
                  _buildSlotBadge(
                    '☀️ ${isBn ? "দুপুর" : "Noon"}',
                    reminder.noonTime,
                    reminder.isActive,
                  ),
                ],
                if (reminder.night) ...[
                  const SizedBox(width: 8),
                  _buildSlotBadge(
                    '🌙 ${isBn ? "রাত" : "Night"}',
                    reminder.nightTime,
                    reminder.isActive,
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                  tooltip: isBn ? 'মুছুন' : 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context, ref, reminder, isBn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotBadge(String label, String time, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FDF4) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? const Color(0xFF86EFAC) : Colors.grey.shade300,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  IconData _getFormIcon(String form) {
    switch (form.toLowerCase()) {
      case 'tablet':
        return Icons.medication_rounded;
      case 'capsule':
        return Icons.medication_liquid_rounded;
      case 'syrup':
        return Icons.local_drink_rounded;
      case 'drop':
        return Icons.water_drop_rounded;
      case 'injection':
        return Icons.vaccines_rounded;
      default:
        return Icons.healing_rounded;
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MedicineReminderModel reminder, bool isBn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isBn ? 'রিমাইন্ডার মুছে ফেলতে চান?' : 'Delete Reminder?'),
        content: Text(
          isBn
              ? '${reminder.medicineName} এর রিমাইন্ডার মুছে ফেলা হবে।'
              : 'Are you sure you want to delete ${reminder.medicineName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (reminder.id != null) {
                ref.read(medicineReminderNotifierProvider.notifier).deleteReminder(reminder.id!);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isBn ? 'মুছুন' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.alarm_on_rounded, size: 64, color: AppColors.primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              isBn ? 'কোনো মেডিসিন রিমাইন্ডার নেই' : 'No Medicine Reminders Yet',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isBn
                  ? 'আপনার প্রতিদিনের ঔষধের সময়সূচী যোগ করুন এবং নিয়মিত সঠিক সময়ে ঔষধ গ্রহণ করুন।'
                  : 'Add your regular prescriptions and vitamins to track your daily intake and never miss a dose.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => AddReminderSheet.show(context),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                isBn ? 'প্রথম রিমাইন্ডার যোগ করুন' : 'Add First Reminder',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
