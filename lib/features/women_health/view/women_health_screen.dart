import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/menstrual_cycle_model.dart';
import '../models/daily_symptom_log.dart';
import '../provider/women_health_provider.dart';
import '../widgets/cycle_visualizer_ring.dart';
import '../widgets/symptom_logger_sheet.dart';
import '../widgets/cycle_settings_sheet.dart';
import '../../../core/utils/app_feedback.dart';

class WomenHealthScreen extends ConsumerWidget {
  const WomenHealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final cycle = ref.watch(womenCycleProvider);
    final symptomsMap = ref.watch(dailySymptomProvider);
    final todayKey = getTodayKey();
    final todayLog = symptomsMap[todayKey];

    final nextPeriodFormatted = DateFormat('d MMMM').format(cycle.nextPeriodDate);
    final nextOvulationFormatted = DateFormat('d MMMM').format(cycle.nextOvulationDate);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF7F9), // Soft Blush Background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF43F5E).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                PhosphorIconsFill.flowerLotus,
                size: 18,
                color: Color(0xFFF43F5E),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              isBn ? 'উইমেন হেলথ ও সাইকেল' : 'Women Health & Cycle',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16.5,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        physics: const BouncingScrollPhysics(),
        children: [
          // ─── 1. Main Flo-grade Radial Visualizer Card ───
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF43F5E).withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                CycleVisualizerRing(cycle: cycle),
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

          // ─── 2. Daily Logged Symptoms & Mood Status Card ───
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
                            color: const Color(0xFFF43F5E).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(PhosphorIconsFill.sparkle, size: 16, color: Color(0xFFF43F5E)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBn ? 'আজকের অনুভূতি ও লক্ষণ' : 'Today\'s Symptoms',
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
                        SymptomLoggerSheet.show(context, initialLog: todayLog);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF43F5E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          todayLog != null ? (isBn ? 'আপডেট' : 'Update') : (isBn ? '+ রেকর্ড' : '+ Log'),
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
                if (todayLog != null) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildPill(todayLog.mood.emoji, todayLog.mood.labelBn, const Color(0xFF0F172A)),
                      if (todayLog.flow != FlowLevel.none)
                        _buildPill(todayLog.flow.emoji, todayLog.flow.labelBn, const Color(0xFFF43F5E)),
                      if (todayLog.cramp != CrampLevel.none)
                        _buildPill('⚡', todayLog.cramp.labelBn, const Color(0xFF8B5CF6)),
                      ...todayLog.physicalSymptoms.map((s) => _buildPill('🩺', s, const Color(0xFF0284C7))),
                    ],
                  ),
                ] else ...[
                  Text(
                    isBn
                        ? 'আজকের কোনো লক্ষণ এখনও রেকর্ড করা হয়নি। আপনার শরীর কেমন অনুভব করছে তা রেকর্ড করুন।'
                        : 'No symptoms logged today. Record how your body feels.',
                    style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ─── 3. Phase-Specific Clinical Advice Card ───
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFFF1F2),
                  const Color(0xFFFFE4E6).withOpacity(0.6),
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
                      '${cycle.currentPhase.nameBn} - ${isBn ? 'স্বাস্থ্য পরামর্শ' : 'Care Tips'}',
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
                  cycle.currentPhase.adviceBn,
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

          const SizedBox(height: 18),

          // ─── 4. 4-Phase Biological Guide Overview ───
          Text(
            isBn ? 'মাসিক চক্রের ৪টি প্রধান পর্যায়' : 'The 4 Cycle Phases',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          _buildPhaseOverviewCard(
            title: isBn ? '১. পিরিয়ড ফেজ (দিন ১ - ৫)' : '1. Menstrual Phase (Day 1 - 5)',
            desc: isBn ? 'জরায়ুর প্রাচীর ভাঙন ও রক্তক্ষরণ। আয়রনসমৃদ্ধ খাদ্য ও পর্যাপ্ত বিশ্রাম প্রয়োজন।' : 'Shedding of uterine lining. Hydration and iron-rich foods are critical.',
            color: const Color(0xFFF43F5E),
            isActive: cycle.currentPhase == CyclePhase.menstrual,
          ),
          const SizedBox(height: 8),
          _buildPhaseOverviewCard(
            title: isBn ? '২. ফলিকুলার ফেজ (দিন ৬ - ১১)' : '2. Follicular Phase (Day 6 - 11)',
            desc: isBn ? 'ডিম্বাণু পরিপক্ক হওয়ার সময়। শক্তি ও মেজাজ প্রফুল্ল থাকে।' : 'Egg matures in the follicle. High energy levels and positive mood.',
            color: const Color(0xFFEC4899),
            isActive: cycle.currentPhase == CyclePhase.follicular,
          ),
          const SizedBox(height: 8),
          _buildPhaseOverviewCard(
            title: isBn ? '৩. ওভুলেশন ফেজ (দিন ১২ - ১৬)' : '3. Ovulation Window (Day 12 - 16)',
            desc: isBn ? 'ডিম্বস্ফোটন ঘটে। এটি সন্তান ধারণের সবচেয়ে উর্বর ও অনুকূল সময়।' : 'Egg is released. Highest chance of conception and peak fertility.',
            color: const Color(0xFF8B5CF6),
            isActive: cycle.currentPhase == CyclePhase.fertileOvulation,
          ),
          const SizedBox(height: 8),
          _buildPhaseOverviewCard(
            title: isBn ? '৪. লুটিয়াল ফেজ (দিন ১৭ - ২৮)' : '4. Luteal Phase (Day 17 - 28)',
            desc: isBn ? 'প্রজেস্টেরন হরমোন বৃদ্ধি পায়। প্রি-মেনস্ট্রুয়াল সিন্ড্রোম (PMS) বা ক্লান্তি দেখা দিতে পারে।' : 'Progesterone peaks. PMS, food cravings, or fatigue might occur.',
            color: const Color(0xFFF59E0B),
            isActive: cycle.currentPhase == CyclePhase.luteal,
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String emoji, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
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

  Widget _buildPhaseOverviewCard({
    required String title,
    required String desc,
    required Color color,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive ? color : Colors.grey.shade200,
          width: isActive ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
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
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: isActive ? color : const Color(0xFF0F172A),
                      ),
                    ),
                    if (isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'বর্তমান পর্যায়',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
