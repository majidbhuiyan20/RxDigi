import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../models/bangladeshi_food_model.dart';
import '../../../core/utils/app_feedback.dart';

class MealCalorieCalculatorSheet extends StatefulWidget {
  final Map<BangladeshiFoodModel, int> selectedMeal;
  final Function(BangladeshiFoodModel, int) onUpdateQuantity;
  final VoidCallback onClearMeal;

  const MealCalorieCalculatorSheet({
    super.key,
    required this.selectedMeal,
    required this.onUpdateQuantity,
    required this.onClearMeal,
  });

  static Future<void> show(
    BuildContext context, {
    required Map<BangladeshiFoodModel, int> selectedMeal,
    required Function(BangladeshiFoodModel, int) onUpdateQuantity,
    required VoidCallback onClearMeal,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MealCalorieCalculatorSheet(
        selectedMeal: selectedMeal,
        onUpdateQuantity: onUpdateQuantity,
        onClearMeal: onClearMeal,
      ),
    );
  }

  @override
  State<MealCalorieCalculatorSheet> createState() => _MealCalorieCalculatorSheetState();
}

class _MealCalorieCalculatorSheetState extends State<MealCalorieCalculatorSheet> {
  int get totalCalories {
    int sum = 0;
    widget.selectedMeal.forEach((food, qty) {
      sum += food.calories * qty;
    });
    return sum;
  }

  double get totalCarbs {
    double sum = 0;
    widget.selectedMeal.forEach((food, qty) {
      sum += food.carbs * qty;
    });
    return sum;
  }

  double get totalProtein {
    double sum = 0;
    widget.selectedMeal.forEach((food, qty) {
      sum += food.protein * qty;
    });
    return sum;
  }

  double get totalFat {
    double sum = 0;
    widget.selectedMeal.forEach((food, qty) {
      sum += food.fat * qty;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final entries = widget.selectedMeal.entries.toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
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
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.forkKnife,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'আজকের মিল ক্যালকুলেটর' : 'Meal Plate Calculator',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (entries.isNotEmpty)
                TextButton(
                  onPressed: () {
                    AppFeedback.playLight();
                    widget.onClearMeal();
                    Navigator.pop(context);
                  },
                  child: Text(
                    isBn ? 'প্লেট খালি করুন' : 'Clear Plate',
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Summary Grand Total Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'মোট ক্যালোরি গ্রহণ' : 'Total Calories',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$totalCalories',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'kcal',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol(isBn ? 'কার্বোহাইড্রেট' : 'Carbs', '${totalCarbs.toStringAsFixed(1)}g', const Color(0xFFFBBF24)),
                    _buildStatCol(isBn ? 'প্রোটিন' : 'Protein', '${totalProtein.toStringAsFixed(1)}g', const Color(0xFF60A5FA)),
                    _buildStatCol(isBn ? 'ফ্যাট' : 'Fat', '${totalFat.toStringAsFixed(1)}g', const Color(0xFFF87171)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            isBn ? 'প্লেটের খাবার সমূহ (${entries.length})' : 'Plate Items (${entries.length})',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),

          // Scrollable List of Foods
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🍽️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        Text(
                          isBn ? 'প্লেটে কোনো খাবার যোগ করা হয়নি' : 'Your meal plate is empty',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isBn ? 'খাবারের তালিকার (+) বাটনে চাপ দিয়ে যোগ করুন' : 'Tap (+) on any food to calculate calories',
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      final food = item.key;
                      final qty = item.value;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Text(food.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    food.nameBn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${food.calories * qty} kcal (${food.servingSizeBn})',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity controls (- / +)
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    AppFeedback.playLight();
                                    widget.onUpdateQuantity(food, qty - 1);
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: const Icon(PhosphorIconsBold.minus, size: 14, color: Color(0xFF0F172A)),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    '$qty',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    AppFeedback.playLight();
                                    widget.onUpdateQuantity(food, qty + 1);
                                    setState(() {});
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(PhosphorIconsBold.plus, size: 14, color: AppColors.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          const SizedBox(height: 12),

          // Done Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isBn ? 'সম্পন্ন করুন' : 'Done',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

