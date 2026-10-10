import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/pregnancy_provider.dart';
import 'pregnancy_hero_card.dart';
import 'pregnancy_week_detail_card.dart';
import 'fetal_kick_counter_sheet.dart';
import 'anc_visits_card.dart';
import 'pregnancy_danger_signs_card.dart';
import 'pregnancy_notification_card.dart';
import 'women_care_supplements_card.dart';
import 'pregnancy_setup_sheet.dart';

class PregnancyDashboardView extends ConsumerWidget {
  final MenstrualCycleModel cycle;

  const PregnancyDashboardView({
    super.key,
    required this.cycle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final pregnancy = ref.watch(pregnancyProvider);

    // If pregnancy is not configured yet by the user, show welcoming setup card
    if (!pregnancy.isConfigured) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUnconfiguredWelcomeCard(context, isBn),

          // Daily Supplements (Iron & Folic Acid Routine)
          WomenCareSupplementsCard(cycle: cycle),

          // ANC Doctor Visits & Ultrasound Checklist
          const AncVisitsCard(),

          // Emergency Obstetric Danger Signs
          const PregnancyDangerSignsCard(),
        ],
      );
    }

    final isKickCounterRecommended = pregnancy.currentWeek >= 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── 1. Pregnancy Hero Card ───
        PregnancyHeroCard(pregnancy: pregnancy),

        // ─── 2. Notification Status & Instant Test Trigger ───
        PregnancyNotificationCard(pregnancy: pregnancy),

        // ─── 3. Interactive Week-by-Week Fetal & Maternal Guide ───
        PregnancyWeekDetailCard(pregnancy: pregnancy),

        // ─── 4. Fetal Kick Counter Shortcut Card ───
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isKickCounterRecommended
                  ? const Color(0xFFFECDD3)
                  : Colors.grey.shade100,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF43F5E).withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  PhosphorIconsFill.footprints,
                  size: 24,
                  color: Color(0xFFE11D48),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isBn ? 'ফিটাল কিক কাউন্টার' : 'Fetal Kick Counter',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        if (isKickCounterRecommended) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE11D48)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isBn ? 'প্রয়োজনীয়' : 'Active',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBE123C),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isBn
                          ? 'শিশুর নড়াচড়া ও লাথি গুনে সুস্থতা ট্র্যাক করুন।'
                          : 'Count 10 movements to monitor baby wellbeing.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  AppFeedback.playLight();
                  FetalKickCounterSheet.show(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE11D48),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(
                  isBn ? 'কাউন্ট করুন' : 'Count',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),

        // ─── 5. Daily Supplements (Iron & Folic Acid Routine) ───
        WomenCareSupplementsCard(cycle: cycle),

        // ─── 6. ANC Doctor Visits & Ultrasound Checklist ───
        const AncVisitsCard(),

        // ─── 7. Emergency Obstetric Danger Signs ───
        const PregnancyDangerSignsCard(),
      ],
    );
  }

  Widget _buildUnconfiguredWelcomeCard(BuildContext context, bool isBn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF1F2), // Rose-50
            Color(0xFFFDF4FF), // Fuchsia-50
            Color(0xFFFAF5FF), // Purple-50
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFECDD3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E).withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsFill.baby, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn ? 'মাতৃত্বকালীন যাত্রায় স্বাগতম 🌸' : 'Welcome to Motherhood 🌸',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBn ? 'সঠিক হিসাব পেতে তথ্য সেটআপ করুন' : 'Set up details for personalized tracking',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isBn
                ? 'আপনার শেষ মাসিকের ১ম দিন (LMP) অথবা আল্ট্রাসাউন্ড অনুযায়ী ডেলিভারির সম্ভাব্য তারিখ (EDD) দিন। RxDigi আপনাকে প্রতি সপ্তাহের বিকাশ, পুষ্টি ও চেকআপ সম্পর্কে তথ্য দেবে।'
                : 'Enter your Last Menstrual Period (LMP) or ultrasound Due Date (EDD) to receive accurate weekly fetal development updates and prenatal care advice.',
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                AppFeedback.playLight();
                PregnancySetupSheet.show(context);
              },
              icon: const Icon(PhosphorIconsBold.sparkle, size: 18, color: Colors.white),
              label: Text(
                isBn ? 'গর্ভাবস্থার তথ্য সেটআপ করুন' : 'Set Up Pregnancy Details',
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

