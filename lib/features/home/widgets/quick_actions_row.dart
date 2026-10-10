import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../medicines/view/medicines_screen.dart';
import '../../medicine_reminder/view/add_reminder_sheet.dart';
import '../../vitals/view/add_vital_sheet.dart';
import '../../rx_studio/view/rx_studio_screen.dart';

class QuickActionsRow extends StatelessWidget {
  const QuickActionsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    final items = [
      _ActionItem(
        title: isBn ? 'ঔষধের দাম' : 'Medicine Index',
        subtitle: isBn ? 'সস্তা বিকল্প' : 'Prices',
        icon: PhosphorIconsRegular.pill,
        bgColor: const Color(0xFFEFF6FF), // Soft Blue
        iconColor: const Color(0xFF2563EB),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MedicinesScreen())),
      ),
      _ActionItem(
        title: isBn ? 'রিমাইন্ডার' : 'Reminder',
        subtitle: isBn ? 'অ্যালার্ম সেট' : 'Schedule',
        icon: PhosphorIconsRegular.alarm,
        bgColor: const Color(0xFFF0FDF4), // Soft Emerald
        iconColor: const Color(0xFF16A34A),
        onTap: () => AddReminderSheet.show(context),
      ),
      _ActionItem(
        title: isBn ? 'প্রেশার/সুগার' : 'Vitals Log',
        subtitle: isBn ? 'পরিমাপ করুন' : 'Track BP',
        icon: PhosphorIconsRegular.heartbeat,
        bgColor: const Color(0xFFFEF2F2), // Soft Rose
        iconColor: const Color(0xFFDC2626),
        onTap: () => AddVitalSheet.show(context),
      ),
      _ActionItem(
        title: isBn ? 'প্রেসক্রিপশন' : 'Rx Studio',
        subtitle: isBn ? 'নতুন তৈরি' : 'Digital Rx',
        icon: PhosphorIconsRegular.fileText,
        bgColor: const Color(0xFFFAF5FF), // Soft Purple
        iconColor: const Color(0xFF9333EA),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RxStudioScreen())),
      ),
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              elevation: 0,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.025),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: item.bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: item.iconColor, size: 20),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
}
