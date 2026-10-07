import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../models/health_tip_model.dart';
import '../provider/health_tips_provider.dart';

class CategoryFilterBar extends ConsumerWidget {
  final List<HealthTipModel> tips;
  final bool isBn;

  const CategoryFilterBar({
    super.key,
    required this.tips,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedTipCategoryProvider);
    final categories = ['All', ...tips.map((e) => e.category).toSet().toList()];

    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = (selectedCategory == null && cat == 'All') ||
              (selectedCategory == cat);

          String catLabel = cat;
          if (cat == 'All') {
            catLabel = isBn ? 'সব টিপস' : 'All';
          } else {
            final matched = tips.firstWhere((t) => t.category == cat, orElse: () => tips.first);
            catLabel = matched.getCategory(isBn);
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                catLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primaryColor,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
                ),
              ),
              onSelected: (selected) {
                ref.read(selectedTipCategoryProvider.notifier).select(
                    (cat == 'All') ? null : cat);
              },
            ),
          );
        },
      ),
    );
  }
}
