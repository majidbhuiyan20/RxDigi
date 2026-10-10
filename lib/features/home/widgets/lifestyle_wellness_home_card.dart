import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../diet_nutrition/view/diet_nutrition_screen.dart';
import '../../women_health/view/women_health_screen.dart';
import '../../../core/utils/app_feedback.dart';

class LifestyleWellnessHomeCard extends StatelessWidget {
  const LifestyleWellnessHomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBn ? 'লাইফস্টাইল ও সুস্থতা' : 'Lifestyle & Wellness',
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Dual Grid Cards Row
        Row(
          children: [
            // ─── 1. Bangladeshi Diet & GI Guide ───
            Expanded(
              child: _buildLifestyleTile(
                context: context,
                title: isBn ? 'দেশীয় খাবার ও ডায়াবেটিস' : 'Bangladeshi Diet & GI',
                subtitle: isBn ? 'ক্যালোরি ও লো-GI গাইড' : 'Calorie & GI Index',
                badgeText: isBn ? '৬০০+ খাবার' : '600+ Foods',
                emoji: '🍛',
                gradientColors: const [
                  Color(0xFFECFDF5),
                  Color(0xFFD1FAE5),
                ],
                borderColor: const Color(0xFFA7F3D0),
                accentColor: const Color(0xFF059669),
                onTap: () {
                  AppFeedback.playLight();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DietNutritionScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // ─── 2. Women Health & Period Tracker ───
            Expanded(
              child: _buildLifestyleTile(
                context: context,
                title: isBn ? 'উইমেন হেলথ ও সাইকেল' : 'Women Health & Cycle',
                subtitle: isBn ? 'পিরিয়ড ও ওভুলেশন' : 'Period & Ovulation',
                badgeText: isBn ? 'সাইকেল' : 'Cycle Log',
                emoji: '🌸',
                gradientColors: const [
                  Color(0xFFFFF1F2),
                  Color(0xFFFFE4E6),
                ],
                borderColor: const Color(0xFFFECDD3),
                accentColor: const Color(0xFFE11D48),
                onTap: () {
                  AppFeedback.playLight();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const WomenHealthScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLifestyleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badgeText,
    required String emoji,
    required List<Color> gradientColors,
    required Color borderColor,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

