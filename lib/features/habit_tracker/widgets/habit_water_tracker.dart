import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HabitWaterTracker extends StatelessWidget {
  final int glasses;
  final ValueChanged<int> onChanged;
  final bool isBn;

  const HabitWaterTracker({
    super.key,
    required this.glasses,
    required this.onChanged,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    final percent = ((glasses / 8) * 100).toInt().clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F9FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0284C7).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(PhosphorIconsFill.drop, color: Color(0xFF0284C7), size: 18),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'দৈনিক পানি পানের লক্ষ্য' : 'Daily Water Hydration',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isBn ? 'লক্ষ্যমাত্রা: ৮ গ্লাস (২.০ লিটার)' : 'Target: 8 glasses (2.0 L)',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
              // Stepper
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (glasses > 0) {
                          HapticFeedback.lightImpact();
                          onChanged(glasses - 1);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(PhosphorIconsBold.minus, size: 13, color: Color(0xFF0284C7)),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        '$glasses/8',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        if (glasses < 8) {
                          HapticFeedback.lightImpact();
                          onChanged(glasses + 1);
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(PhosphorIconsBold.plus, size: 13, color: Color(0xFF0284C7)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 8 Glasses Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(8, (index) {
              final isFilled = index < glasses;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(index + 1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isFilled ? const Color(0xFF0284C7) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isFilled ? const Color(0xFF0284C7) : const Color(0xFFBAE6FD),
                      width: 1.2,
                    ),
                    boxShadow: isFilled
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isFilled ? PhosphorIconsFill.drop : PhosphorIconsRegular.drop,
                        size: 14,
                        color: isFilled ? Colors.white : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isFilled ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),

          // Progress line
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (glasses / 8).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: const Color(0xFFE0F2FE),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? '$percent% দৈনিক পূরণ' : '$percent% Completed',
                style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
              ),
              Text(
                glasses >= 8
                    ? (isBn ? 'দারুণ! লক্ষ্য পূরণ হয়েছে 🎉' : 'Awesome! Target Reached 🎉')
                    : (isBn ? 'আরও ${8 - glasses} গ্লাস বাকি' : '${8 - glasses} glasses left'),
                style: TextStyle(
                  fontSize: 10,
                  color: glasses >= 8 ? const Color(0xFF059669) : const Color(0xFF0284C7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

