import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../provider/health_tips_provider.dart';
import '../widgets/health_tip_list_card.dart';

class SavedTipsScreen extends ConsumerWidget {
  const SavedTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final bookmarkedIds = ref.watch(bookmarkedTipIdsProvider).value ?? [];
    final allTipsAsync = ref.watch(healthTipsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isBn ? 'সংরক্ষিত স্বাস্থ্য টিপস' : 'Saved Health Tips',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
      ),
      body: allTipsAsync.when(
        data: (allTips) {
          final savedList = allTips.where((t) => bookmarkedIds.contains(t.id)).toList();

          if (savedList.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        PhosphorIconsRegular.bookmarkSimple,
                        size: 36,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      isBn ? 'কোনো টিপস সেভ করা নেই' : 'No Saved Tips Yet',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBn
                          ? 'পছন্দের স্বাস্থ্য টিপসে বুকমার্ক আইকন চেপে সহজে পরবর্তীতে পড়ার জন্য সংরক্ষণ করুন।'
                          : 'Tap the bookmark icon on any health tip to save it for quick reference.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: savedList.length,
            itemBuilder: (context, index) {
              return HealthTipListCard(tip: savedList[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

