import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/pregnancy_model.dart';
import '../utils/women_health_formatters.dart';
import 'pregnancy_setup_sheet.dart';

class PregnancyHeroCard extends StatelessWidget {
  final PregnancyModel pregnancy;

  const PregnancyHeroCard({
    super.key,
    required this.pregnancy,
  });

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final weekInfo = PregnancyWeekCatalog.getWeekInfo(pregnancy.currentWeek);
    final eddStr = WomenHealthFormatters.formatDayMonth(pregnancy.estimatedDueDate, isBn: isBn);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          // Top Header: Nickname, Trimester Badge & Edit Button
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 14, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE11D48),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(PhosphorIconsFill.baby, color: Colors.white, size: 15),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '🌸 ${pregnancy.babyNickname}${isBn ? "র গর্ভাবস্থা" : "'s Journey"}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9F1239),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Text(
                        pregnancy.currentTrimester.shortName(isBn),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBE123C),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(PhosphorIconsRegular.gear, size: 18, color: Color(0xFF9F1239)),
                      onPressed: () {
                        AppFeedback.playLight();
                        PregnancySetupSheet.show(context);
                      },
                      tooltip: isBn ? 'ডিউ ডেট ও সেটিংস' : 'Due Date Settings',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Main Big Gestational Age Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBn
                          ? '${WomenHealthFormatters.formatDigits(pregnancy.currentWeek, isBn: true)} সপ্তাহ ${WomenHealthFormatters.formatDigits(pregnancy.currentDayOfWeek, isBn: true)} দিন'
                          : 'Week ${pregnancy.currentWeek}, Day ${pregnancy.currentDayOfWeek}',
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pregnancy.currentTrimester.name(isBn),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),

                // Large Emoji Fruit Representation
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFECDD3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      weekInfo.fruitEmoji,
                      style: const TextStyle(fontSize: 34),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Fruit Comparison Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFCE7F3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(PhosphorIconsRegular.ruler, size: 16, color: Color(0xFFBE123C)),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'সোনামণি এখন আকারের দিক থেকে:' : 'Baby is currently the size of:',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                        ),
                        Text(
                          isBn ? weekInfo.fruitNameBn : weekInfo.fruitNameEn,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '~${WomenHealthFormatters.formatDigits(weekInfo.lengthCm, isBn: isBn)} ${isBn ? "সেমি" : "cm"}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                    Text(
                      '~${WomenHealthFormatters.formatDigits(weekInfo.weightGrams.toInt(), isBn: isBn)} ${isBn ? "গ্রাম" : "g"}',
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Progress Bar (Total 40 weeks)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${WomenHealthFormatters.formatDigits(pregnancy.progressPercent, isBn: isBn)}% ${isBn ? "পথ সম্পন্ন" : "complete"}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFBE123C),
                      ),
                    ),
                    Text(
                      '${isBn ? "আর মাত্র " : ""}${WomenHealthFormatters.formatDigits(pregnancy.daysRemaining, isBn: isBn)} ${isBn ? "দিন বাকি" : "days left"}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pregnancy.progressFraction,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE11D48)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Bottom EDD Pill Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(PhosphorIconsRegular.calendarHeart, size: 15, color: Color(0xFF9F1239)),
                const SizedBox(width: 6),
                Text(
                  '${isBn ? "সম্ভাব্য প্রসবের তারিখ (EDD): " : "Estimated Due Date: "}$eddStr',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9F1239),
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
