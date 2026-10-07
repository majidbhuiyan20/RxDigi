import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../vitals/provider/vitals_provider.dart';
import '../../vitals/view/vitals_screen.dart';
import '../../vitals/view/add_vital_sheet.dart';

class HomeVitalsCard extends ConsumerWidget {
  const HomeVitalsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final latestBp = ref.watch(latestBpProvider);
    final latestSugar = ref.watch(latestSugarProvider);
    final latestWeight = ref.watch(latestWeightProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.heartStraight,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'স্বাস্থ্য পরিমাপক (Vitals)' : 'My Health Vitals',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () => AddVitalSheet.show(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsBold.plus, size: 14, color: Color(0xFFEF4444)),
                      const SizedBox(width: 4),
                      Text(
                        isBn ? 'লগ করুন' : 'Log Vital',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3 Vitals Cards in a Row
          Row(
            children: [
              _buildVitalCard(
                title: isBn ? 'রক্তচাপ (BP)' : 'Blood Pressure',
                icon: PhosphorIconsRegular.heartbeat,
                color: const Color(0xFFEF4444),
                value: latestBp?.displayValue ?? '--/--',
                unit: 'mmHg',
                category: latestBp?.category ?? (isBn ? 'লগ নেই' : 'No log'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VitalsScreen())),
              ),
              const SizedBox(width: 10),
              _buildVitalCard(
                title: isBn ? 'সুগার (Sugar)' : 'Blood Sugar',
                icon: PhosphorIconsRegular.drop,
                color: const Color(0xFFF59E0B),
                value: latestSugar?.displayValue ?? '--',
                unit: 'mmol/L',
                category: latestSugar?.category ?? (isBn ? 'লগ নেই' : 'No log'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VitalsScreen())),
              ),
              const SizedBox(width: 10),
              _buildVitalCard(
                title: isBn ? 'ওজন (Weight)' : 'Weight',
                icon: PhosphorIconsRegular.scales,
                color: const Color(0xFF0D9488),
                value: latestWeight?.displayValue ?? '--',
                unit: 'kg',
                category: latestWeight?.category ?? (isBn ? 'লগ নেই' : 'No log'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VitalsScreen())),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const VitalsScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isBn ? 'সকল হিস্টোরি ও গ্রাফ দেখুন' : 'View History & Charts',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D9488),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      PhosphorIconsBold.arrowRight,
                      size: 13,
                      color: Color(0xFF0D9488),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalCard({
    required String title,
    required IconData icon,
    required Color color,
    required String value,
    required String unit,
    required String category,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.18), width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (value != '--' && value != '--/--') ...[
                      const SizedBox(width: 2),
                      Text(
                        unit,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
