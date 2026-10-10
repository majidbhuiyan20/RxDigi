import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/pregnancy_model.dart';
import '../provider/pregnancy_provider.dart';
import '../utils/women_health_formatters.dart';

class FetalKickCounterSheet extends ConsumerStatefulWidget {
  const FetalKickCounterSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FetalKickCounterSheet(),
    );
  }

  @override
  ConsumerState<FetalKickCounterSheet> createState() =>
      _FetalKickCounterSheetState();
}

class _FetalKickCounterSheetState extends ConsumerState<FetalKickCounterSheet> {
  int _kicks = 0;
  Timer? _timer;
  int _secondsElapsed = 0;
  bool _isSessionActive = false;
  bool _isCompleted = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerIfNeeded() {
    if (!_isSessionActive) {
      _isSessionActive = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() => _secondsElapsed++);
      });
    }
  }

  void _recordKick(bool isBn) {
    if (_isCompleted) return;

    HapticFeedback.heavyImpact();
    AppFeedback.playLight();
    _startTimerIfNeeded();

    setState(() {
      _kicks++;
      if (_kicks >= 10) {
        _isCompleted = true;
        _timer?.cancel();
        _saveSession(isBn);
      }
    });
  }

  Future<void> _saveSession(bool isBn) async {
    AppFeedback.playSuccess();
    final minutes = (_secondsElapsed / 60).ceil().clamp(1, 120);
    final log = KickCounterLog(
      id: 'kick_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      durationMinutes: minutes,
      kickCount: _kicks,
      notes: isBn
          ? '$minutes মিনিটে ১০টি পূর্ণ কিক রেকর্ড হয়েছে'
          : '10 kicks completed in $minutes mins',
    );
    await ref.read(kickCounterLogsProvider.notifier).addLog(log);
  }

  void _resetSession() {
    AppFeedback.playLight();
    _timer?.cancel();
    setState(() {
      _kicks = 0;
      _secondsElapsed = 0;
      _isSessionActive = false;
      _isCompleted = false;
    });
  }

  String _formatTime(int seconds, bool isBn) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mStr = m.toString().padLeft(2, '0');
    final sStr = s.toString().padLeft(2, '0');
    final formatted = '$mStr:$sStr';
    return isBn ? WomenHealthFormatters.formatDigits(formatted, isBn: true) : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final history = ref.watch(kickCounterLogsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
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
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.footprints,
                      color: Color(0xFFE11D48),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'ফিটাল কিক কাউন্টার' : 'Fetal Kick Counter',
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isBn ? '১০টি নড়াচড়ার সময়কাল রেকর্ড করুন' : 'Count 10 movements under 2 hours',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(PhosphorIconsRegular.x, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const Divider(height: 20),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // Info Reassurance Banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(PhosphorIconsFill.heartbeat, color: Color(0xFF16A34A), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isBn
                              ? 'খাবার বা পানি খাওয়ার পর শান্ত হয়ে বসুন বা বাম কাতে শুয়ে বাচ্চার প্রতিটি লাথি বা নড়াচড়ায় ট্যাপ করুন।'
                              : 'Rest comfortably on your left side after a meal. Tap the circle every time you feel a distinct movement.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            height: 1.4,
                            color: Color(0xFF15803D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Main Interactive Counter Circle
                Center(
                  child: GestureDetector(
                    onTap: () => _recordKick(isBn),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isCompleted
                              ? [const Color(0xFF10B981), const Color(0xFF059669)]
                              : [const Color(0xFFF43F5E), const Color(0xFFE11D48)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isCompleted
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFF43F5E))
                                .withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isCompleted
                                ? PhosphorIconsFill.checkCircle
                                : PhosphorIconsFill.footprints,
                            color: Colors.white,
                            size: 38,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${WomenHealthFormatters.formatDigits(_kicks, isBn: isBn)} / ${WomenHealthFormatters.formatDigits(10, isBn: isBn)}',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isCompleted
                                ? (isBn ? 'সম্পন্ন হয়েছে!' : 'Completed!')
                                : (isBn ? 'ট্যাপ করুন' : 'Tap to Count'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Timer & Controls Row
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(PhosphorIconsRegular.timer, size: 16, color: Color(0xFF475569)),
                            const SizedBox(width: 6),
                            Text(
                              _formatTime(_secondsElapsed, isBn),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _resetSession,
                        icon: const Icon(PhosphorIconsRegular.arrowsCounterClockwise, size: 14),
                        label: Text(
                          isBn ? 'নতুন করে শুরু করুন' : 'Reset Session',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // History Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn ? 'বিগত কিক সেশনের রেকর্ড:' : 'Past Kick Sessions:',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF334155),
                      ),
                    ),
                    Text(
                      '${history.length} ${isBn ? "টি সেশন" : "logs"}',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        isBn ? 'এখনও কোনো কিক সেশন রেকর্ড করা হয়নি' : 'No recorded sessions yet',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  ...history.map((h) => _buildHistoryItem(h, isBn)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(KickCounterLog item, bool isBn) {
    final dateStr = WomenHealthFormatters.formatDayMonth(item.timestamp, isBn: isBn);
    final timeStr = '${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsFill.check, color: Color(0xFF059669), size: 14),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dateStr • $timeStr',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (item.notes != null)
                    Text(
                      item.notes!,
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${WomenHealthFormatters.formatDigits(item.durationMinutes, isBn: isBn)} ${isBn ? "মিনিট" : "min"}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0284C7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
