import 'dart:math';
import 'package:flutter/material.dart';
import '../models/menstrual_cycle_model.dart';

class CycleVisualizerRing extends StatelessWidget {
  final MenstrualCycleModel cycle;

  const CycleVisualizerRing({
    super.key,
    required this.cycle,
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
    final phaseColor = _getPhaseColor(cycle.currentPhase);

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
              color: phaseColor.withOpacity(0.04),
            ),
          ),

          // Custom Paint Radial Circular Ring
          CustomPaint(
            size: const Size(220, 220),
            painter: _CycleRingPainter(
              progress: cycle.cycleProgress,
              phaseColor: phaseColor,
            ),
          ),

          // Center Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isBn ? 'দিন ${cycle.currentCycleDay}' : 'Day ${cycle.currentCycleDay}',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: phaseColor,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isBn ? cycle.currentPhase.nameBn : cycle.currentPhase.nameEn,
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
                isBn
                    ? 'পরবর্তী পিরিয়ড ${cycle.daysUntilNextPeriod} দিন পর'
                    : 'Next period in ${cycle.daysUntilNextPeriod}d',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cycle.currentPhase.pregnancyChanceBn,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
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
          phaseColor.withOpacity(0.4),
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

    // Thumb dot indicator at the current day position
    final thumbAngle = -pi / 2 + sweepAngle;
    final thumbX = center.dx + radius * cos(thumbAngle);
    final thumbY = center.dy + radius * sin(thumbAngle);

    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final thumbBorderPaint = Paint()
      ..color = phaseColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(thumbX, thumbY), 8, thumbPaint);
    canvas.drawCircle(Offset(thumbX, thumbY), 8, thumbBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.phaseColor != phaseColor;
  }
}

