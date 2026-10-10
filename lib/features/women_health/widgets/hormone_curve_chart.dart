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

  String _getHormoneInsight(int day, int cycleLength, bool isBn) {
    final ovulation = cycleLength - 14;
    if (day <= 5) {
      return isBn
          ? 'এস্ট্রোজেন ও প্রজেস্টেরন সর্বনিম্ন: শরীর বিশ্রাম চাইছে, আয়রন ও উষ্ণ পানীয় গ্রহণ করুন।'
          : 'Estrogen & Progesterone are at baseline: Prioritize restful sleep, warm hydration, and iron-dense nourishment.';
    } else if (day < ovulation - 2) {
      return isBn
          ? 'এস্ট্রোজেন ক্রমাগত বাড়ছে: কর্মশক্তি, শারীরিক স্ট্যামিনা ও আত্মবিশ্বাস তুঙ্গে থাকবে।'
          : 'Estrogen is steadily rising: Peak physical endurance, cognitive focus, and workout stamina.';
    } else if (day <= ovulation + 1) {
      return isBn
          ? 'LH স্পাইক ও এস্ট্রোজেন সর্বোচ্চ: ডিম্বস্ফোটন ঘটছে, ন্যাচারাল গ্লো ও উর্বরতা শীর্ষে।'
          : 'Luteinizing Hormone (LH) surge & peak Estrogen: Ovulation window, elevated mood, and maximal fertility.';
    } else if (day <= ovulation + 8) {
      return isBn
          ? 'প্রজেস্টেরন হরমোন সর্বোচ্চ: শরীর শান্ত ও বিশ্রামের মোডে থাকে, তবে ঘুম ঘুম ভাব হতে পারে।'
          : 'Progesterone dominates: Metabolism increases, calming effect on the nervous system, potential mild fatigue.';
    } else {
      return isBn
          ? 'হরমোনের মাত্রা দ্রুত নামছে: পিএমএস (PMS) বা মিষ্টির ক্র্যাভিংস হতে পারে, ডার্ক চকলেট ও ফল খান।'
          : 'Hormones drop pre-period: PMS or cravings may occur; magnesium-rich foods and light stretching recommended.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final scrubDay = _currentScrubDay;
    final totalDays = widget.cycle.cycleLength;
    final insight = _getHormoneInsight(scrubDay, totalDays, isBn);

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
                  Text(
                    isBn ? 'হরমোন লেভেল ও বায়ো-কার্ভ' : 'Hormone Curve & Bio-Chart',
                    style: const TextStyle(
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
                  '${isBn ? "দিন " : "Day "}${WomenHealthFormatters.formatDigits(scrubDay, isBn: isBn)}',
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
              _buildFilterChip(0, isBn ? 'সকল' : 'All', const Color(0xFF0F172A)),
              const SizedBox(width: 6),
              _buildFilterChip(1, isBn ? 'এস্ট্রোজেন' : 'Estrogen', const Color(0xFFEC4899)),
              const SizedBox(width: 6),
              _buildFilterChip(2, isBn ? 'প্রজেস্টেরন' : 'Progesterone', const Color(0xFFF59E0B)),
              const SizedBox(width: 6),
              _buildFilterChip(3, isBn ? 'এলএইচ' : 'LH', const Color(0xFF8B5CF6)),
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
            children: [
              Text(
                isBn ? 'দিন ১ (পিরিয়ড)' : 'Day 1 (Period)',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
              Text(
                isBn ? 'দিন ১৪ (ওভুলেশন)' : 'Day 14 (Ovulation)',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF8B5CF6), fontWeight: FontWeight.w700),
              ),
              Text(
                '${isBn ? "দিন " : "Day "}${WomenHealthFormatters.formatDigits(totalDays, isBn: isBn)}',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
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
  final int filterMode;

  _HormoneGraphPainter({
    required this.cycleLength,
    required this.scrubDay,
    required this.filterMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final ovulationDay = (cycleLength - 14).toDouble();

    // Estrogen Curve: Peaks around Day (ovulation - 1), dips, secondary mid-luteal wave
    final estrogenPath = Path();
    // Progesterone Curve: Low during follicular, surges mid-luteal
    final progesteronePath = Path();
    // LH (Luteinizing Hormone): Flat, sharp spike 24-36h before ovulation
    final lhPath = Path();

    for (int day = 1; day <= cycleLength; day++) {
      final x = ((day - 1) / (cycleLength - 1)) * w;

      // Estrogen normalization (0.0 to 1.0)
      final dOvu = (day - (ovulationDay - 1));
      final folPeak = 0.85 * exp(-pow(dOvu / 3.5, 2));
      final lutPeak = 0.50 * exp(-pow((day - (ovulationDay + 7)) / 4.0, 2));
      final estrogenVal = (0.15 + folPeak + lutPeak).clamp(0.08, 0.95);
      final yEstrogen = h - (estrogenVal * h * 0.85) - 6;

      // Progesterone normalization
      final progPeak = 0.90 * exp(-pow((day - (ovulationDay + 7)) / 3.8, 2));
      final progVal = (0.05 + progPeak).clamp(0.05, 0.95);
      final yProg = h - (progVal * h * 0.85) - 6;

      // LH normalization: sharp spike on ovulation day
      final lhSpike = 0.95 * exp(-pow((day - ovulationDay) / 1.1, 2));
      final lhVal = (0.06 + lhSpike).clamp(0.06, 0.95);
      final yLh = h - (lhVal * h * 0.85) - 6;

      if (day == 1) {
        estrogenPath.moveTo(x, yEstrogen);
        progesteronePath.moveTo(x, yProg);
        lhPath.moveTo(x, yLh);
      } else {
        estrogenPath.lineTo(x, yEstrogen);
        progesteronePath.lineTo(x, yProg);
        lhPath.lineTo(x, yLh);
      }
    }

    // Paint Lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.8;

    // Draw Estrogen (Pink)
    if (filterMode == 0 || filterMode == 1) {
      linePaint.color = const Color(0xFFEC4899);
      canvas.drawPath(estrogenPath, linePaint);
    }

    // Draw Progesterone (Amber)
    if (filterMode == 0 || filterMode == 2) {
      linePaint.color = const Color(0xFFF59E0B);
      canvas.drawPath(progesteronePath, linePaint);
    }

    // Draw LH (Purple)
    if (filterMode == 0 || filterMode == 3) {
      linePaint.color = const Color(0xFF8B5CF6);
      canvas.drawPath(lhPath, linePaint);
    }

    // Draw Scrub Indicator Vertical Line & Day Pin
    final scrubX = ((scrubDay - 1) / (cycleLength - 1)) * w;
    final scrubPaint = Paint()
      ..color = const Color(0xFF0F172A).withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(scrubX, 4), Offset(scrubX, h), scrubPaint);

    final pinPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(scrubX, 4), 4.5, pinPaint);
    pinPaint.color = Colors.white;
    canvas.drawCircle(Offset(scrubX, 4), 2.2, pinPaint);
  }

  @override
  bool shouldRepaint(covariant _HormoneGraphPainter oldDelegate) {
    return oldDelegate.cycleLength != cycleLength ||
        oldDelegate.scrubDay != scrubDay ||
        oldDelegate.filterMode != filterMode;
  }
}
