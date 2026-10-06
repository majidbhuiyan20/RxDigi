import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
                      color: const Color(0xFFE53935).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Color(0xFFE53935), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'স্বাস্থ্য পরিমাপক (My Vitals)' : 'My Health Vitals',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              InkWell(
                onTap: () => AddVitalSheet.show(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add, size: 16, color: Color(0xFFE53935)),
                      const SizedBox(width: 4),
                      Text(
                        isBn ? 'পরিমাপ করুন' : 'Log Vital',
                        style: const TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Vitals Cards in a Row
          Row(
            children: [
              _buildVitalCard(
                title: isBn ? 'রক্তচাপ (BP)' : 'Blood Pressure',
                icon: Icons.speed_rounded,
                color: const Color(0xFFE53935),
                value: latestBp?.displayValue ?? '--/--',
                unit: 'mmHg',
                category: latestBp?.category ?? (isBn ? 'লগ নেই' : 'No log'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VitalsScreen())),
              ),
              const SizedBox(width: 10),
              _buildVitalCard(
                title: isBn ? 'সুগার (Sugar)' : 'Blood Sugar',
                icon: Icons.water_drop_rounded,
                color: const Color(0xFFFB8C00),
                value: latestSugar?.displayValue ?? '--',
                unit: 'mmol/L',
                category: latestSugar?.category ?? (isBn ? 'লগ নেই' : 'No log'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VitalsScreen())),
              ),
              const SizedBox(width: 10),
              _buildVitalCard(
                title: isBn ? 'ওজন (Weight)' : 'Weight',
                icon: Icons.monitor_weight_outlined,
                color: const Color(0xFF00897B),
                value: latestWeight?.displayValue ?? '--',
                unit: 'kg',
                category: latestWeight?.category ?? (isBn ? 'লগ নেই' : 'No log'),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VitalsScreen())),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (c) => const VitalsScreen()),
              ),
              child: Text(
                isBn ? 'সকল হিস্টোরি ও গ্রাফ দেখুন →' : 'View History & Charts →',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF00897B)),
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                unit,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
