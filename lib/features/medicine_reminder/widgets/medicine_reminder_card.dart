import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/slot_style.dart';
import '../../../app/app_colors.dart';
import '../models/medicine_reminder_model.dart';
import '../provider/medicine_reminder_provider.dart';

class MedicineReminderCard extends ConsumerWidget {
  final MedicineReminderModel reminder;
  final bool isBn;

  const MedicineReminderCard({
    super.key,
    required this.reminder,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  _buildSlotBadge(SlotStyle.morning, isBn ? 'সকাল' : 'Morning', reminder.morningTime, reminder.isActive),
                if (reminder.noon) ...[
                  const SizedBox(width: 8),
                  _buildSlotBadge(SlotStyle.noon, isBn ? 'দুপুর' : 'Noon', reminder.noonTime, reminder.isActive),
                ],
                if (reminder.night) ...[
                  const SizedBox(width: 8),
                  _buildSlotBadge(SlotStyle.night, isBn ? 'রাত' : 'Night', reminder.nightTime, reminder.isActive),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(PhosphorIconsRegular.trash, size: 20, color: Colors.red.shade400),
                  tooltip: isBn ? 'মুছুন' : 'Delete',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotBadge(SlotStyle style, String label, String time, bool isActive) {
    final c = isActive ? style.color : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 16, color: c),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c)),
              Text(time, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
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

  void _confirmDelete(BuildContext context, WidgetRef ref) {
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
}
