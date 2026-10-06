import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../view/add_reminder_sheet.dart';

class ReminderEmptyState extends StatelessWidget {
  final bool isBn;

  const ReminderEmptyState({super.key, required this.isBn});

  @override
  Widget build(BuildContext context) {
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
