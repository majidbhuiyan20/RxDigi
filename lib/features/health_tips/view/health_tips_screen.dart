import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../models/health_tip_model.dart';
import '../provider/health_tips_provider.dart';
import 'health_tip_detail_screen.dart';

class HealthTipsScreen extends ConsumerStatefulWidget {
  const HealthTipsScreen({super.key});

  @override
  ConsumerState<HealthTipsScreen> createState() => _HealthTipsScreenState();
}

class _HealthTipsScreenState extends ConsumerState<HealthTipsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite':
        return Icons.favorite_rounded;
      case 'water_drop':
        return Icons.water_drop_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'medical_services':
        return Icons.medical_services_rounded;
      case 'bug_report':
        return Icons.coronavirus_rounded;
      case 'bedtime':
        return Icons.bedtime_rounded;
      default:
        return Icons.health_and_safety_rounded;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final selectedCategory = ref.watch(selectedTipCategoryProvider);
    final tipsAsync = ref.watch(healthTipsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header with Language Toggle
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'স্বাস্থ্য সুরক্ষা ও টিপস' : 'Health & Wellness Guide',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1C1E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBn ? 'সুস্থ জীবনযাত্রার প্রয়োজনীয় নির্দেশিকা' : 'Daily preventive care & lifestyle tips',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      // Language Selector Pill
                      GestureDetector(
                        onTap: () {
                          ref.read(tipLanguageIsBnProvider.notifier).state = !isBn;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.language, size: 16, color: AppColors.primaryColor),
                              const SizedBox(width: 6),
                              Text(
                                isBn ? 'English' : 'বাংলা',
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: isBn ? 'রোগ বা স্বাস্থ্য টিপস খুঁজুন...' : 'Search health tips, habits...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey.shade600),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Category Filter Chips
            tipsAsync.when(
              data: (tips) {
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
                            ref.read(selectedTipCategoryProvider.notifier).state =
                                (cat == 'All') ? null : cat;
                          },
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // Tips List
            Expanded(
              child: tipsAsync.when(
                data: (allTips) {
                  final filteredTips = allTips.where((tip) {
                    final matchesCategory = selectedCategory == null || tip.category == selectedCategory;
                    if (!matchesCategory) return false;

                    if (_searchQuery.isEmpty) return true;
                    final title = tip.getTitle(isBn).toLowerCase();
                    final summary = tip.getSummary(isBn).toLowerCase();
                    final category = tip.getCategory(isBn).toLowerCase();
                    return title.contains(_searchQuery) ||
                        summary.contains(_searchQuery) ||
                        category.contains(_searchQuery);
                  }).toList();

                  if (filteredTips.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            isBn ? 'কোনো টিপস পাওয়া যায়নি' : 'No health tips found',
                            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filteredTips.length,
                    itemBuilder: (context, index) {
                      final tip = filteredTips[index];
                      final tipColor = _parseColor(tip.color);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HealthTipDetailScreen(tip: tip),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: tipColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(_getIconData(tip.icon), color: tipColor, size: 26),
                              ),
                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: tipColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        tip.getCategory(isBn),
                                        style: TextStyle(
                                          color: tipColor,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      tip.getTitle(isBn),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tip.getSummary(isBn),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.35,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Text('Error loading tips: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
