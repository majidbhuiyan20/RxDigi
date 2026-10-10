import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../../diet_nutrition/view/diet_nutrition_screen.dart';
import '../models/menstrual_cycle_model.dart';
import 'doctor_cycle_report_sheet.dart';

class PcosDietGuidanceCard extends ConsumerWidget {
  final MenstrualCycleModel cycle;

  const PcosDietGuidanceCard({
    super.key,
    required this.cycle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final isIrregular = cycle.isIrregularCycle;

    final List<Map<String, String>> pcosFoods = [
      {
        'emoji': '🍵',
        'nameBn': 'মেথি ভেজানো পানি / চা',
        'nameEn': 'Fenugreek Seed Water',
        'benefitBn': 'ইনসুলিন সেনসিটিভিটি বাড়ায় ও ওভারিয়ান হরমোন নিয়ন্ত্রণে সাহায্য করে।',
        'benefitEn': 'Improves insulin sensitivity and balances ovarian hormones.',
        'gi': 'Low GI (15)',
      },
      {
        'emoji': '☕',
        'nameBn': 'দারুচিনি চা',
        'nameEn': 'Cinnamon Infusion',
        'benefitBn': 'ডিম্বাশয়ের কার্যক্ষমতা বৃদ্ধি ও মাসিক নিয়মিত করতে সহায়ক।',
        'benefitEn': 'Clinically studied for regulating menstrual regularity.',
        'gi': 'Low GI (10)',
      },
      {
        'emoji': '🥣',
        'nameBn': 'ঘরের টক দই',
        'nameEn': 'Natural Curd / Yogurt',
        'benefitBn': 'প্রোবায়োটিক গাট ব্যাক্টেরিয়া উন্নত করে এবং হরমোন ডিটক্স করে।',
        'benefitEn': 'Probiotics promote healthy estrogen metabolism.',
        'gi': 'Low GI (28)',
      },
      {
        'emoji': '🥬',
        'nameBn': 'পালং ও লাল শাক',
        'nameEn': 'Spinach & Amaranth',
        'benefitBn': 'আয়রন ও ম্যাগনেসিয়াম সমৃদ্ধ—ক্র্যাম্প ও রক্তস্বল্পতা প্রতিরোধ করে।',
        'benefitEn': 'High iron & magnesium reduce cramping and fatigue.',
        'gi': 'Low GI (15)',
      },
      {
        'emoji': '🌰',
        'nameBn': 'চিয়া সিডস ও তিসি',
        'nameEn': 'Chia & Flax Seeds',
        'benefitBn': 'ওমেগা-৩ ও লিগনান উপাদান ওভারিয়ান সিস্টের প্রদাহ কমায়।',
        'benefitEn': 'Omega-3 and lignans reduce systemic inflammation.',
        'gi': 'Low GI (20)',
      },
      {
        'emoji': '🍐',
        'nameBn': 'দেশি পেয়ারা ও আমলকী',
        'nameEn': 'Guava & Amla',
        'benefitBn': 'উচ্চ ভিটামিন সি ও অ্যান্টিঅক্সিডেন্ট শরীরে আয়রন শোষণে সহায়তা করে।',
        'benefitEn': 'High vitamin C enhances cellular iron absorption.',
        'gi': 'Low GI (25)',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isIrregular ? const Color(0xFFFECDD3) : Colors.grey.shade100,
          width: isIrregular ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isIrregular ? const Color(0xFFF43F5E) : Colors.grey).withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Warning Badge if irregular
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isIrregular
                          ? const Color(0xFFF43F5E).withValues(alpha: 0.12)
                          : const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isIrregular ? PhosphorIconsFill.warningCircle : PhosphorIconsFill.leaf,
                      size: 18,
                      color: isIrregular ? const Color(0xFFE11D48) : const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isIrregular
                        ? (isBn ? 'PCOS ও অনিয়মিত সাইকেল গাইডেন্স' : 'PCOS & Irregular Cycle Guide')
                        : (isBn ? 'হরমোনাল ব্যালেন্স ও ডায়েট গাইড' : 'Hormonal Balance & Diet Guide'),
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
                  color: isIrregular
                      ? const Color(0xFFFFF1F2)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isIrregular
                        ? const Color(0xFFFECDD3)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: Text(
                  isIrregular
                      ? (isBn ? 'সতর্কতা' : 'Flagged')
                      : (isBn ? 'টিপস' : 'Nutrition'),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isIrregular
                        ? const Color(0xFFBE123C)
                        : const Color(0xFF047857),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Clinical explanation text
          Text(
            isIrregular
                ? (isBn
                    ? 'আপনার বর্তমান সাইকেল ${cycle.cycleLength} দিন (স্বাভাবিক ২১-৩৫ দিন)। সাইকেল দীর্ঘমেয়াদী বা অনিয়মিত হলে ইনসুলিন রেজিস্ট্যান্স ও হরমোনাল ভারসাম্য রক্ষার জন্য লো-গ্লাইসেমিক ইনডেক্স ও আঁশযুক্ত খাবার গ্রহণ অত্যন্ত ফলপ্রসূ।'
                    : 'Your cycle length is ${cycle.cycleLength} days (normal 21-35 days). When cycles vary or are delayed, low-GI foods and anti-inflammatory nutrition help restore ovulatory health.')
                : (isBn
                    ? 'সুস্থ ও ব্যালেন্সড সাইকেলের জন্য প্রতিদিন পর্যাপ্ত অ্যান্টিঅক্সিডেন্ট ও স্বাস্থ্যকর ফ্যাটযুক্ত খাবার নিশ্চিত করুন।'
                    : 'To maintain hormonal vitality throughout your cycle, include low-glycemic foods, clean proteins, and healthy fats.'),
            style: TextStyle(
              fontSize: 12.5,
              height: 1.45,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 14),

          // Horizontal scroll of curated foods
          Text(
            isBn ? 'প্রস্তাবিত দেশি পুষ্টিকর খাবার (Low GI):' : 'Recommended Foods for Hormonal Balance:',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),

          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: pcosFoods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = pcosFoods[index];
                return Container(
                  width: 200,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(item['emoji']!, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              SizedBox(
                                width: 105,
                                child: Text(
                                  isBn ? item['nameBn']! : item['nameEn']!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['gi']!,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        isBn ? item['benefitBn']! : item['benefitEn']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.3,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Action row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppFeedback.playLight();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DietNutritionScreen()),
                    );
                  },
                  icon: const Icon(PhosphorIconsRegular.forkKnife, size: 15),
                  label: Text(
                    isBn ? 'ডায়েট ডাটাবেজ দেখুন' : 'Explore Diet Library',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppFeedback.playLight();
                    DoctorCycleReportSheet.show(context, cycle);
                  },
                  icon: const Icon(PhosphorIconsRegular.fileText, size: 15),
                  label: Text(
                    isBn ? 'ডাক্তারের রিপোর্ট' : 'Doctor Report',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE123C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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

