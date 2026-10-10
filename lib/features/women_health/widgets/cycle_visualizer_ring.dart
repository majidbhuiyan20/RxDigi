import 'dart:math';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../utils/women_health_formatters.dart';
import 'cycle_settings_sheet.dart';

class CycleVisualizerRing extends StatelessWidget {
  final MenstrualCycleModel cycle;
  final DateTime selectedDate;
  final CycleGoalMode goalMode;

  const CycleVisualizerRing({
    super.key,
    required this.cycle,
    this.goalMode = CycleGoalMode.trackCycle,
    required this.selectedDate,
  });

  Color _getPhaseColor(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstrual:
        return const Color(0xFFF43F5E); // Rose/Crimson
      case CyclePhase.follicular:
        return const Color(0xFFEC4899); // Pink
      case CyclePhase.fertileOvulation:
        return const Color(0xFF8B5CF6); // Purple/Violet
      case CyclePhase.luteal:
        return const Color(0xFFF59E0B); // Amber/Warm Gold
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    if (!cycle.isConfigured) {
      return GestureDetector(
        onTap: () {
          AppFeedback.playLight();
          CycleSettingsSheet.show(context, cycle);
        },
        child: Container(
          width: 250,
          height: 250,
          alignment: Alignment.center,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 230,
                height: 230,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.05),
                ),
              ),
              CustomPaint(
                size: const Size(220, 220),
                painter: _CycleRingPainter(
                  progress: 0.0,
                  phaseColor: const Color(0xFFF43F5E),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.calendarPlus,
                      color: Color(0xFFE11D48),
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBn ? 'সাইকেল শুরু করুন' : 'Start Cycle',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isBn ? 'শেষ পিরিয়ডের তারিখ দিন' : 'Set last period date',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(PhosphorIconsFill.pencilSimple, size: 11, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          isBn ? 'তারিখ নির্বাচন' : 'Set Date',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
    final targetDay = cycle.getCycleDayFor(selectedDate);
    final targetPhase = cycle.getPhaseFor(selectedDate);
    final phaseColor = _getPhaseColor(targetPhase);
    final progress = (targetDay / cycle.cycleLength).clamp(0.0, 1.0);
    final isToday = WomenHealthFormatters.isSameDay(selectedDate, DateTime.now());

    return Container(
      width: 250,
      height: 250,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft pulse circle
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: phaseColor.withValues(alpha: 0.05),
            ),
          ),

          // Custom Paint Radial Circular Ring
          CustomPaint(
            size: const Size(220, 220),
            painter: _CycleRingPainter(
              progress: progress,
              phaseColor: phaseColor,
            ),
          ),

          // Center Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isToday) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    WomenHealthFormatters.formatDayMonth(selectedDate, isBn: isBn),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
              ],
              Text(
                isBn
                    ? 'দিন ${WomenHealthFormatters.formatDigits(targetDay, isBn: true)}'
                    : 'Day $targetDay',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: phaseColor,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  targetPhase.name(isBn),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: phaseColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isToday
                    ? (isBn
                        ? 'পরবর্তী পিরিয়ড ${WomenHealthFormatters.formatDigits(cycle.daysUntilNextPeriod, isBn: true)} দিন পর'
                        : 'Next period in ${cycle.daysUntilNextPeriod}d')
                    : (isBn
                        ? 'সাইকেলের স্থায়িত্ব: ${WomenHealthFormatters.formatDigits(cycle.cycleLength, isBn: true)} দিন'
                        : 'Cycle Length: ${cycle.cycleLength}d'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                goalMode == CycleGoalMode.tryToConceive
                    ? (targetPhase == CyclePhase.fertileOvulation
                        ? (isBn ? '🌸 গর্ভধারণের সর্বোচ্চ সুযোগ' : '🌸 Peak Conception Window')
                        : (isBn ? 'গর্ভধারণের সম্ভাবনা: কম' : 'Chance of Pregnancy: Low'))
                    : targetPhase.pregnancyChance(isBn),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: goalMode == CycleGoalMode.tryToConceive &&
                          targetPhase == CyclePhase.fertileOvulation
                      ? const Color(0xFF8B5CF6)
                      : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final double progress;
  final Color phaseColor;

  _CycleRingPainter({
    required this.progress,
    required this.phaseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;

    // Background track paint
    final trackPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Active progress arc paint
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [
          phaseColor.withValues(alpha: 0.35),
          phaseColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      activePaint,
    );

    // Thumb dot indicator at the current day position (only if progress > 0)
    if (progress > 0.0) {
      final thumbAngle = -pi / 2 + sweepAngle;
      final thumbX = center.dx + radius * cos(thumbAngle);
      final thumbY = center.dy + radius * sin(thumbAngle);

      final thumbPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      final thumbBorderPaint = Paint()
        ..color = phaseColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2;

      canvas.drawCircle(Offset(thumbX, thumbY), 8, thumbPaint);
      canvas.drawCircle(Offset(thumbX, thumbY), 8, thumbBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phaseColor != phaseColor;
  }
}
