import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';

class QuickPeriodActionCard extends ConsumerWidget {
  final MenstrualCycleModel cycle;

  const QuickPeriodActionCard({
    super.key,
    required this.cycle,
  });

  void _showStartPeriodDialog(BuildContext context, WidgetRef ref, bool isBn) {
    AppFeedback.playLight();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(PhosphorIconsFill.drop, color: Color(0xFFF43F5E), size: 22),
            const SizedBox(width: 8),
            Text(
              isBn ? 'নতুন পিরিয়ড শুরু?' : 'Period Started Today?',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isBn
              ? 'আজকে আপনার নতুন মাসিক চক্রের ১ম দিন হিসেবে চিহ্নিত করতে চান? আপনার পরবর্তী পূর্বাভাসগুলো স্বয়ংক্রিয়ভাবে আপডেট হয়ে যাবে।'
              : 'Mark today as Day 1 of your new menstrual cycle? Predictions will automatically recalculate.',
          style: const TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel', style: const TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () async {
              AppFeedback.playSuccess();
              Navigator.pop(ctx);
              await ref.read(womenCycleProvider.notifier).recordPeriodStarted(DateTime.now());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBn ? '🩸 আজকের দিনটি পিরিয়ডের ১ম দিন হিসেবে সেভ হয়েছে' : '🩸 Today saved as Day 1 of period'),
                    backgroundColor: const Color(0xFFF43F5E),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isBn ? 'হ্যাঁ, রেকর্ড করুন' : 'Yes, Log Start', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEndPeriodDialog(BuildContext context, WidgetRef ref, bool isBn) {
    AppFeedback.playLight();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            const Icon(PhosphorIconsFill.sparkle, color: Color(0xFF10B981), size: 22),
            const SizedBox(width: 8),
            Text(
              isBn ? 'পিরিয়ড শেষ হয়েছে?' : 'Period Ended Today?',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          isBn
              ? 'আজকে পিরিয়ডের রক্তক্ষরণ শেষ হয়েছে হিসেবে রেকর্ড করবেন?'
              : 'Mark today as the end of period bleeding?',
          style: const TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel', style: const TextStyle(color: Color(0xFF94A3B8))),
          ),
          ElevatedButton(
            onPressed: () async {
              AppFeedback.playSuccess();
              Navigator.pop(ctx);
              await ref.read(womenCycleProvider.notifier).recordPeriodEnded(DateTime.now());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBn ? '✨ পিরিয়ডের সময়কাল সফলভাবে আপডেট হয়েছে' : '✨ Period duration updated successfully'),
                    backgroundColor: const Color(0xFF10B981),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isBn ? 'হ্যাঁ, শেষ হয়েছে' : 'Yes, Log End', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final isPeriodNow = cycle.currentPhase == CyclePhase.menstrual;

    if (isPeriodNow) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsFill.check, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'পিরিয়ড কি শেষ হয়েছে?' : 'Has period ended?',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isBn ? 'আজকে রক্তক্ষরণ বন্ধ হয়ে থাকলে ট্যাপ করুন' : 'Tap if bleeding stopped today',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => _showEndPeriodDialog(context, ref, isBn),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isBn ? 'শেষ হয়েছে' : 'Ended',
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFF43F5E),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsFill.drop, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBn ? 'আজ কি পিরিয়ড শুরু হয়েছে?' : 'Did period start today?',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9F1239),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  isBn ? '১ম দিন হিসেবে দ্রুত রেকর্ড করুন' : 'Quickly log as Day 1',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFBE123C),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showStartPeriodDialog(context, ref, isBn),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF43F5E),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isBn ? 'শুরু হয়েছে' : 'Started',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
