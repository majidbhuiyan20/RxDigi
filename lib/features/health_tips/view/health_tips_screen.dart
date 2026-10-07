import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    if (selectedBodyPart != null && tip.bodyPart != selectedBodyPart) {
                      return false;
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
                      // When not searching: show daily banner, trending pain points, and body navigator
                      if (!isSearching) ...[
                        const DailyHealthHackBanner(),
                        const SizedBox(height: 6),
                        const TrendingTopicsBar(),
                        const SizedBox(height: 6),
                        const BodyPartFilterBar(),
                        const SizedBox(height: 10),
                      ],

                      // Results header count
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isSearching
                                  ? (isBn ? 'অনুসন্ধানের ফলাফল' : 'Search Results')
                                  : (selectedBodyPart != null
                                      ? (isBn ? 'নির্বাচিত ক্যাটাগরি' : 'Selected Category')
                                      : (isBn ? 'সকল স্বাস্থ্য নির্দেশিকা' : 'All Health Guides')),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: TipsTheme.primary.withOpacity(0.08),
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
