import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/health_tip_model.dart';
import '../provider/health_tips_provider.dart';
import '../services/health_tip_tts_service.dart';
import '../theme/tips_theme.dart';
import '../view/health_tip_detail_screen.dart';
import 'tip_story_card_modal.dart';

class HealthTipListCard extends ConsumerWidget {
  final HealthTipModel tip;

  const HealthTipListCard({super.key, required this.tip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final bookmarkedIds = ref.watch(bookmarkedTipIdsProvider).value ?? [];
    final isBookmarked = bookmarkedIds.contains(tip.id);

    final catColor = TipsTheme.getColor(tip.bodyPart.isNotEmpty ? tip.bodyPart : tip.category);
    final catIcon = TipsTheme.getIcon(tip.bodyPart.isNotEmpty ? tip.bodyPart : tip.category);

    final hack = tip.getQuickHack(isBn);
    final myth = tip.getMythBuster(isBn);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HealthTipDetailScreen(tip: tip),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Category Tag, Reading Time & Bookmark Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(catIcon, size: 12, color: catColor),
                              const SizedBox(width: 5),
                              Text(
                                tip.getCategory(isBn),
                                style: TextStyle(
                                  color: catColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tip.readTime,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(bookmarkedTipIdsProvider.notifier).toggle(tip.id);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          isBookmarked ? PhosphorIconsFill.bookmarkSimple : PhosphorIconsRegular.bookmarkSimple,
                          size: 19,
                          color: isBookmarked ? TipsTheme.primary : Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),

                // 2. Title
                Text(
                  tip.getTitle(isBn),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),

                // 3. Short Summary
                Text(
                  tip.getSummary(isBn),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // 4. Highlight Preview (Hack or Myth preview if exists)
                if (hack.isNotEmpty || myth.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: hack.isNotEmpty ? TipsTheme.quickHackBg : TipsTheme.mythBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: hack.isNotEmpty ? TipsTheme.quickHackBorder : TipsTheme.mythBorder,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          hack.isNotEmpty ? PhosphorIconsFill.lightning : PhosphorIconsFill.info,
                          size: 13,
                          color: hack.isNotEmpty ? TipsTheme.quickHackColor : TipsTheme.mythColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            hack.isNotEmpty ? hack : myth,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: hack.isNotEmpty
                                  ? const Color(0xFF92400E)
                                  : const Color(0xFF5B21B6),
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 5. Card Footer
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Listen quick button
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            AppFeedback.playLight();
                            final buffer = StringBuffer();
                            buffer.write('${tip.getTitle(isBn)}. ');
                            buffer.write(tip.getSummary(isBn));
                            HealthTipTtsService().speak(
                              tipId: tip.id,
                              text: buffer.toString(),
                              isBn: isBn,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDFA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF99F6E4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(PhosphorIconsFill.speakerHigh, size: 12, color: Color(0xFF0F766E)),
                                const SizedBox(width: 4),
                                Text(
                                  isBn ? 'শুনুন' : 'Listen',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F766E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Story Card quick button
                        InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            AppFeedback.playLight();
                            TipStoryCardModal.show(context, tip, isBn);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDF2F8),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFBCFE8)),
                            ),
                            child: Row(
                              children: [
                                const Icon(PhosphorIconsFill.instagramLogo, size: 12, color: Color(0xFFDB2777)),
                                const SizedBox(width: 4),
                                Text(
                                  isBn ? 'স্টোরি' : 'Story',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFDB2777),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          isBn ? 'বিস্তারিত পড়ুন' : 'Read more',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: TipsTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          PhosphorIconsRegular.caretRight,
                          size: 12,
                          color: TipsTheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
