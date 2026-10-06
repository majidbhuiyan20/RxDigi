import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/health_tips_provider.dart';
import '../widgets/health_tips_header.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/health_tip_list_card.dart';
import '../widgets/tips_empty_state.dart';

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
            // 1. Search & Language Header
            HealthTipsHeader(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              onClearSearch: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            ),

            // 2. Category Filter Bar
            tipsAsync.when(
              data: (tips) => CategoryFilterBar(tips: tips, isBn: isBn),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // 3. Tips List
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
                    return TipsEmptyState(isBn: isBn);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filteredTips.length,
                    itemBuilder: (context, index) {
                      return HealthTipListCard(
                        tip: filteredTips[index],
                        isBn: isBn,
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
