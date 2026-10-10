import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/pregnancy_model.dart';
import '../provider/pregnancy_provider.dart';
import '../utils/women_health_formatters.dart';

class AncVisitsCard extends ConsumerWidget {
  const AncVisitsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final visits = ref.watch(ancVisitsProvider);
    final completedCount = visits.where((v) => v.isCompleted).length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.stethoscope,
                      size: 18,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'ডাক্তারের চেকআপ (ANC শিডিউল)' : 'Doctor Visits (ANC Protocol)',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${WomenHealthFormatters.formatDigits(completedCount, isBn: isBn)}/${WomenHealthFormatters.formatDigits(visits.length, isBn: isBn)} ${isBn ? "সম্পন্ন" : "done"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            isBn
                ? 'WHO ও জাতীয় প্রোটোকল অনুযায়ী গর্ভাবস্থায় চিকিৎসকের নিয়মিত চেকআপ ও প্রয়োজনীয় আল্ট্রাসাউন্ড তালিকা:'
                : 'WHO & National standard antenatal care appointments and crucial ultrasound roadmap:',
            style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade600),
          ),

          const SizedBox(height: 14),

          // Visit list
          ...visits.map((item) => _buildVisitItem(context, ref, item, isBn)),
        ],
      ),
    );
  }

  Widget _buildVisitItem(
    BuildContext context,
    WidgetRef ref,
    ANCVisitItem item,
    bool isBn,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isCompleted ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isCompleted ? const Color(0xFFE2E8F0) : const Color(0xFFBAE6FD),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1-Tap Checkbox
          GestureDetector(
            onTap: () {
              AppFeedback.playSuccess();
              ref.read(ancVisitsProvider.notifier).toggleVisit(item.visitNumber);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.isCompleted ? const Color(0xFF0284C7) : Colors.white,
                border: Border.all(
                  color: item.isCompleted ? const Color(0xFF0284C7) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? item.titleBn : item.titleEn,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: item.isCompleted ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                        decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.weekRange,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isBn ? item.descriptionBn : item.descriptionEn,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (item.isCompleted && item.completedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${isBn ? "সম্পন্ন: " : "Completed: "}${WomenHealthFormatters.formatDayMonth(item.completedDate!, isBn: isBn)}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
