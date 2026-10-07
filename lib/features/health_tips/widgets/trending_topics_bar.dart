import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../provider/health_tips_provider.dart';

class TrendingTopicsBar extends ConsumerWidget {
  const TrendingTopicsBar({super.key});

  static final List<Map<String, dynamic>> _commonPainPoints = [
    {
      'id': 'stomach',
      'title_bn': 'গ্যাস্ট্রিক ও পেট ফাঁপা',
      'title_en': 'Gas & Acidity',
      'icon': PhosphorIconsFill.fire,
      'color': const Color(0xFFEA580C),
    },
    {
      'id': 'brain',
      'title_bn': 'ঘুম ও মাথাব্যথা',
      'title_en': 'Sleep & Headache',
      'icon': PhosphorIconsFill.moonStars,
      'color': const Color(0xFF4F46E5),
    },
    {
      'id': 'eyes',
      'title_bn': 'স্ক্রিনে চোখের ক্লান্তি',
      'title_en': 'Screen Strain',
      'icon': PhosphorIconsFill.eye,
      'color': const Color(0xFF0284C7),
    },
    {
      'id': 'hair',
      'title_bn': 'চুল পড়া ও খুশকি',
      'title_en': 'Hair Fall',
      'icon': PhosphorIconsFill.sparkle,
      'color': const Color(0xFF9333EA),
    },
    {
      'id': 'heart',
      'title_bn': 'রক্তচাপ ও কোলেস্টেরল',
      'title_en': 'High BP & Heart',
      'icon': PhosphorIconsFill.heartbeat,
      'color': const Color(0xFFDC2626),
    },
    {
      'id': 'bones',
      'title_bn': 'কোমর ও ঘাড় ব্যথা',
      'title_en': 'Back & Neck Pain',
      'icon': PhosphorIconsFill.personSimpleWalk,
      'color': const Color(0xFF475569),
    },
    {
      'id': 'emergency',
      'title_bn': 'জরুরি ফার্স্ট এইড',
      'title_en': 'First Aid',
      'icon': PhosphorIconsFill.firstAid,
      'color': const Color(0xFFB91C1C),
    },
    {
      'id': 'lifestyle',
      'title_bn': 'ব্লাড সুগার ও ওজন',
      'title_en': 'Blood Sugar & Diet',
      'icon': PhosphorIconsFill.scales,
      'color': const Color(0xFF059669),
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final selectedBodyPart = ref.watch(selectedBodyPartProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Icon(
                PhosphorIconsFill.flame,
                size: 16,
                color: Color(0xFFEA580C),
              ),
              const SizedBox(width: 6),
              Text(
                isBn ? 'সবচেয়ে সাধারণ সমস্যাগুলো' : 'Most Common Health Concerns',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _commonPainPoints.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _commonPainPoints[index];
              final String id = item['id'];
              final String title = isBn ? item['title_bn'] : item['title_en'];
              final IconData icon = item['icon'];
              final Color color = item['color'];
              final isSelected = selectedBodyPart == id;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  if (isSelected) {
                    ref.read(selectedBodyPartProvider.notifier).select(null);
                  } else {
                    ref.read(selectedBodyPartProvider.notifier).select(id);
                    ref.read(selectedTipCategoryProvider.notifier).select(null);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? color : const Color(0xFFE2E8F0),
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected ? color.withValues(alpha: 0.25) : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isSelected ? Colors.white : color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
