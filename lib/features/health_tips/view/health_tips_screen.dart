import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/health_tips_provider.dart';
import '../widgets/health_tips_header.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/health_tip_list_card.dart';
import '../widgets/tips_empty_state.dart';
import '../../../app/app_colors.dart';
import '../models/health_tip_model.dart';
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

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    children: [
                      _buildOfflineSummary(allTips, isBn),
                      if (_searchQuery.isEmpty && selectedCategory == null) ...[
                        const SizedBox(height: 14),
                        _buildDailyFocusCard(filteredTips.first, isBn),
                      ],
                      const SizedBox(height: 22),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBn ? 'আপনার জন্য টিপস' : 'For your wellbeing',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF17252A)),
                          ),
                          Text(
                            '${filteredTips.length} ${isBn ? 'টি' : 'tips'}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...filteredTips.map((tip) => HealthTipListCard(tip: tip, isBn: isBn)),
                    ],
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

  Widget _buildOfflineSummary(List<HealthTipModel> tips, bool isBn) {
    final categories = tips.map((tip) => tip.category).toSet().length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDECE8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE5F4F0), borderRadius: BorderRadius.circular(11)),
            child: const Icon(Icons.wifi_off_rounded, size: 18, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isBn ? 'ইন্টারনেট ছাড়াই স্বাস্থ্য টিপস পড়ুন' : 'Wellness guidance, always available offline',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF31534E)),
            ),
          ),
          Text('$categories ${isBn ? 'ক্যাটাগরি' : 'categories'}', style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildDailyFocusCard(HealthTipModel tip, bool isBn) {
    final color = _parseColor(tip.color);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: GestureDetector(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HealthTipDetailScreen(tip: tip))),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), shape: BoxShape.circle), child: Icon(_getIconData(tip.icon), color: Colors.white, size: 24)),
              const SizedBox(width: 12),
              Expanded(child: Text(isBn ? 'আজকের স্বাস্থ্য ফোকাস' : 'TODAY\'S HEALTH FOCUS', style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.6))),
              const Icon(Icons.arrow_outward_rounded, color: Colors.white, size: 20),
            ]),
            const SizedBox(height: 18),
            Text(tip.getTitle(isBn), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 21, height: 1.2, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(tip.getSummary(isBn), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.35)),
            const SizedBox(height: 16),
            Row(children: [
              Text(tip.getCategory(isBn), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(isBn ? 'বিস্তারিত পড়ুন' : 'Read the guide', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'favorite': return Icons.favorite_rounded;
      case 'water_drop': return Icons.water_drop_rounded;
      case 'shield': return Icons.shield_rounded;
      case 'restaurant': return Icons.restaurant_rounded;
      case 'medical_services': return Icons.medical_services_rounded;
      case 'bug_report': return Icons.coronavirus_rounded;
      case 'bedtime': return Icons.bedtime_rounded;
      default: return Icons.health_and_safety_rounded;
    }
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primaryColor;
    }
  }
}
