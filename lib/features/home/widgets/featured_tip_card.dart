import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../health_tips/provider/health_tips_provider.dart';
import '../../health_tips/view/health_tips_screen.dart';
import '../../health_tips/view/health_tip_detail_screen.dart';

class FeaturedTipCard extends ConsumerWidget {
  const FeaturedTipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tipsAsync = ref.watch(healthTipsListProvider);
    final isTipBn = ref.watch(tipLanguageIsBnProvider);

    return tipsAsync.when(
      data: (tips) {
        if (tips.isEmpty) return const SizedBox.shrink();

        // Rotate featured tip daily based on day of year
        final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
        final tip = tips[dayOfYear % tips.length];

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Language Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00897B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF00897B), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isTipBn ? 'দৈনিক স্বাস্থ্য বার্তা' : "Daily Health Insight",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),

                  // Mini Bangla / English Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: Row(
                      children: [
                        _buildLangChip('বাং', isTipBn, () {
                          if (!isTipBn) ref.read(tipLanguageIsBnProvider.notifier).state = true;
                        }),
                        _buildLangChip('EN', !isTipBn, () {
                          if (isTipBn) ref.read(tipLanguageIsBnProvider.notifier).state = false;
                        }),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tip Title
              Text(
                isTipBn ? tip.titleBn : tip.titleEn,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
              ),
              const SizedBox(height: 6),

              // Summary
              Text(
                isTipBn ? tip.summaryBn : tip.summaryEn,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 12),

              // Category & Detail Link
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00897B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tip.getCategory(isTipBn),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF00897B)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HealthTipDetailScreen(tip: tip),
                        ),
                      );
                    },
                    child: Text(
                      isTipBn ? 'বিস্তারিত পড়ুন →' : 'Read Full Tip →',
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF00897B)),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16),

              // View all health tips button
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => const HealthTipsScreen()),
                  ),
                  icon: const Icon(Icons.menu_book_rounded, size: 16, color: Color(0xFF00897B)),
                  label: Text(
                    isTipBn ? 'সকল স্বাস্থ্য নির্দেশিকা ও টিপস দেখুন' : 'Explore All Wellness Categories',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF00897B), fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildLangChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00897B) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
