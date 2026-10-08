import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/habit_analytics_model.dart';
import '../provider/health_habit_provider.dart';

class HabitBarChart extends StatefulWidget {
  final List<DailyHabitStat> dailyStats;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool isBn;

  const HabitBarChart({
    super.key,
    required this.dailyStats,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isBn,
  });

  @override
  State<HabitBarChart> createState() => _HabitBarChartState();
}

class _HabitBarChartState extends State<HabitBarChart> {
  @override
  Widget build(BuildContext context) {
    if (widget.dailyStats.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedDateStr = habitDateString(widget.selectedDate);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.chartBar,
                      size: 18,
                      color: Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isBn ? 'সাপ্তাহিক রুটিন ট্রেন্ড' : 'Weekly Habit Performance',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        widget.isBn ? 'প্রতিদিনের টাস্ক সম্পন্নের হার (%)' : 'Daily Task Completion Rate (%)',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsBold.flagCheckered, size: 12, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      widget.isBn ? 'টার্গেট ৮০%' : 'Goal 80%',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Bar Chart
          AspectRatio(
            aspectRatio: 1.7,
            child: BarChart(
              BarChartData(
                maxY: 100,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF1E293B),
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final stat = widget.dailyStats[groupIndex];
                      final dayName = widget.isBn ? stat.dayNameBn : stat.dayNameEn;
                      return BarTooltipItem(
                        '$dayName\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${stat.completedCount}/${stat.totalHabits} ${widget.isBn ? "সম্পন্ন" : "done"} (${stat.percentage}%)',
                            style: TextStyle(
                              color: stat.isGood ? const Color(0xFF34D399) : const Color(0xFFFBBF24),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent && response != null && response.spot != null) {
                      final index = response.spot!.touchedBarGroupIndex;
                      if (index >= 0 && index < widget.dailyStats.length) {
                        HapticFeedback.selectionClick();
                        widget.onDateSelected(widget.dailyStats[index].date);
                      }
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 25,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 50 || value == 100) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF94A3B8),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < widget.dailyStats.length) {
                          final stat = widget.dailyStats[index];
                          final isSelected = stat.dateString == selectedDateStr;
                          final dayName = widget.isBn ? stat.dayNameBn : stat.dayNameEn;

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF0F766E) : Colors.transparent,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                  getDrawingHorizontalLine: (value) {
                    if (value == 80) {
                      // Goal line: dashed amber/green
                      return const FlLine(
                        color: Color(0xFF10B981),
                        strokeWidth: 1.2,
                        dashArray: [4, 4],
                      );
                    }
                    return FlLine(
                      color: const Color(0xFFF1F5F9),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: 80,
                      color: const Color(0xFF059669).withValues(alpha: 0.5),
                      strokeWidth: 1.2,
                      dashArray: [5, 4],
                    ),
                  ],
                ),
                barGroups: List.generate(widget.dailyStats.length, (index) {
                  final stat = widget.dailyStats[index];
                  final isSelected = stat.dateString == selectedDateStr;
                  final rate = stat.percentage.toDouble();

                  List<Color> gradientColors;
                  if (stat.isGood) {
                    gradientColors = const [Color(0xFF10B981), Color(0xFF059669)];
                  } else if (stat.isMedium) {
                    gradientColors = const [Color(0xFFF59E0B), Color(0xFFD97706)];
                  } else if (stat.completedCount > 0) {
                    gradientColors = const [Color(0xFF3B82F6), Color(0xFF2563EB)];
                  } else {
                    gradientColors = const [Color(0xFFE2E8F0), Color(0xFFCBD5E1)];
                  }

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: rate > 0 ? rate : 4,
                        gradient: LinearGradient(
                          colors: gradientColors,
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: isSelected ? 18 : 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100,
                          color: const Color(0xFFF8FAFC),
                        ),
                        borderSide: isSelected
                            ? const BorderSide(color: Color(0xFF0F766E), width: 1.5)
                            : BorderSide.none,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(const Color(0xFF10B981), widget.isBn ? '≥৮০% সম্পন্ন' : '≥80% Done'),
              const SizedBox(width: 14),
              _buildLegendDot(const Color(0xFFF59E0B), widget.isBn ? '৫০-৭৯%' : '50-79%'),
              const SizedBox(width: 14),
              _buildLegendDot(const Color(0xFF3B82F6), widget.isBn ? '<৫০%' : '<50%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
