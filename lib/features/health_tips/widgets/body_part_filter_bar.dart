import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../provider/health_tips_provider.dart';
import '../theme/tips_theme.dart';

class BodyPartFilterBar extends ConsumerWidget {
  const BodyPartFilterBar({super.key});

  static final List<Map<String, dynamic>> _bodyParts = [
    {
      'id': null,
      'label_bn': 'সব টিপস',
      'label_en': 'All Tips',
      'icon': PhosphorIconsFill.squaresFour,
    },
    {
      'id': 'stomach',
      'label_bn': 'পেট ও গ্যাস',
      'label_en': 'Stomach & Gas',
      'icon': PhosphorIconsFill.fire,
    },
    {
      'id': 'brain',
      'label_bn': 'মাথা ও ঘুম',
      'label_en': 'Brain & Sleep',
      'icon': PhosphorIconsFill.brain,
    },
    {
      'id': 'heart',
      'label_bn': 'হার্ট ও রক্তচাপ',
      'label_en': 'Heart & BP',
      'icon': PhosphorIconsFill.heartbeat,
    },
    {
      'id': 'pancreas',
      'label_bn': 'ডায়াবেটিস ও জীবনধারা',
      'label_en': 'Diabetes & Lifestyle',
      'icon': PhosphorIconsFill.scales,
    },
    {
      'id': 'bone',
      'label_bn': 'হাড় ও কোমর',
      'label_en': 'Bones & Spine',
      'icon': PhosphorIconsFill.personSimpleWalk,
    },
    {
      'id': 'kidney',
      'label_bn': 'কিডনি ও পানি',
      'label_en': 'Kidneys & Hydration',
      'icon': PhosphorIconsFill.dropHalfBottom,
    },
    {
      'id': 'skin',
      'label_bn': 'ত্বক ও রূপচর্চা',
      'label_en': 'Skin & Face',
      'icon': PhosphorIconsFill.drop,
    },
    {
      'id': 'hair',
      'label_bn': 'চুল ও স্ক্যাল্প',
      'label_en': 'Hair & Scalp',
      'icon': PhosphorIconsFill.sparkle,
    },
    {
      'id': 'eyes',
      'label_bn': 'চোখের যত্ন',
      'label_en': 'Eyes & Vision',
      'icon': PhosphorIconsFill.eye,
    },
    {
      'id': 'mouth',
      'label_bn': 'কান, নাক ও দাঁত',
      'label_en': 'ENT & Dental',
      'icon': PhosphorIconsFill.smiley,
    },
    {
      'id': 'women',
      'label_bn': 'নারী ও মাতৃত্ব',
      'label_en': 'Women & Maternal',
      'icon': PhosphorIconsFill.flowerLotus,
    },
    {
      'id': 'fitness',
      'label_bn': 'ব্যায়াম ও সঠিক ভঙ্গি',
      'label_en': 'Fitness & Posture',
      'icon': PhosphorIconsFill.personSimpleWalk,
    },
    {
      'id': 'hands_feet',
      'label_bn': 'হাত, পা ও নখ',
      'label_en': 'Hands & Feet',
      'icon': PhosphorIconsFill.footprints,
    },
    {
      'id': 'emergency',
      'label_bn': 'জরুরি ফার্স্ট এইড',
      'label_en': 'First Aid',
      'icon': PhosphorIconsFill.firstAid,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final selectedBodyPart = ref.watch(selectedBodyPartProvider);

    return SizedBox(
      height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _bodyParts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = _bodyParts[index];
              final String? id = item['id'];
              final String label = isBn ? item['label_bn'] : item['label_en'];
              final IconData icon = item['icon'];
              final isSelected = selectedBodyPart == id;
              final Color activeColor = id != null ? TipsTheme.getColor(id) : TipsTheme.primary;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(selectedBodyPartProvider.notifier).select(id);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor.withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? activeColor : Colors.transparent,
                      width: 1.4,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 13,
                        color: isSelected ? activeColor : const Color(0xFF64748B),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? activeColor : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
  }
}

