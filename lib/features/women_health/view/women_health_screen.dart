import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../l10n/local_provider.dart';
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
import '../widgets/doctor_cycle_report_sheet.dart';
import '../widgets/past_cycle_history_sheet.dart';
import '../widgets/pcos_diet_guidance_card.dart';
import '../widgets/women_care_supplements_card.dart';
import '../widgets/pregnancy_dashboard_view.dart';
import '../widgets/pregnancy_setup_sheet.dart';
import '../widgets/fetal_kick_counter_sheet.dart';
import '../services/pregnancy_notification_service.dart';
import '../provider/pregnancy_provider.dart';

class WomenHealthScreen extends ConsumerWidget {
  const WomenHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final isBn = currentLocale.languageCode == 'bn';

    final cycle = ref.watch(womenCycleProvider);
    final selectedDate = ref.watch(selectedCycleDateProvider);
    final goalMode = ref.watch(cycleGoalModeProvider);
    final symptomsMap = ref.watch(dailySymptomProvider);

    final selectedDateKey = WomenHealthFormatters.toDateKey(selectedDate);
    final selectedLog = symptomsMap[selectedDateKey];

    final isSelectedToday = WomenHealthFormatters.isSameDay(selectedDate, DateTime.now());
    final targetPhase = cycle.getPhaseFor(selectedDate);
    final targetDay = cycle.getCycleDayFor(selectedDate);

