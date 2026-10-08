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
                      if (reminder.hasStockTracking) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: reminder.isOutOfStock
                                    ? Colors.red.shade50
                                    : reminder.isLowStock
                                        ? Colors.orange.shade50
                                        : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: reminder.isOutOfStock
                                      ? Colors.red.shade300
                                      : reminder.isLowStock
                                          ? Colors.orange.shade300
                                          : Colors.green.shade300,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    reminder.isOutOfStock
                                        ? PhosphorIconsRegular.warningCircle
                                        : reminder.isLowStock
                                            ? PhosphorIconsRegular.warning
                                            : PhosphorIconsRegular.package,
                                    size: 13,
                                    color: reminder.isOutOfStock
                                        ? Colors.red.shade700
                                        : reminder.isLowStock
                                            ? Colors.orange.shade800
                                            : Colors.green.shade700,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    reminder.isOutOfStock
                                        ? (isBn ? 'স্টক শেষ!' : 'Out of stock!')
                                        : reminder.isLowStock
                                            ? (isBn ? 'মাত্র ${reminder.currentStock}টি বাকি' : 'Only ${reminder.currentStock} left')
                                            : (isBn ? 'স্টক: ${reminder.currentStock}টি বাকি' : 'Stock: ${reminder.currentStock} left'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: reminder.isOutOfStock
                                          ? Colors.red.shade700
                                          : reminder.isLowStock
                                              ? Colors.orange.shade800
                                              : Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () {
                                if (reminder.id != null) {
                                  ref.read(medicineReminderNotifierProvider.notifier).refillStock(reminder.id!, 10);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(isBn ? '${reminder.medicineName} এ ১০টি ট্যাবলেট যোগ করা হয়েছে' : 'Added 10 pills to ${reminder.medicineName}')),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isBn ? '+১০ রিফিল' : '+10 Refill',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (reminder.morning)
                        _buildSlotBadge(SlotStyle.morning, isBn ? 'সকাল' : 'Morning', reminder.morningTime, reminder.isActive),
                      if (reminder.noon)
                        _buildSlotBadge(SlotStyle.noon, isBn ? 'দুপুর' : 'Noon', reminder.noonTime, reminder.isActive),
                      if (reminder.evening)
                        _buildSlotBadge(SlotStyle.evening, isBn ? 'সন্ধ্যা' : 'Evening', reminder.eveningTime, reminder.isActive),
                      if (reminder.night)
                        _buildSlotBadge(SlotStyle.night, isBn ? 'রাত' : 'Night', reminder.nightTime, reminder.isActive),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
      case 'capsule':
        return PhosphorIconsRegular.pill;
      case 'syrup':
      case 'drop':
        return PhosphorIconsRegular.drop;
      case 'injection':
        return PhosphorIconsRegular.syringe;
      default:
        return PhosphorIconsRegular.firstAid;
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
