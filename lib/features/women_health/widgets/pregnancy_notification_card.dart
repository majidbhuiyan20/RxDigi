import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/pregnancy_model.dart';
import '../services/pregnancy_notification_service.dart';
import 'pregnancy_setup_sheet.dart';

class PregnancyNotificationCard extends ConsumerWidget {
  final PregnancyModel pregnancy;

  const PregnancyNotificationCard({
    super.key,
    required this.pregnancy,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final timeStr = pregnancy.notificationTime.format(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.bellRinging,
                      size: 16,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'সচেতনতামূলক দৈনিক নোটিফিকেশন' : 'Daily Maternal Awareness Alerts',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: pregnancy.isNotificationEnabled
                      ? const Color(0xFFECFDF5)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: pregnancy.isNotificationEnabled
                        ? const Color(0xFFA7F3D0)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  pregnancy.isNotificationEnabled
                      ? (isBn ? 'সক্রিয় ($timeStr)' : 'Active ($timeStr)')
                      : (isBn ? 'বন্ধ' : 'Disabled'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: pregnancy.isNotificationEnabled
                        ? const Color(0xFF047857)
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            isBn
                ? 'সোনামণির বৃদ্ধির নিয়মিত আপডেট, পুষ্টিকর খাবার এবং সুস্বাস্থ্যের টিপস আপনার নির্বাচিত ভাষায় ($timeStr টায়) স্বয়ংক্রিয়ভাবে পাঠানো হয়।'
                : 'Fetal growth milestones, maternal hydration, and care tips are delivered daily at $timeStr in your chosen language.',
            style: TextStyle(fontSize: 11.5, height: 1.4, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppFeedback.playLight();
                    PregnancySetupSheet.show(context);
                  },
                  icon: const Icon(PhosphorIconsRegular.clock, size: 14),
                  label: Text(
                    isBn ? 'সময় পরিবর্তন' : 'Change Time',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    AppFeedback.playSuccess();
                    await PregnancyNotificationService.sendTestNotification(
                      model: pregnancy,
                      isBn: isBn,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBn
                              ? '🔔 টেস্ট নোটিফিকেশন সফলভাবে পাঠানো হয়েছে!'
                              : '🔔 Test notification sent successfully!'),
                          backgroundColor: const Color(0xFF0F172A),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(PhosphorIconsFill.paperPlaneRight, size: 14),
                  label: Text(
                    isBn ? 'টেস্ট নোটিফিকেশন' : 'Test Alert Now',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
