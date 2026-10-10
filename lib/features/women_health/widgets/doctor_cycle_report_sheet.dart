import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../services/doctor_cycle_report_generator.dart';
import '../utils/women_health_formatters.dart';

class DoctorCycleReportSheet extends ConsumerWidget {
  final MenstrualCycleModel cycle;

  const DoctorCycleReportSheet({
    super.key,
    required this.cycle,
  });

  static Future<void> show(BuildContext context, MenstrualCycleModel cycle) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DoctorCycleReportSheet(cycle: cycle),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final history = ref.watch(womenCycleHistoryProvider);
    final symptomsMap = ref.watch(dailySymptomProvider);
    final ocpState = ref.watch(womenOCPProvider);
    final ironState = ref.watch(womenIronProvider);

    final lmpStr = WomenHealthFormatters.formatDayMonth(cycle.lastPeriodStartDate, isBn: isBn);
    final nextPeriodStr = WomenHealthFormatters.formatDayMonth(cycle.nextPeriodDate, isBn: isBn);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        PhosphorIconsFill.filePdf,
                        color: Color(0xFFE11D48),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'ডাক্তারের ক্লিনিক্যাল সামারি' : 'Doctor Clinical Summary',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          isBn ? 'গাইনোকোলজিস্টের জন্য সাইকেল রেকর্ড' : 'Menstrual Brief for Gynecologist',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Body Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                // Highlight Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFECDD3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsFill.stethoscope, color: Color(0xFFBE123C), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isBn
                            ? 'ডাক্তার দেখানোর সময় শেষ পিরিয়ডের তারিখ ও সাইকেলের পরিবর্তন সহজেই তুলে ধরুন।'
                            : 'Present your exact LMP, cycle variations, and symptoms clearly during doctor consultations.',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9F1239),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Clinical Grid: LMP, Cycle Length, Bleeding Days, Regularity
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: isBn ? 'সর্বশেষ পিরিয়ড (LMP)' : 'Last Period (LMP)',
                        value: lmpStr,
                        subtitle: isBn ? 'পরবর্তী: $nextPeriodStr' : 'Next: $nextPeriodStr',
                        color: const Color(0xFFBE123C),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: isBn ? 'সাইকেলের দৈর্ঘ্য' : 'Cycle Length',
                        value: WomenHealthFormatters.formatDaysCount(cycle.cycleLength, isBn: isBn),
                        subtitle: isBn ? 'স্বাভাবিক: ২১-৩৫ দিন' : 'Norm: 21-35 days',
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: isBn ? 'ব্লিডিং সময়কাল' : 'Bleeding Duration',
                        value: WomenHealthFormatters.formatDaysCount(cycle.periodDuration, isBn: isBn),
                        subtitle: isBn ? 'স্বাভাবিক: ৩-৭ দিন' : 'Norm: 3-7 days',
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: isBn ? 'সাইকেল স্ট্যাটাস' : 'Regularity Status',
                        value: cycle.isIrregularCycle
                            ? (isBn ? 'অনিয়মিত (Flagged)' : 'Irregular (Flagged)')
                            : (isBn ? 'স্বাভাবিক ও নিয়মিত' : 'Normal Regular'),
                        subtitle: cycle.isIrregularCycle
                            ? (isBn ? 'PCOS / হরমোনাল ঝুঁকি' : 'Suspected Oligo/PCOS')
                            : (isBn ? 'FIGO মানদণ্ড' : 'FIGO Standard'),
                        color: cycle.isIrregularCycle ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Contraception & Supplements Summary
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(PhosphorIconsFill.pill, size: 16, color: Color(0xFF475569)),
                          const SizedBox(width: 6),
                          Text(
                            isBn ? 'ওষুধ ও সাপ্লিমেন্ট হিস্ট্রি' : 'Medication & Supplements',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• ${isBn ? "জন্মনিয়ন্ত্রণ পিল (OCP): " : "Birth Control Pill: "}${ocpState.isEnabled ? "${ocpState.pillBrand} (${ocpState.packDays} ${isBn ? "পিল প্যাক" : "pills"})" : (isBn ? "চালু নেই" : "None")}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '• ${isBn ? "আয়রন ও ফলিক এসিড: " : "Iron Supplement: "}${ironState.isEnabled ? ironState.supplementName : (isBn ? "চালু নেই" : "None")}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Recent Cycles Timeline List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'বিগত সাইকেলের তালিকা' : 'Recent Cycles Log',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${history.length + 1} ${isBn ? "টি রেকর্ড" : "cycles"}',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Current Cycle Tile
                _buildCycleTile(
                  label: isBn ? 'চলমান সাইকেল' : 'Current Cycle',
                  startDate: cycle.lastPeriodStartDate,
                  cycleLength: cycle.cycleLength,
                  periodDays: cycle.periodDuration,
                  isIrregular: cycle.isIrregularCycle,
                  isBn: isBn,
                  isCurrent: true,
                ),

                ...history.map((h) => _buildCycleTile(
                      label: h.notes ?? (isBn ? 'বিগত সাইকেল' : 'Past Cycle'),
                      startDate: h.startDate,
                      cycleLength: h.cycleLength,
                      periodDays: h.periodDuration,
                      isIrregular: h.isIrregular,
                      isBn: isBn,
                      isCurrent: false,
                    )),
              ],
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Copy Text Button
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      AppFeedback.playLight();
                      final text = DoctorCycleReportGenerator.generatePlainTextSummary(
                        cycle: cycle,
                        cycleHistory: history,
                        ocpState: ocpState,
                        ironState: ironState,
                        isBn: isBn,
                      );
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isBn ? '📋 সামারি টেক্সট কপি হয়েছে' : '📋 Summary copied to clipboard'),
                          backgroundColor: const Color(0xFF0F172A),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(PhosphorIconsRegular.copy, size: 16),
                    label: Text(isBn ? 'কপি' : 'Copy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Print Button
                IconButton.outlined(
                  onPressed: () {
                    AppFeedback.playLight();
                    DoctorCycleReportGenerator.printReport(
                      cycle: cycle,
                      cycleHistory: history,
                      symptomsMap: symptomsMap,
                      ocpState: ocpState,
                      ironState: ironState,
                    );
                  },
                  icon: const Icon(PhosphorIconsRegular.printer, size: 18),
                  style: IconButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 8),
                // Share PDF Primary Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      AppFeedback.playSuccess();
                      DoctorCycleReportGenerator.shareReport(
                        cycle: cycle,
                        cycleHistory: history,
                        symptomsMap: symptomsMap,
                        ocpState: ocpState,
                        ironState: ironState,
                      );
                    },
                    icon: const Icon(PhosphorIconsFill.shareNetwork, size: 17),
                    label: Text(
                      isBn ? 'PDF শেয়ার / সেভ' : 'Share / Save PDF',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFBE123C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9.5,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCycleTile({
    required String label,
    required DateTime startDate,
    required int cycleLength,
    required int periodDays,
    required bool isIrregular,
    required bool isBn,
    required bool isCurrent,
  }) {
    final dateFormatted = WomenHealthFormatters.formatDayMonth(startDate, isBn: isBn);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFFFF1F2) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? const Color(0xFFFECDD3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isIrregular ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${WomenHealthFormatters.formatDigits(cycleLength, isBn: isBn)} ${isBn ? "দিনের চক্র" : "days cycle"}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isIrregular ? const Color(0xFFDC2626) : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${isBn ? "ব্লিডিং: " : "Bleeding: "}${WomenHealthFormatters.formatDigits(periodDays, isBn: isBn)} ${isBn ? "দিন" : "days"}',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

