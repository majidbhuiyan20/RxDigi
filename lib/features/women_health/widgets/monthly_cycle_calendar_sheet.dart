import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../utils/women_health_formatters.dart';

class MonthlyCycleCalendarSheet extends ConsumerStatefulWidget {
  final MenstrualCycleModel cycle;

  const MonthlyCycleCalendarSheet({
    super.key,
    required this.cycle,
  });

  static Future<void> show(BuildContext context, MenstrualCycleModel cycle) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthlyCycleCalendarSheet(cycle: cycle),
    );
  }

  @override
  ConsumerState<MonthlyCycleCalendarSheet> createState() =>
      _MonthlyCycleCalendarSheetState();
}

class _MonthlyCycleCalendarSheetState
    extends ConsumerState<MonthlyCycleCalendarSheet> {
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final selected = ref.read(selectedCycleDateProvider);
    _focusedMonth = DateTime(selected.year, selected.month, 1);
  }

  void _prevMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    HapticFeedback.selectionClick();
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final selectedDate = ref.watch(selectedCycleDateProvider);
    final symptomsMap = ref.watch(dailySymptomProvider);
    final today = DateTime.now();

    final year = _focusedMonth.year;
    final month = _focusedMonth.month;
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // 1 = Monday, 7 = Sunday
    final startingWeekdayOffset = firstDayOfMonth.weekday - 1;

    final totalGridCells = startingWeekdayOffset + daysInMonth;
    final rowCount = (totalGridCells / 7).ceil();

    final monthTitle = isBn
        ? '${WomenHealthFormatters.formatDayMonth(firstDayOfMonth, isBn: true).split(' ').last} ${WomenHealthFormatters.formatDigits(year, isBn: true)}'
        : '${WomenHealthFormatters.formatDayMonth(firstDayOfMonth, isBn: false).split(' ').last} $year';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 14),

          // Header: Navigation & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.calendarDots,
                      color: Color(0xFFF43F5E),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    monthTitle,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(PhosphorIconsBold.caretLeft, size: 18),
                    onPressed: _prevMonth,
                    tooltip: isBn ? 'পূর্ববর্তী মাস' : 'Previous Month',
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsBold.caretRight, size: 18),
                    onPressed: _nextMonth,
                    tooltip: isBn ? 'পরবর্তী মাস' : 'Next Month',
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsRegular.x, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (!widget.cycle.isConfigured) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsFill.info, size: 16, color: Color(0xFFE11D48)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'সাইকেল সেটআপ করা হয়নি। পিরিয়ড ও ওভুলেশনের দিন দেখতে সাইকেল সেট করুন।'
                          : 'Cycle not configured. Set up your cycle to preview period and fertile windows.',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF9F1239)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Weekday Labels
          Row(
            children: [
              _WeekdayLabel(isBn ? 'সোম' : 'Mon'),
              _WeekdayLabel(isBn ? 'মঙ্গল' : 'Tue'),
              _WeekdayLabel(isBn ? 'বুধ' : 'Wed'),
              _WeekdayLabel(isBn ? 'বৃহঃ' : 'Thu'),
              _WeekdayLabel(isBn ? 'শুক্র' : 'Fri'),
              _WeekdayLabel(isBn ? 'শনি' : 'Sat'),
              _WeekdayLabel(isBn ? 'রবি' : 'Sun'),
            ],
          ),

          const SizedBox(height: 8),

          // Calendar Days Grid
          Flexible(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: rowCount * 7,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final dayNumber = index - startingWeekdayOffset + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox();
                }

                final cellDate = DateTime(year, month, dayNumber);
                final isSelected = WomenHealthFormatters.isSameDay(cellDate, selectedDate);
                final isToday = WomenHealthFormatters.isSameDay(cellDate, today);

                final isPeriod = widget.cycle.isConfigured && widget.cycle.isPeriodDay(cellDate);
                final isFertile = widget.cycle.isConfigured && widget.cycle.isFertileDay(cellDate);
                final isOvulation = widget.cycle.isConfigured && widget.cycle.isOvulationDay(cellDate);

                final dateKey = WomenHealthFormatters.toDateKey(cellDate);
                final hasSymptom = symptomsMap.containsKey(dateKey);

                Color cellBg = const Color(0xFFF8FAFC);
                Color textColor = const Color(0xFF1E293B);
                Border? border;

                if (isSelected) {
                  cellBg = const Color(0xFF0F172A);
                  textColor = Colors.white;
                } else if (isPeriod) {
                  cellBg = const Color(0xFFFFF1F2);
                  textColor = const Color(0xFFBE123C);
                  border = Border.all(color: const Color(0xFFFECDD3));
                } else if (isOvulation) {
                  cellBg = const Color(0xFFF5F3FF);
                  textColor = const Color(0xFF6D28D9);
                  border = Border.all(color: const Color(0xFFDDD6FE), width: 1.5);
                } else if (isFertile) {
                  cellBg = const Color(0xFFFAF5FF);
                  textColor = const Color(0xFF7E22CE);
                }

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(selectedCycleDateProvider.notifier).selectDate(cellDate);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cellBg,
                      borderRadius: BorderRadius.circular(12),
                      border: border,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          WomenHealthFormatters.formatDigits(dayNumber, isBn: isBn),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday || isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isPeriod)
                              const Icon(
                                PhosphorIconsFill.drop,
                                size: 9,
                                color: Color(0xFFF43F5E),
                              )
                            else if (isOvulation)
                              const Icon(
                                PhosphorIconsFill.flowerLotus,
                                size: 9,
                                color: Color(0xFF8B5CF6),
                              )
                            else if (isFertile)
                              Container(
                                width: 4.5,
                                height: 4.5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFA855F7),
                                ),
                              )
                            else
                              const SizedBox(height: 9),
                            if (hasSymptom) ...[
                              const SizedBox(width: 2),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF0284C7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Legend Guide
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _buildLegendItem(const Color(0xFFF43F5E), isBn ? 'পিরিয়ড দিন' : 'Period Day'),
                _buildLegendItem(const Color(0xFFA855F7), isBn ? 'উর্বর সময়' : 'Fertile Window'),
                _buildLegendItem(const Color(0xFF6D28D9), isBn ? 'ডিম্বস্ফোটন (Peak)' : 'Ovulation (Peak)'),
                _buildLegendItem(const Color(0xFF0284C7), isBn ? 'লক্ষণ রেকর্ডকৃত' : 'Logged Symptoms'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}