    final nextPeriodFormatted = cycle.isConfigured
        ? WomenHealthFormatters.formatDayMonth(cycle.nextPeriodDate, isBn: isBn)
        : (isBn ? 'সেট করুন' : 'Not Set');
    final nextOvulationFormatted = cycle.isConfigured
        ? WomenHealthFormatters.formatDayMonth(cycle.nextOvulationDate, isBn: isBn)
        : (isBn ? 'সেট করুন' : 'Not Set');

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9), // Soft Blush Background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'উইমেন হেলথ ও সাইকেল' : 'Women Health & Cycle',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16.5,
            color: Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          // ─── Direct Language Switcher Toggle Pill [ 文A EN / বাং ] ───
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              final nextLang = isBn ? 'en' : 'bn';
              ref.read(localeProvider.notifier).setLocale(Locale(nextLang));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.translate, size: 12, color: Color(0xFF0F172A)),
                  const SizedBox(width: 3),
                  Text(
                    isBn ? 'EN' : 'বাং',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),

          // ─── Doctor Clinical Summary PDF Action ───
          IconButton(
            tooltip: isBn ? 'ডাক্তারের রিপোর্ট (PDF)' : 'Doctor Report (PDF)',
            icon: const Icon(PhosphorIconsRegular.filePdf, size: 21, color: Color(0xFFBE123C)),
            onPressed: () {
              AppFeedback.playLight();
              DoctorCycleReportSheet.show(context, cycle);
            },
          ),

          // ─── More Options Menu (History & Settings) ───
          PopupMenuButton<String>(
            icon: const Icon(PhosphorIconsRegular.dotsThreeVertical, size: 20, color: Color(0xFF0F172A)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              AppFeedback.playLight();
              if (val == 'history') {
                PastCycleHistorySheet.show(context, cycle);
              } else if (val == 'settings') {
                CycleSettingsSheet.show(context, cycle);
              } else if (val == 'pregnancy_settings') {
                PregnancySetupSheet.show(context);
              } else if (val == 'kick_counter') {
                FetalKickCounterSheet.show(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'history',
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.clockCounterClockwise, size: 18, color: Color(0xFF0F172A)),
                    const SizedBox(width: 10),
                    Text(
                      isBn ? 'সাইকেল হিস্ট্রি' : 'Cycle History',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.gear, size: 18, color: Color(0xFF0F172A)),
                    const SizedBox(width: 10),
                    Text(
                      isBn ? 'সাইকেল সেটিংস' : 'Cycle Settings',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'pregnancy_settings',
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.baby, size: 18, color: Color(0xFFE11D48)),
                    const SizedBox(width: 10),
                    Text(
                      isBn ? 'গর্ভাবস্থা ও ডিউ ডেট' : 'Pregnancy Settings',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'kick_counter',
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.footprints, size: 18, color: Color(0xFFE11D48)),
                    const SizedBox(width: 10),
                    Text(
                      isBn ? 'ফিটাল কিক কাউন্টার' : 'Kick Counter',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
        physics: const BouncingScrollPhysics(),
        children: [
          // ─── Top 3-Mode Selector Strip & History Chip ───
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Period Tracking Mode
                _buildModeChip(
                  label: isBn ? '🩸 পিরিয়ড ট্র্যাকিং' : '🩸 Period Track',
                  isSelected: goalMode == CycleGoalMode.trackCycle,
                  activeBg: const Color(0xFFF43F5E),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(cycleGoalModeProvider.notifier).setMode(CycleGoalMode.trackCycle);
                  },
                ),
                const SizedBox(width: 8),

                // 2. TTC Conception Mode
                _buildModeChip(
                  label: isBn ? '🌸 গর্ভধারণ পরিকল্পনা' : '🌸 Conception',
                  isSelected: goalMode == CycleGoalMode.tryToConceive,
                  activeBg: const Color(0xFF8B5CF6),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(cycleGoalModeProvider.notifier).setMode(CycleGoalMode.tryToConceive);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isBn ? '🌸 গর্ভধারণ পরিকল্পনা মোড চালু হয়েছে' : '🌸 TTC Conception Mode Activated'),
                        backgroundColor: const Color(0xFF8B5CF6),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // 3. Pregnancy Mode (NEW)
                _buildModeChip(
                  label: isBn ? '🤰 গর্ভাবস্থা মোড' : '🤰 Pregnancy',
                  isSelected: goalMode == CycleGoalMode.pregnancy,
                  activeBg: const Color(0xFFE11D48),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(cycleGoalModeProvider.notifier).setMode(CycleGoalMode.pregnancy);
                    final preg = ref.read(pregnancyProvider);
                    if (!preg.isConfigured) {
                      PregnancySetupSheet.show(context);
                    } else {
                      PregnancyNotificationService.scheduleDailyNotification(
                        model: preg,
                        isBn: isBn,
                      );
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isBn ? '🤰 গর্ভাবস্থা ও মাতৃত্ব ট্র্যাকার চালু হয়েছে' : '🤰 Pregnancy Mode Activated'),
                        backgroundColor: const Color(0xFFE11D48),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),

                // Quick History Shortcut Chip
                InkWell(
                  onTap: () {
                    AppFeedback.playLight();
                    PastCycleHistorySheet.show(context, cycle);
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIconsRegular.clockCounterClockwise, size: 13, color: Color(0xFF475569)),
                        const SizedBox(width: 4),
                        Text(
                          isBn ? 'হিস্ট্রি' : 'History',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Conditional View Based on Selected Mode ───
          if (goalMode == CycleGoalMode.pregnancy) ...[
            PregnancyDashboardView(cycle: cycle),
          ] else ...[
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
                      child: GestureDetector(
                        onTap: () {
                          if (!cycle.isConfigured) {
                            AppFeedback.playLight();
                            CycleSettingsSheet.show(context, cycle);
                          }
                        },
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
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!cycle.isConfigured) {
                            AppFeedback.playLight();
                            CycleSettingsSheet.show(context, cycle);
                          }
                        },
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

          // ─── 5. Clinical PCOS & Irregular Cycle Guidance + Bangladeshi Diet Card ───
          PcosDietGuidanceCard(cycle: cycle),

          // ─── 6. Women's Care & Supplements (Birth Control OCP & Iron Routine) ───
          WomenCareSupplementsCard(cycle: cycle),

          // ─── 7. Daily Logged Symptoms & Mood Status Card ───
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
                              : '${WomenHealthFormatters.formatDayMonth(selectedDate, isBn: isBn)} ${isBn ? "এর লক্ষণ" : "Symptoms"}',
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
                      _buildPill(selectedLog.mood.emoji, selectedLog.mood.label(isBn), const Color(0xFF0F172A)),
                      if (selectedLog.flow != FlowLevel.none)
                        _buildPill(selectedLog.flow.emoji, selectedLog.flow.label(isBn), const Color(0xFFF43F5E)),
                      if (selectedLog.cramp != CrampLevel.none)
                        _buildPill('⚡', selectedLog.cramp.label(isBn), const Color(0xFF8B5CF6)),
                      ...selectedLog.physicalSymptoms.map((s) =>
                          _buildPill('🩺', SymptomCatalog.getLabel(s, isBn), const Color(0xFF0284C7))),
                    ],
                  ),
                ] else ...[
                  Text(
                    isSelectedToday
                        ? (isBn
                            ? 'আজকের কোনো লক্ষণ এখনও রেকর্ড করা হয়নি। আপনার শরীর কেমন অনুভব করছে তা রেকর্ড করুন।'
                            : 'No symptoms logged today. Record how your body feels.')
                        : (isBn
                            ? '${WomenHealthFormatters.formatDayMonth(selectedDate, isBn: true)}-এর কোনো লক্ষণ রেকর্ড করা নেই।'
                            : 'No symptoms logged for ${WomenHealthFormatters.formatDayMonth(selectedDate, isBn: false)}.'),
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ─── 8. Flo-Style Daily Body, Skin & Energy Forecast Cards ───
          if (cycle.isConfigured) ...[
            DailyBodyForecastSection(phase: targetPhase),
            const SizedBox(height: 18),

            // ─── 9. Phase-Specific Clinical Advice Card ───
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
                        '${targetPhase.name(isBn)} - ${isBn ? 'স্বাস্থ্য পরামর্শ' : 'Care Tips'}',
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
                    targetPhase.advice(isBn),
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
          ] else ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFFECDD3)),
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
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(PhosphorIconsFill.sparkle, size: 20, color: Color(0xFFE11D48)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn ? 'ব্যক্তিগত পরামর্শ পেতে সাইকেল সেট করুন' : 'Unlock Daily Body Insights',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9F1239),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isBn
                        ? 'আপনার শেষ পিরিয়ডের তারিখ দিলে আপনার হরমোন চক্র অনুযায়ী প্রতিদিনের কর্মশক্তি, ত্বকের যত্ন ও পুষ্টি সম্পর্কিত সঠিক পূর্বাভাস ও পরামর্শ দেখতে পাবেন।'
                        : 'Set up your last period date to receive daily personalized guidance on physical stamina, skincare, and nutrition for each hormonal phase.',
                    style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.45,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () {
                      AppFeedback.playLight();
                      CycleSettingsSheet.show(context, cycle);
                    },
                    icon: const Icon(PhosphorIconsRegular.calendarPlus, size: 16),
                    label: Text(
                      isBn ? 'মাসিক চক্র সেটআপ করুন' : 'Set Up Cycle Now',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE11D48),
                      side: const BorderSide(color: Color(0xFFFECDD3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),
          ],
          ],
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required bool isSelected,
    required Color activeBg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeBg : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeBg.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
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

