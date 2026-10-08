import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../provider/health_tips_provider.dart';
import '../view/health_tip_detail_screen.dart';

class DailyHealthHackBanner extends ConsumerWidget {
  const DailyHealthHackBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final featuredTipAsync = ref.watch(dailyFeaturedTipProvider);

    return featuredTipAsync.when(
      data: (tip) {
        if (tip == null) return const SizedBox.shrink();

        final hasMyth = tip.getMythBuster(isBn).isNotEmpty;
        final hasHack = tip.getQuickHack(isBn).isNotEmpty;
        final displaySubtitle = hasMyth
            ? tip.getMythBuster(isBn)
            : (hasHack ? tip.getQuickHack(isBn) : tip.getSummary(isBn));

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HealthTipDetailScreen(tip: tip),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top tag row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                PhosphorIconsFill.lightning,
                                size: 13,
                                color: Color(0xFFFDE047),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isBn ? 'আজকের জরুরি হ্যাক' : 'Daily Health Hack',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                PhosphorIconsRegular.clock,
                                size: 11,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tip.readTime,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      tip.getTitle(isBn),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Hack or Myth content
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            hasMyth ? PhosphorIconsFill.warningCircle : PhosphorIconsFill.sparkle,
                            size: 15,
                            color: const Color(0xFFFDE047),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              displaySubtitle,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Bottom tap to read
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          isBn ? 'বিস্তারিত পড়ুন' : 'Read details',
                          style: const TextStyle(
                            color: Color(0xFF93C5FD),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          PhosphorIconsRegular.arrowRight,
                          size: 13,
                          color: Color(0xFF93C5FD),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
