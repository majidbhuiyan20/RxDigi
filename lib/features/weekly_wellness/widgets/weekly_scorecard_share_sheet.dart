import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/weekly_wellness_score_model.dart';
import '../../../core/utils/app_feedback.dart';

class WeeklyScorecardShareSheet extends StatefulWidget {
  final WeeklyWellnessScoreModel scoreModel;
  final bool isBn;

  const WeeklyScorecardShareSheet({
    super.key,
    required this.scoreModel,
    required this.isBn,
  });

  static Future<void> show(BuildContext context, WeeklyWellnessScoreModel scoreModel, bool isBn) {
    AppFeedback.playCelebration();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WeeklyScorecardShareSheet(scoreModel: scoreModel, isBn: isBn),
    );
  }

  @override
  State<WeeklyScorecardShareSheet> createState() => _WeeklyScorecardShareSheetState();
}

class _WeeklyScorecardShareSheetState extends State<WeeklyScorecardShareSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isExporting = false;

  Future<void> _exportAndShare() async {
    setState(() => _isExporting = true);
    AppFeedback.playSuccess();
    try {
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Boundary not found');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('Failed to generate PNG');

      final pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/RxDigi_Weekly_Score_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      final caption = widget.isBn
          ? '🏆 গত সপ্তাহে আমার RxDigi স্বাস্থ্য স্কোর: ${widget.scoreModel.score}/100 (গ্রেড: ${widget.scoreModel.grade})\n\n💊 নিয়মিত ওষুধ ও সুস্থ জীবনযাত্রায় আমার সঙ্গী RxDigi!'
          : '🏆 My weekly RxDigi Health Score: ${widget.scoreModel.score}/100 (Grade: ${widget.scoreModel.grade})\n\nTrack your wellness with RxDigi!';

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: caption,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('শেয়ার করতে সমস্যা হয়েছে: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = widget.scoreModel;
    final isBn = widget.isBn;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🌟', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'সাপ্তাহিক স্বাস্থ্য স্কোরকার্ড' : 'Weekly Wellness Card',
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Visual RepaintBoundary Story / Social Card
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: RepaintBoundary(
                key: _cardKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0B192C),
                        Color(0xFF1E3E62),
                        Color(0xFF004D40),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Card Top Bar: RxDigi Logo & Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  PhosphorIconsFill.shieldCheck,
                                  color: Color(0xFF34D399),
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'RxDigi Health',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              isBn ? 'সাপ্তাহিক রিক্যাপ' : 'Weekly Digest',
                              style: const TextStyle(
                                color: Color(0xFFFDE047),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Trophy & Big Score Display
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF59E0B).withOpacity(0.15),
                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3), width: 2),
                        ),
                        child: const Text('🏆', style: TextStyle(fontSize: 42)),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${model.score}',
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '/100',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              model.grade,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Text(
                        model.headlineBn,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFDE047),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          model.summaryBn,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 16),

                      // 4 Pillars Stats Grid
                      Row(
                        children: [
                          _buildCardStat(
                            emoji: '💊',
                            value: '${model.medicinePercent}%',
                            label: isBn ? 'মেডিসিন রুটিন' : 'Medicine',
                          ),
                          _buildCardStat(
                            emoji: '💧',
                            value: '${model.waterDaysAchieved}/7',
                            label: isBn ? 'পানি পান' : 'Hydration',
                          ),
                          _buildCardStat(
                            emoji: '🔥',
                            value: '${model.streakDays} দিন',
                            label: isBn ? 'স্ট্রিক' : 'Streak',
                          ),
                          _buildCardStat(
                            emoji: '🩺',
                            value: '${model.vitalsLoggedCount} বার',
                            label: isBn ? 'স্বাস্থ্য চেক' : 'Vitals',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Badges Section
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: model.badges.where((b) => b.isUnlocked).map((b) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(b.emoji, style: const TextStyle(fontSize: 13)),
                                const SizedBox(width: 5),
                                Text(
                                  b.titleBn,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Share to WhatsApp/Story
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportAndShare,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(PhosphorIconsBold.shareNetwork, size: 20, color: Colors.white),
              label: Text(
                _isExporting
                    ? (isBn ? 'ইমেজ তৈরি হচ্ছে...' : 'Generating Image...')
                    : (isBn ? 'স্টোরি বা হোয়াটসঅ্যাপে শেয়ার করুন' : 'Share to WhatsApp & Stories'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
