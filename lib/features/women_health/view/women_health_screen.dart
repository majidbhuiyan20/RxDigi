import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/daily_symptom_log.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../utils/women_health_formatters.dart';
import '../widgets/cycle_visualizer_ring.dart';
import '../widgets/horizontal_cycle_date_strip.dart';
import '../widgets/hormone_curve_chart.dart';
import '../widgets/quick_period_action_card.dart';
import '../widgets/daily_body_forecast_section.dart';
import '../widgets/symptom_logger_sheet.dart';
import '../widgets/cycle_settings_sheet.dart';
import '../../../core/utils/app_feedback.dart';

class WomenHealthScreen extends ConsumerWidget {
  const WomenHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final cycle = ref.watch(womenCycleProvider);
    final selectedDate = ref.watch(selectedCycleDateProvider);
    final goalMode = ref.watch(cycleGoalModeProvider);
    final symptomsMap = ref.watch(dailySymptomProvider);

    final selectedDateKey = WomenHealthFormatters.toDateKey(selectedDate);
    final selectedLog = symptomsMap[selectedDateKey];

    final isSelectedToday = WomenHealthFormatters.isSameDay(selectedDate, DateTime.now());
    final targetPhase = cycle.getPhaseFor(selectedDate);
    final targetDay = cycle.getCycleDayFor(selectedDate);

    final nextPeriodFormatted = WomenHealthFormatters.formatDayMonthBn(cycle.nextPeriodDate);
    final nextOvulationFormatted = WomenHealthFormatters.formatDayMonthBn(cycle.nextOvulationDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9), // Soft Blush Background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'উইমেন হেলথ ও সাইকেল' : 'Women Health & Cycle',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          // Cycle Goal Mode Switcher Pill (Period Track vs Conception Mode)
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(cycleGoalModeProvider.notifier).toggleMode();
              final isTTC = goalMode == CycleGoalMode.trackCycle;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isTTC
                      ? '🌸 গর্ভধারণ পরিকল্পনা মোড চালু হয়েছে'
                      : '🩸 পিরিয়ড ট্র্যাকিং মোড চালু হয়েছে'),
                  backgroundColor: isTTC ? const Color(0xFF8B5CF6) : const Color(0xFFF43F5E),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: goalMode == CycleGoalMode.tryToConceive
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.12)
                    : const Color(0xFFF43F5E).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: goalMode == CycleGoalMode.tryToConceive
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                      : const Color(0xFFF43F5E).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    goalMode == CycleGoalMode.tryToConceive
                        ? PhosphorIconsFill.sparkle
                        : PhosphorIconsFill.drop,
                    size: 12,
                    color: goalMode == CycleGoalMode.tryToConceive
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFFF43F5E),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    goalMode == CycleGoalMode.tryToConceive ? 'গর্ভধারণ মোড' : 'পিরিয়ড মোড',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: goalMode == CycleGoalMode.tryToConceive
                          ? const Color(0xFF7C3AED)
                          : const Color(0xFFE11D48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: isBn ? 'সাইকেল সেটিংস' : 'Cycle Settings',
            icon: const Icon(PhosphorIconsRegular.gear, size: 21, color: Color(0xFF0F172A)),
            onPressed: () {
              AppFeedback.playLight();
              CycleSettingsSheet.show(context, cycle);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
        physics: const BouncingScrollPhysics(),
        children: [
          // ─── 1. Interactive Horizontal Calendar Date Reel ───
          HorizontalCycleDateStrip(cycle: cycle),

          // ─── 2. 1-Tap Quick Action Card: "আজ কি পিরিয়ড শুরু/শেষ হয়েছে?" ───
          QuickPeriodActionCard(cycle: cycle),

          // ─── 3. Main Flo-grade Radial Visualizer Card ───
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CycleVisualizerRing(
                  cycle: cycle,
                  selectedDate: selectedDate,
                  goalMode: goalMode,
                ),
                const SizedBox(height: 18),

                // Quick Forecast Pills
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFECDD3)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isBn ? 'পরবর্তী পিরিয়ড' : 'Next Period',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextPeriodFormatted,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF9F1239),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F3FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDDD6FE)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              isBn ? 'সম্ভাব্য ওভুলেশন' : 'Ovulation Window',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6D28D9),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nextOvulationFormatted,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF5B21B6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ─── 4. Interactive 28-Day Hormone Curve Chart (Signature Flo / Clue Feature) ───
          HormoneCurveChart(
            cycle: cycle,
            selectedDay: targetDay,
          ),

          const SizedBox(height: 18),

          // ─── 5. Daily Logged Symptoms & Mood Status Card ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade100),
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
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(PhosphorIconsFill.heart, size: 16, color: Color(0xFFF43F5E)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isSelectedToday
                              ? (isBn ? 'আজকের অনুভূতি ও লক্ষণ' : 'Today\'s Symptoms')
                              : '${WomenHealthFormatters.formatDayMonthBn(selectedDate)} এর লক্ষণ',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        AppFeedback.playLight();
                        SymptomLoggerSheet.show(
                          context,
                          initialLog: selectedLog,
                          targetDate: selectedDate,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedLog != null ? (isBn ? 'আপডেট' : 'Update') : (isBn ? '+ রেকর্ড' : '+ Log'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF43F5E),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (selectedLog != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildPill(selectedLog.mood.emoji, selectedLog.mood.labelBn, const Color(0xFF0F172A)),
                      if (selectedLog.flow != FlowLevel.none)
                        _buildPill(selectedLog.flow.emoji, selectedLog.flow.labelBn, const Color(0xFFF43F5E)),
                      if (selectedLog.cramp != CrampLevel.none)
                        _buildPill('⚡', selectedLog.cramp.labelBn, const Color(0xFF8B5CF6)),
                      ...selectedLog.physicalSymptoms.map((s) => _buildPill('🩺', s, const Color(0xFF0284C7))),
                    ],
                  ),
                ] else ...[
                  Text(
                    isSelectedToday
                        ? (isBn
                            ? 'আজকের কোনো লক্ষণ এখনও রেকর্ড করা হয়নি। আপনার শরীর কেমন অনুভব করছে তা রেকর্ড করুন।'
                            : 'No symptoms logged today. Record how your body feels.')
                        : '${WomenHealthFormatters.formatDayMonthBn(selectedDate)}-এর কোনো লক্ষণ রেকর্ড করা নেই।',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ─── 6. Flo-Style Daily Body, Skin & Energy Forecast Cards ───
          DailyBodyForecastSection(phase: targetPhase),

          const SizedBox(height: 18),

          // ─── 7. Phase-Specific Clinical Advice Card ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFF1F2),
                  const Color(0xFFFFE4E6).withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(PhosphorIconsFill.lightbulb, size: 20, color: Color(0xFFE11D48)),
                    const SizedBox(width: 8),
                    Text(
                      '${targetPhase.nameBn} - ${isBn ? 'স্বাস্থ্য পরামর্শ' : 'Care Tips'}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  targetPhase.adviceBn,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF881337),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
