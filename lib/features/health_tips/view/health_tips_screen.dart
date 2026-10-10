import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../provider/health_tips_provider.dart';
import '../theme/tips_theme.dart';
import '../widgets/health_tips_header.dart';
import '../widgets/daily_health_hack_banner.dart';
import '../widgets/trending_topics_bar.dart';
import '../widgets/body_part_filter_bar.dart';
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
  int _categoryTab = 0; // 0: Trending, 1: Body Navigator

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final selectedBodyPart = ref.watch(selectedBodyPartProvider);
    final tipsAsync = ref.watch(healthTipsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header with search, bookmarks, and language switch
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

            // 2. Main Content
            Expanded(
              child: tipsAsync.when(
                data: (allTips) {
                  final filteredTips = allTips.where((tip) {
                    // Body part filter
                    if (selectedBodyPart != null) {
                      final s = selectedBodyPart;
                      final bp = tip.bodyPart;
                      final matches = (bp == s) ||
                          ((s == 'bone' || s == 'bones') && (bp == 'bone' || bp == 'bones')) ||
                          ((s == 'kidney' || s == 'kidneys') && (bp == 'kidney' || bp == 'kidneys')) ||
                          ((s == 'mouth' || s == 'ent') && (bp == 'mouth' || bp == 'ent')) ||
                          ((s == 'hands_feet' || s == 'feet') && (bp == 'hands_feet' || bp == 'feet')) ||
                          ((s == 'pancreas' || s == 'lifestyle') && (bp == 'pancreas' || bp == 'lifestyle'));
                      if (!matches) return false;
                    }

                    // Search query filter
                    if (_searchQuery.isNotEmpty) {
                      final title = tip.getTitle(isBn).toLowerCase();
                      final summary = tip.getSummary(isBn).toLowerCase();
                      final cat = tip.getCategory(isBn).toLowerCase();
                      final hack = tip.getQuickHack(isBn).toLowerCase();
                      final myth = tip.getMythBuster(isBn).toLowerCase();
                      final remedy = tip.getHomeRemedy(isBn).toLowerCase();

                      return title.contains(_searchQuery) ||
                          summary.contains(_searchQuery) ||
                          cat.contains(_searchQuery) ||
                          hack.contains(_searchQuery) ||
                          myth.contains(_searchQuery) ||
                          remedy.contains(_searchQuery);
                    }

                    return true;
                  }).toList();

                  final isSearching = _searchQuery.isNotEmpty;

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 110),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // When not searching: show daily banner, tab switcher, and category chips
                      if (!isSearching) ...[
                        const DailyHealthHackBanner(),
                        const SizedBox(height: 6),
                        // Segmented Tab Switcher
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 42,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _categoryTab = 0);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _categoryTab == 0 ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(11),
                                        boxShadow: _categoryTab == 0
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            PhosphorIconsFill.flame,
                                            size: 15,
                                            color: _categoryTab == 0 ? const Color(0xFFEA580C) : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isBn ? 'জনপ্রিয় সমস্যা' : 'Trending Issues',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: _categoryTab == 0 ? FontWeight.bold : FontWeight.w600,
                                              color: _categoryTab == 0 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _categoryTab = 1);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      decoration: BoxDecoration(
                                        color: _categoryTab == 1 ? Colors.white : Colors.transparent,
                                        borderRadius: BorderRadius.circular(11),
                                        boxShadow: _categoryTab == 1
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.06),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1.5),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            PhosphorIconsFill.squaresFour,
                                            size: 15,
                                            color: _categoryTab == 1 ? TipsTheme.primary : const Color(0xFF64748B),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            isBn ? 'অঙ্গভিত্তিক গাইড' : 'Body Navigator',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: _categoryTab == 1 ? FontWeight.bold : FontWeight.w600,
                                              color: _categoryTab == 1 ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_categoryTab == 0)
                          const TrendingTopicsBar()
                        else
                          const BodyPartFilterBar(),
                        const SizedBox(height: 8),
                      ],

                      // Results header count with reset filter
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      isSearching
                                          ? (isBn ? 'অনুসন্ধানের ফলাফল' : 'Search Results')
                                          : (selectedBodyPart != null
                                              ? (isBn ? 'ফিল্টার করা টিপস' : 'Filtered Tips')
                                              : (isBn ? 'সকল স্বাস্থ্য নির্দেশিকা' : 'All Health Guides')),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (selectedBodyPart != null) ...[
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        HapticFeedback.lightImpact();
                                        ref.read(selectedBodyPartProvider.notifier).select(null);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(PhosphorIconsBold.x, size: 10, color: Colors.red),
                                            const SizedBox(width: 3),
                                            Text(
                                              isBn ? 'মুছুন' : 'Clear',
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: TipsTheme.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${filteredTips.length} ${isBn ? 'টি টিপস' : 'tips'}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: TipsTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tips list or empty state
                      if (filteredTips.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: TipsEmptyState(isBn: isBn),
                        )
                      else
                        ...filteredTips.map((tip) => HealthTipListCard(tip: tip)),
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('Error loading tips: $e'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
