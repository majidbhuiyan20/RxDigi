import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/health_tip_model.dart';
import '../provider/health_tips_provider.dart';
import '../theme/tips_theme.dart';

class HealthTipDetailScreen extends ConsumerWidget {
  final HealthTipModel tip;

  const HealthTipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = ref.watch(tipLanguageIsBnProvider);
    final bookmarkedIds = ref.watch(bookmarkedTipIdsProvider).value ?? [];
    final isBookmarked = bookmarkedIds.contains(tip.id);

    final catColor = TipsTheme.getColor(tip.bodyPart.isNotEmpty ? tip.bodyPart : tip.category);
    final catIcon = TipsTheme.getIcon(tip.bodyPart.isNotEmpty ? tip.bodyPart : tip.category);

    final hack = tip.getQuickHack(isBn);
    final myth = tip.getMythBuster(isBn);
    final remedy = tip.getHomeRemedy(isBn);
    final keyPoints = tip.getKeyPoints(isBn);
    final dos = tip.getDos(isBn);
    final donts = tip.getDonts(isBn);
    final doctorAlert = tip.getWhenToSeeDoctor(isBn);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          tip.getCategory(isBn),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          // Bookmark toggle
          IconButton(
            icon: Icon(
              isBookmarked ? PhosphorIconsFill.bookmarkSimple : PhosphorIconsRegular.bookmarkSimple,
              color: isBookmarked ? TipsTheme.primary : const Color(0xFF475569),
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(bookmarkedTipIdsProvider.notifier).toggle(tip.id);
            },
          ),
          // Language toggle
          IconButton(
            icon: const Icon(PhosphorIconsRegular.translate, color: Color(0xFF475569)),
            onPressed: () {
              HapticFeedback.selectionClick();
              ref.read(tipLanguageIsBnProvider.notifier).toggle();
            },
          ),
          // Share
          IconButton(
            icon: const Icon(PhosphorIconsRegular.shareNetwork, color: Color(0xFF475569)),
            onPressed: () => _shareTip(tip, isBn),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Title & Category Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.025),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(catIcon, size: 14, color: catColor),
                            const SizedBox(width: 5),
                            Text(
                              tip.getCategory(isBn),
                              style: TextStyle(
                                color: catColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(PhosphorIconsRegular.clock, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              tip.readTime,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tip.getTitle(isBn),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tip.getSummary(isBn),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF475569),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 2. Quick 1-Minute Hack (if available)
            if (hack.isNotEmpty) ...[
              _buildSectionBox(
                icon: PhosphorIconsFill.lightning,
                iconColor: TipsTheme.quickHackColor,
                bgColor: TipsTheme.quickHackBg,
                borderColor: TipsTheme.quickHackBorder,
                title: isBn ? '১ মিনিটের জরুরি হ্যাক' : '1-Minute Quick Hack',
                titleColor: TipsTheme.quickHackColor,
                content: hack,
              ),
              const SizedBox(height: 14),
            ],

            // 3. Myth Buster vs Fact (if available)
            if (myth.isNotEmpty) ...[
              _buildSectionBox(
                icon: PhosphorIconsFill.shieldWarning,
                iconColor: TipsTheme.mythColor,
                bgColor: TipsTheme.mythBg,
                borderColor: TipsTheme.mythBorder,
                title: isBn ? 'ভুল ধারণা বনাম আসল সত্য' : 'Myth vs Medical Fact',
                titleColor: TipsTheme.mythColor,
                content: myth,
              ),
              const SizedBox(height: 14),
            ],

            // 4. Kitchen / Home Remedy (if available)
            if (remedy.isNotEmpty) ...[
              _buildSectionBox(
                icon: PhosphorIconsFill.plant,
                iconColor: TipsTheme.remedyColor,
                bgColor: TipsTheme.remedyBg,
                borderColor: TipsTheme.remedyBorder,
                title: isBn ? 'ঘরোয়া প্রাকৃতিক সমাধান' : 'Natural Home Remedy',
                titleColor: TipsTheme.remedyColor,
                content: remedy,
              ),
              const SizedBox(height: 14),
            ],

            // 5. Key Highlights
            if (keyPoints.isNotEmpty) ...[
              _buildCardSection(
                title: isBn ? 'মূল শিক্ষণীয় বিষয়' : 'Key Highlights',
                icon: PhosphorIconsBold.listChecks,
                iconColor: TipsTheme.primary,
                child: Column(
                  children: keyPoints.map((point) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: TipsTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 6. Do's and Don'ts Stacked
            if (dos.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TipsTheme.doBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TipsTheme.doBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsFill.checkCircle, size: 18, color: TipsTheme.doColor),
                        const SizedBox(width: 8),
                        Text(
                          isBn ? 'যা করবেন (করণীয়)' : 'Do\'s (Recommended)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TipsTheme.doColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...dos.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4, right: 8),
                                child: Icon(PhosphorIconsFill.check, size: 14, color: TipsTheme.doColor),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF065F46),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            if (donts.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: TipsTheme.dontBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TipsTheme.dontBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(PhosphorIconsFill.xCircle, size: 18, color: TipsTheme.dontColor),
                        const SizedBox(width: 8),
                        Text(
                          isBn ? 'ভুলেও যা করবেন না (বর্জনীয়)' : 'Don\'ts (Avoid)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: TipsTheme.dontColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...donts.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4, right: 8),
                                child: Icon(PhosphorIconsFill.x, size: 14, color: TipsTheme.dontColor),
                              ),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF991B1B),
                                    height: 1.4,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 7. When to See a Doctor (Red Flag Warning)
            if (doctorAlert.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: TipsTheme.doctorWarningBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TipsTheme.doctorWarningBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(PhosphorIconsFill.warningOctagon, size: 20, color: TipsTheme.doctorWarningColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'কখন অবশ্যই ডাক্তার দেখাবেন?' : 'When to Consult a Doctor?',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: TipsTheme.doctorWarningColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            doctorAlert,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF881337),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 8. Share Action Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TipsTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _shareTip(tip, isBn),
                icon: const Icon(PhosphorIconsBold.shareNetwork, size: 18),
                label: Text(
                  isBn ? 'এই টিপসটি বন্ধুদের সাথে শেয়ার করুন' : 'Share this Tip with Friends',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 9. Disclaimer
            Center(
              child: Text(
                tip.getDisclaimer(isBn),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionBox({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String title,
    required Color titleColor,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF1E293B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _shareTip(HealthTipModel tip, bool isBn) {
    HapticFeedback.lightImpact();
    final buffer = StringBuffer();
    buffer.writeln('🌟 ${tip.getTitle(isBn)}');
    buffer.writeln();
    buffer.writeln(tip.getSummary(isBn));
    buffer.writeln();
    if (tip.getQuickHack(isBn).isNotEmpty) {
      buffer.writeln('⚡ হ্যাক: ${tip.getQuickHack(isBn)}');
      buffer.writeln();
    }
    if (tip.getMythBuster(isBn).isNotEmpty) {
      buffer.writeln('🚫 ভুল ধারণা বনাম সত্য: ${tip.getMythBuster(isBn)}');
      buffer.writeln();
    }
    buffer.writeln('📱 RxDigi হেলথ অ্যাপ থেকে শেয়ারকৃত।');

    Share.share(buffer.toString());
  }
}
