import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/app_colors.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/health_tip_model.dart';
import '../theme/tips_theme.dart';

class TipStoryCardModal extends StatefulWidget {
  final HealthTipModel tip;
  final bool isBn;

  const TipStoryCardModal({
    super.key,
    required this.tip,
    required this.isBn,
  });

  static void show(BuildContext context, HealthTipModel tip, bool isBn) {
    AppFeedback.playLight();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TipStoryCardModal(tip: tip, isBn: isBn),
    );
  }

  @override
  State<TipStoryCardModal> createState() => _TipStoryCardModalState();
}

class _TipStoryCardModalState extends State<TipStoryCardModal> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportAndShareImage() async {
    setState(() => _isExporting = true);
    AppFeedback.playSuccess();
    try {
      final boundary = _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary not found');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to generate PNG');

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/RxDigi_Story_${widget.tip.id}.png');
      await file.writeAsBytes(pngBytes);

      final shareCaption = widget.isBn
          ? '🌟 ${widget.tip.getTitle(true)}\n\n${widget.tip.getSummary(true)}\n\n📱 RxDigi অ্যাপে আরও জানুন।'
          : '🌟 ${widget.tip.getTitle(false)}\n\n${widget.tip.getSummary(false)}\n\n📱 Explore more on RxDigi Health.';

      await Share.shareXFiles(
        [XFile(file.path)],
        text: shareCaption,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ইমেজ এক্সপোর্টে সমস্যা: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  void _copyTipText() {
    AppFeedback.playSuccess();
    final tip = widget.tip;
    final isBn = widget.isBn;
    final buffer = StringBuffer();
    buffer.writeln('🌟 ${tip.getTitle(isBn)}');
    buffer.writeln();
    buffer.writeln(tip.getSummary(isBn));
    buffer.writeln();
    if (tip.getQuickHack(isBn).isNotEmpty) {
      buffer.writeln('⚡ হ্যাক: ${tip.getQuickHack(isBn)}');
      buffer.writeln();
    }
    if (tip.getHomeRemedy(isBn).isNotEmpty) {
      buffer.writeln('🌿 ঘরোয়া প্রতিকার: ${tip.getHomeRemedy(isBn)}');
      buffer.writeln();
    }
    buffer.writeln('📱 RxDigi হেলথ অ্যাপ থেকে শেয়ারকৃত।');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBn ? 'টিপস ক্লিপবোর্ডে কপি করা হয়েছে' : 'Copied to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tip = widget.tip;
    final isBn = widget.isBn;
    final catColor = TipsTheme.getColor(tip.bodyPart.isNotEmpty ? tip.bodyPart : tip.category);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Indicator
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(PhosphorIconsFill.sparkle, color: Color(0xFFFBBF24), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isBn ? 'স্টোরি কার্ড এক্সপোর্ট' : 'Share as Story Card',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(PhosphorIconsBold.x, color: Colors.white70, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- The Printable / Capturable Story Card Widget ---
              Center(
                child: RepaintBoundary(
                  key: _boundaryKey,
                  child: Container(
                    width: 320,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF042F2E), // Deep Emerald Teal
                          Color(0xFF0F766E),
                          Color(0xFF115E59),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header: RxDigi Brand & Category
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(PhosphorIconsFill.pill, size: 13, color: Colors.white),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'RxDigi HEALTH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                tip.getCategory(isBn),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Tip Title
                        Text(
                          tip.getTitle(isBn),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tip Summary
                        Text(
                          tip.getSummary(isBn),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white.withValues(alpha: 0.9),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Highlight Box (Quick Hack or Home Remedy)
                        if (tip.getQuickHack(isBn).isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFBBF24).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('⚡', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip.getQuickHack(isBn),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFFEF3C7),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (tip.getHomeRemedy(isBn).isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD1FAE5).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🌿', style: TextStyle(fontSize: 14)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    tip.getHomeRemedy(isBn),
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD1FAE5),
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Card Footer: Verified & Watermark
                        Container(
                          padding: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(PhosphorIconsFill.sealCheck, size: 14, color: Color(0xFF34D399)),
                                  const SizedBox(width: 4),
                                  Text(
                                    isBn ? 'মেডিকেল ভেরিফাইড' : 'Verified Clinical Advice',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                isBn ? 'দৈনিক স্বাস্থ্য সহায়িকা' : 'RxDigi Health Guide',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Export Controls
              if (_isExporting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                )
              else
                Row(
                  children: [
                    // Copy Text button
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: _copyTipText,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(PhosphorIconsBold.copy, size: 16),
                        label: Text(
                          isBn ? 'কপি টেক্সট' : 'Copy Text',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Share Story button
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: _exportAndShareImage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        icon: const Icon(PhosphorIconsFill.instagramLogo, size: 18),
                        label: Text(
                          isBn ? 'স্টোরি কার্ড শেয়ার' : 'Share Story Card',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
