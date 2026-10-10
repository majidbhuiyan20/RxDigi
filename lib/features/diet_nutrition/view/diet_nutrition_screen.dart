import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../l10n/local_provider.dart';
import '../models/bangladeshi_food_model.dart';
import '../data/bangladeshi_food_database.dart';
import '../widgets/food_item_tile.dart';
import '../widgets/meal_calorie_calculator_sheet.dart';
import '../../../core/utils/app_feedback.dart';

class DietNutritionScreen extends ConsumerStatefulWidget {
  const DietNutritionScreen({super.key});

  @override
  ConsumerState<DietNutritionScreen> createState() => _DietNutritionScreenState();
}

class _DietNutritionScreenState extends ConsumerState<DietNutritionScreen> {
  final TextEditingController _searchController = TextEditingController();
  FoodCategory? _selectedCategory;
  bool _onlyDiabeticSafe = false;
  bool _isLoading = true;
  List<BangladeshiFoodModel> _allFoods = [];

  // Selected meal plate: Map<Food, Quantity>
  final Map<BangladeshiFoodModel, int> _selectedMeal = {};

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final list = await BangladeshiFoodDatabase.loadAllFoods();
    if (mounted) {
      setState(() {
        _allFoods = list;
        _isLoading = false;
      });
    }
  }

  List<BangladeshiFoodModel> get _filteredFoods {
    var list = BangladeshiFoodDatabase.searchFoods(_allFoods, _searchController.text);
    if (_selectedCategory != null) {
      list = BangladeshiFoodDatabase.filterByCategory(list, _selectedCategory);
    }
    if (_onlyDiabeticSafe) {
      list = BangladeshiFoodDatabase.getDiabeticSafeFoods(list);
    }
    return list;
  }

  int get _totalPlateCalories {
    int sum = 0;
    _selectedMeal.forEach((food, qty) {
      sum += food.calories * qty;
    });
    return sum;
  }

  int get _totalPlateItemsCount {
    int sum = 0;
    _selectedMeal.forEach((_, qty) {
      sum += qty;
    });
    return sum;
  }

  void _addToMeal(BangladeshiFoodModel food) {
    setState(() {
      _selectedMeal[food] = (_selectedMeal[food] ?? 0) + 1;
    });
  }

  void _updateQuantity(BangladeshiFoodModel food, int qty) {
    setState(() {
      if (qty <= 0) {
        _selectedMeal.remove(food);
      } else {
        _selectedMeal[food] = qty;
      }
    });
  }

  void _clearMeal() {
    setState(() {
      _selectedMeal.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isBn = currentLocale.languageCode == 'bn';
    final foods = _filteredFoods;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'দেশীয় খাবার ও ডায়াবেটিস গাইড' : 'Bangladeshi Diet & GI',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                AppFeedback.playLight();
                final nextLang = isBn ? 'en' : 'bn';
                ref.read(localeProvider.notifier).setLocale(Locale(nextLang));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsRegular.translate, size: 14, color: Color(0xFF0F172A)),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'EN' : 'বাং',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedMeal.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  AppFeedback.playLight();
                  MealCalorieCalculatorSheet.show(
                    context,
                    selectedMeal: _selectedMeal,
                    onUpdateQuantity: _updateQuantity,
                    onClearMeal: _clearMeal,
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(PhosphorIconsBold.calculator, size: 14, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalPlateCalories kcal',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ─── 1. Search Bar & Diabetic Toggle ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: isBn
                          ? 'খাবারের নাম খুঁজুন (যেমন: ভাত, রুটি, ডাল, আম...)'
                          : 'Search food (e.g., Rice, Roti, Dal, Mango...)',
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                      prefixIcon: const Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(PhosphorIconsRegular.x, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Quick Filters: "🟢 ডায়াবেটিস-বান্ধব (Low GI)" toggle chip
                Row(
                  children: [
                    FilterChip(
                      selected: _onlyDiabeticSafe,
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(PhosphorIconsFill.shieldCheck, size: 14, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(
                            isBn ? 'ডায়াবেটিস নিরাপদ (Low GI)' : 'Diabetic Safe Only',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: _onlyDiabeticSafe ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      selectedColor: const Color(0xFF10B981),
                      backgroundColor: const Color(0xFFF1F5F9),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      onSelected: (val) {
                        AppFeedback.playSelection();
                        setState(() => _onlyDiabeticSafe = val);
                      },
                    ),
                    const Spacer(),
                    Text(
                      '${foods.length} ${isBn ? 'টি খাবার' : 'items'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── 2. Category Filter Chips (Horizontal Scroll) ───
          Container(
            height: 48,
            color: Colors.white,
            padding: const EdgeInsets.only(bottom: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildCategoryChip(
                  label: isBn ? 'সকল খাবার' : 'All Foods',
                  emoji: '🍽️',
                  isSelected: _selectedCategory == null,
                  onTap: () => setState(() => _selectedCategory = null),
                ),
                ...FoodCategory.values.map((cat) {
                  return _buildCategoryChip(
                    label: isBn ? cat.labelBn : cat.labelEn,
                    emoji: cat.iconEmoji,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  );
                }),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // ─── 3. Foods List ───
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF10B981),
                    ),
                  )
                : foods.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🔍', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 10),
                            Text(
                              isBn ? 'কোনো খাবার পাওয়া যায়নি' : 'No foods found',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isBn ? 'অন্য কোনো নাম লিখে সার্চ করুন' : 'Try searching with another keyword',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                    padding: EdgeInsets.fromLTRB(16, 14, 16, _selectedMeal.isNotEmpty ? 90 : 30),
                    physics: const BouncingScrollPhysics(),
                    itemCount: foods.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      final qty = _selectedMeal[food] ?? 0;
                      return FoodItemTile(
                        food: food,
                        quantityInPlate: qty,
                        onAddToPlate: () => _addToMeal(food),
                      );
                    },
                  ),
          ),
        ],
      ),

      // ─── 4. Floating Meal Plate Bar ───
      bottomSheet: _selectedMeal.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: InkWell(
                  onTap: () {
                    AppFeedback.playLight();
                    MealCalorieCalculatorSheet.show(
                      context,
                      selectedMeal: _selectedMeal,
                      onUpdateQuantity: _updateQuantity,
                      onClearMeal: _clearMeal,
                    ).then((_) => setState(() {}));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            PhosphorIconsFill.forkKnife,
                            color: Color(0xFF38BDF8),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isBn
                                    ? 'আপনার প্লেটে $_totalPlateItemsCount টি খাবার'
                                    : '$_totalPlateItemsCount items in plate',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                              Text(
                                '$_totalPlateCalories kcal | ${isBn ? 'ক্যালকুলেটর দেখুন' : 'View Breakdown'}',
                                style: const TextStyle(
                                  color: Color(0xFF38BDF8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Text(
                                isBn ? 'হিসাব করুন' : 'Calculate',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(PhosphorIconsBold.arrowRight, size: 12, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          AppFeedback.playSelection();
          onTap();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

