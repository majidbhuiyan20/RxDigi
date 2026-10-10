import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class PregnancyDangerSignsCard extends StatelessWidget {
  const PregnancyDangerSignsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    final List<Map<String, String>> dangerSigns = [
      {
        'emoji': '🩸',
        'titleBn': 'যোনিপথে যেকোনো রক্তপাত',
        'titleEn': 'Any Vaginal Bleeding',
        'descBn': 'সামান্য রক্তক্ষরণও প্লাসেন্টার জটিলতা নির্দেশ করতে পারে।',
        'descEn': 'Even slight spotting may indicate placental complications.',
      },
      {
        'emoji': '⚡',
        'titleBn': 'তীব্র মাথাব্যথা ও ঝাপসা দৃষ্টি',
        'titleEn': 'Severe Headache / Blurred Vision',
        'descBn': 'উচ্চ রক্তচাপ ও প্রি-এক্লাম্পসিয়ার (Pre-eclampsia) প্রধান লক্ষণ।',
        'descEn': 'Key indicators of sudden dangerous gestational hypertension.',
      },
      {
        'emoji': '💧',
        'titleBn': 'সময়ের পূর্বেই পানি ভেঙে যাওয়া',
        'titleEn': 'Premature Leaking / Fluid Gush',
        'descBn': 'অ্যামনিওটিক তরল নির্গত হলে সংক্রমণ ও প্রসবের ঝুঁকি বাড়ে।',
        'descEn': 'Rupture of membranes requires immediate sterile care.',
      },
      {
        'emoji': '👣',
        'titleBn': 'বাচ্চার নড়াচড়া হঠাৎ কমে যাওয়া',
        'titleEn': 'Reduced Fetal Movements',
        'descBn': '২৮ সপ্তাহের পর ১২ ঘণ্টায় ১০টির কম নড়াচড়া হলে পরীক্ষা প্রয়োজন।',
        'descEn': 'Noticeable decrease in usual kicking patterns needs checkup.',
      },
      {
        'emoji': '🌡️',
        'titleBn': 'প্রচণ্ড জ্বর ও কাঁপুনি',
        'titleEn': 'High Fever with Chills',
        'descBn': 'সংক্রমণ বা ইউরিনারি ইনফেকশন দ্রুত চিকিৎসা না করলে ক্ষতিকর।',
        'descEn': 'Systemic infections require urgent clinical evaluation.',
      },
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFECDD3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFDC2626),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsFill.warning, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Text(
                isBn ? 'জরুরি গর্ভকালীন বিপদচিহ্ন (Danger Signs)' : 'Emergency Danger Signs to Watch For',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            isBn
                ? 'নিম্নলিখিত যেকোনো লক্ষণ দেখা দিলে কোনো প্রকার দ্বিধা না করে অবিলম্বে নিকটস্থ হাসপাতাল বা আপনার চিকিৎসকের শরণাপন্ন হোন:'
                : 'If you experience any of the following symptoms, contact your doctor or visit the hospital emergency without delay:',
            style: const TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Color(0xFF7F1D1D),
            ),
          ),

          const SizedBox(height: 12),

          ...dangerSigns.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['emoji']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? item['titleBn']! : item['titleEn']!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF450A0A),
                            ),
                          ),
                          Text(
                            isBn ? item['descBn']! : item['descEn']!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF991B1B),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

