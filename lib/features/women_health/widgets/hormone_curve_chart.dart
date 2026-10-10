import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/menstrual_cycle_model.dart';
import '../utils/women_health_formatters.dart';

class HormoneCurveChart extends StatefulWidget {
  final MenstrualCycleModel cycle;
  final int selectedDay;

  const HormoneCurveChart({
    super.key,
    required this.cycle,
    required this.selectedDay,
  });

  @override
  State<HormoneCurveChart> createState() => _HormoneCurveChartState();
}

class _HormoneCurveChartState extends State<HormoneCurveChart> {
  int? _scrubDay;
  int _activeHormoneFilter = 0; // 0: All, 1: Estrogen, 2: Progesterone, 3: LH

  int get _currentScrubDay => _scrubDay ?? widget.selectedDay.clamp(1, widget.cycle.cycleLength);

  String _getHormoneInsight(int day, int cycleLength) {
    final ovulation = cycleLength - 14;
    if (day <= 5) {
      return 'এস্ট্রোজেন ও প্রজেস্টেরন সর্বনিম্ন: শরীর বিশ্রাম চাইছে, আয়রন ও উষ্ণ পানীয় গ্রহণ করুন।';
    } else if (day < ovulation - 2) {
      return 'এস্ট্রোজেন ক্রমাগত বাড়ছে: কর্মশক্তি, শারীরিক স্ট্যামিনা ও আত্মবিশ্বাস তুঙ্গে থাকবে।';
    } else if (day <= ovulation + 1) {
      return 'LH স্পাইক ও এস্ট্রোজেন সর্বোচ্চ: ডিম্বস্ফোটন ঘটছে, ন্যাচারাল গ্লো ও উর্বরতা শীর্ষে।';
    } else if (day <= ovulation + 8) {
      return 'প্রজেস্টেরন হরমোন সর্বোচ্চ: শরীর শান্ত ও বিশ্রামের মোডে থাকে, তবে ঘুম ঘুম ভাব হতে পারে।';
    } else {
      return 'হরমোনের মাত্রা দ্রুত নামছে: পিএমএস (PMS) বা মিষ্টির ক্র্যাভিংস হতে পারে, ডার্ক চকলেট ও ফল খান।';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scrubDay = _currentScrubDay;
    final totalDays = widget.cycle.cycleLength;
    final insight = _getHormoneInsight(scrubDay, totalDays);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF43F5E).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.chartLineUp,
                      size: 18,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'হরমোন লেভেল ও বায়ো-কার্ভ',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'দিন ${WomenHealthFormatters.toBengaliDigits(scrubDay)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Filter Chips (All, Estrogen, Progesterone, LH)
          Row(
            children: [
              _buildFilterChip(0, 'সকল হরমোন', const Color(0xFF0F172A)),
              const SizedBox(width: 6),
              _buildFilterChip(1, 'এস্ট্রোজেন', const Color(0xFFEC4899)),
              const SizedBox(width: 6),
              _buildFilterChip(2, 'প্রজেস্টেরন', const Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              _buildFilterChip(3, 'এলএইচ', const Color(0xFF8B5CF6)),
            ],
          ),

          const SizedBox(height: 14),

          // Interactive Touch Scrubber Curve Chart Canvas
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final localX = details.localPosition.dx.clamp(0.0, box.size.width - 36);
                final fraction = localX / (box.size.width - 36);
                final day = (fraction * totalDays).round().clamp(1, totalDays);
                if (_scrubDay != day) {
                  HapticFeedback.selectionClick();
                  setState(() => _scrubDay = day);
                }
              }
            },
            onTapDown: (details) {
              final box = context.findRenderObject() as RenderBox?;
              if (box != null) {
                final localX = details.localPosition.dx.clamp(0.0, box.size.width - 36);
                final fraction = localX / (box.size.width - 36);
                final day = (fraction * totalDays).round().clamp(1, totalDays);
                HapticFeedback.selectionClick();
                setState(() => _scrubDay = day);
              }
            },
            child: SizedBox(
              height: 140,
              width: double.infinity,
              child: CustomPaint(
                painter: _HormoneGraphPainter(
                  cycleLength: totalDays,
                  scrubDay: scrubDay,
                  filterMode: _activeHormoneFilter,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // X-Axis Phase Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('দিন ১ (পিরিয়ড)', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
              Text('দিন ১৪ (ওভুলেশন)', style: TextStyle(fontSize: 10.5, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w700)),
              Text('দিন ২৮ (পরবর্তী)', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
            ],
          ),

          const SizedBox(height: 12),

          // Dynamic Biological Insight Callout Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  PhosphorIconsFill.sparkle,
                  size: 15,
                  color: Color(0xFF8B5CF6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    insight,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int id, String label, Color color) {
    final isSelected = _activeHormoneFilter == id;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _activeHormoneFilter = id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _HormoneGraphPainter extends CustomPainter {
  final int cycleLength;
  final int scrubDay;
  final int filterMode; // 0: All, 1: Estrogen, 2: Progesterone, 3: LH

  _HormoneGraphPainter({
    required this.cycleLength,
    required this.scrubDay,
    required this.filterMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Draw baseline horizontal dashed grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, h * 0.25), Offset(w, h * 0.25), gridPaint);
    canvas.drawLine(Offset(0, h * 0.50), Offset(w, h * 0.50), gridPaint);
    canvas.drawLine(Offset(0, h * 0.75), Offset(w, h * 0.75), gridPaint);

    // Fertile window background glow
    final ovDay = cycleLength - 14;
    final ovStartRatio = ((ovDay - 4) / cycleLength).clamp(0.0, 1.0);
    final ovEndRatio = ((ovDay + 1) / cycleLength).clamp(0.0, 1.0);
    final fertileRect = Rect.fromLTRB(w * ovStartRatio, 0, w * ovEndRatio, h);
    final fertilePaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(fertileRect, const Radius.circular(8)), fertilePaint);

    // Draw Curves
    if (filterMode == 0 || filterMode == 1) {
      _drawHormoneCurve(
        canvas: canvas,
        size: size,
        color: const Color(0xFFEC4899),
        generator: (day) => _getEstrogenValue(day, cycleLength),
      );
    }
    if (filterMode == 0 || filterMode == 2) {
      _drawHormoneCurve(
        canvas: canvas,
        size: size,
        color: const Color(0xFFF59E0B),
        generator: (day) => _getProgesteroneValue(day, cycleLength),
      );
    }
    if (filterMode == 0 || filterMode == 3) {
      _drawHormoneCurve(
        canvas: canvas,
        size: size,
        color: const Color(0xFF8B5CF6),
        generator: (day) => _getLhValue(day, cycleLength),
      );
    }

    // Scrubber indicator line
    final scrubRatio = ((scrubDay - 1) / (cycleLength - 1)).clamp(0.0, 1.0);
    final scrubX = w * scrubRatio;

    final scrubLinePaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..strokeWidth = 1.6;

    // Draw dashed scrubber line
    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < h) {
      canvas.drawLine(
        Offset(scrubX, startY),
        Offset(scrubX, min(startY + dashHeight, h)),
        scrubLinePaint,
      );
      startY += dashHeight + dashSpace;
    }

    // Thumb dot on scrubber top
    final dotPaint = Paint()..color = const Color(0xFF0F172A);
    canvas.drawCircle(Offset(scrubX, h - 4), 4.5, dotPaint);
  }

  void _drawHormoneCurve({
    required Canvas canvas,
    required Size size,
    required Color color,
    required double Function(double day) generator,
  }) {
    final path = Path();
    final points = <Offset>[];
    const steps = 60;

    for (int i = 0; i <= steps; i++) {
      final day = 1 + (i / steps) * (cycleLength - 1);
      final val = generator(day).clamp(0.0, 1.0); // 0.0 bottom, 1.0 peak
      final x = (i / steps) * size.width;
      final y = size.height - (val * (size.height - 18)) - 8;
      points.add(Offset(x, y));
    }

    if (points.isEmpty) return;
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      final midY = (p0.dy + p1.dy) / 2;
      path.quadraticBezierTo(p0.dx, p0.dy, midX, midY);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  // Estrogen mathematical model: peak at ovulation, moderate peak in luteal
  double _getEstrogenValue(double day, int total) {
    final ov = total - 14.0;
    // Pre-ovulation peak at (ov - 1)
    final peak1 = exp(-pow((day - (ov - 1)) / 3.0, 2)) * 0.95;
    // Luteal peak around (ov + 7)
    final peak2 = exp(-pow((day - (ov + 6.5)) / 3.5, 2)) * 0.60;
    return max(0.12, max(peak1, peak2));
  }

  // Progesterone model: flat during follicular, big surge during mid-luteal
  double _getProgesteroneValue(double day, int total) {
    final ov = total - 14.0;
    if (day <= ov) return 0.06;
    // Surges between ov and total, peaking at ov + 7
    final lutealPeak = exp(-pow((day - (ov + 6.5)) / 4.0, 2)) * 0.88;
    return max(0.06, lutealPeak);
  }

  // LH model: baseline ~0.08, extreme narrow spike at (ov - 1)
  double _getLhValue(double day, int total) {
    final ov = total - 14.0;
    final spike = exp(-pow((day - (ov - 1)) / 1.0, 2)) * 1.0;
    return max(0.06, spike);
  }

  @override
  bool shouldRepaint(covariant _HormoneGraphPainter oldDelegate) {
    return oldDelegate.scrubDay != scrubDay ||
        oldDelegate.filterMode != filterMode ||
        oldDelegate.cycleLength != cycleLength;
  }
}

