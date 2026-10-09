import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../models/bangladeshi_food_model.dart';

class FoodDetailSheet extends StatelessWidget {
  final BangladeshiFoodModel food;
  final VoidCallback? onAddToMeal;

  const FoodDetailSheet({
    super.key,
    required this.food,
    this.onAddToMeal,
  });

  static Future<void> show(BuildContext context, BangladeshiFoodModel food, {VoidCallback? onAddToMeal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodDetailSheet(food: food, onAddToMeal: onAddToMeal),
    );
  }

  Color _getGiColor(int gi) {
    if (gi <= 55) return const Color(0xFF10B981); // Green
    if (gi <= 69) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Red
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final giColor = _getGiColor(food.glycemicIndex);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header Row: Emoji + Title + Calorie Pill
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(food.emoji, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.nameBn,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      food.nameEn,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isBn ? 'পরিমাণ:' : 'Portion:'} ${food.servingSizeBn}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.primaryColor.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Column(
                  children: [
                    Text(
                      '${food.calories}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                        height: 1.1,
                      ),
                    ),
                    const Text(
                      'kcal',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Glycemic Index Gauge Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: giColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: giColor.withOpacity(0.25)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: giColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    food.glycemicIndex <= 55
                        ? PhosphorIconsFill.checkCircle
                        : (food.glycemicIndex <= 69
                            ? PhosphorIconsFill.warningCircle
                            : PhosphorIconsFill.prohibit),
                    color: giColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'গ্লাইসেমিক ইনডেক্স (GI)' : 'Glycemic Index (GI)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'GI: ${food.glycemicIndex}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: giColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        food.diabeticRisk.labelBn,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: giColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Macronutrient Breakdown Grid (Carbs, Protein, Fat, Fiber)
          Text(
            isBn ? 'পুষ্টি উপাদান (প্রতি সার্ভিং)' : 'Macronutrients',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMacroItem(
                label: isBn ? 'কার্বোহাইড্রেট' : 'Carbs',
                value: '${food.carbs}g',
                color: const Color(0xFFF59E0B),
                icon: PhosphorIconsRegular.grains,
              ),
              const SizedBox(width: 8),
              _buildMacroItem(
                label: isBn ? 'প্রোটিন' : 'Protein',
                value: '${food.protein}g',
                color: const Color(0xFF3B82F6),
                icon: PhosphorIconsRegular.barbell,
              ),
              const SizedBox(width: 8),
              _buildMacroItem(
                label: isBn ? 'ফ্যাট / চর্বি' : 'Fat',
                value: '${food.fat}g',
                color: const Color(0xFFEF4444),
                icon: PhosphorIconsRegular.drop,
              ),
              const SizedBox(width: 8),
              _buildMacroItem(
                label: isBn ? 'আঁশ / ফাইবার' : 'Fiber',
                value: '${food.fiber}g',
                color: const Color(0xFF10B981),
                icon: PhosphorIconsRegular.plant,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Diabetic & Clinical Guidance Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  PhosphorIconsFill.info,
                  color: AppColors.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'ডায়াবেটিস পুষ্টি পরামর্শ' : 'Diabetic Guidance',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isBn ? food.diabeticAdviceBn : food.diabeticAdviceEn,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Add to Plate / Meal Button
          if (onAddToMeal != null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onAddToMeal!();
                },
                icon: const Icon(PhosphorIconsBold.plusCircle, size: 20, color: Colors.white),
                label: Text(
                  isBn ? 'আজকের প্লেটে যোগ করুন (+)' : 'Add to My Meal Plate (+)',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMacroItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

