import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../utils/women_health_formatters.dart';
import 'monthly_cycle_calendar_sheet.dart';

class HorizontalCycleDateStrip extends ConsumerStatefulWidget {
  final MenstrualCycleModel cycle;

  const HorizontalCycleDateStrip({
    super.key,
    required this.cycle,
  });

  @override
  ConsumerState<HorizontalCycleDateStrip> createState() =>
      _HorizontalCycleDateStripState();
}

class _HorizontalCycleDateStripState
    extends ConsumerState<HorizontalCycleDateStrip> {
  late final ScrollController _scrollController;
  final int _pastDays = 14;
  final int _futureDays = 21;
  late final List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(
      _pastDays + _futureDays + 1,
      (index) => today.add(Duration(days: index - _pastDays)),
    );
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToToday();
    });
  }

  void _scrollToToday() {
    if (_scrollController.hasClients) {
      // Each item width is ~58 + 8 margin = 66
      final targetOffset = (_pastDays * 66.0) - 130;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedCycleDateProvider);
    final symptomsMap = ref.watch(dailySymptomProvider);
    final today = DateTime.now();
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Month / Year + "Full Month Calendar" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      PhosphorIconsRegular.calendarCheck,
                      size: 16,
                      color: Color(0xFFBE123C),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      WomenHealthFormatters.formatDayMonth(selectedDate, isBn: isBn),
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (!WomenHealthFormatters.isSameDay(selectedDate, today)) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          ref.read(selectedCycleDateProvider.notifier).resetToToday();
                          _scrollToToday();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isBn ? 'আজকে ফিরে যান' : 'Go to Today',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    MonthlyCycleCalendarSheet.show(context, widget.cycle);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          PhosphorIconsFill.calendarBlank,
                          size: 14,
                          color: Color(0xFFE11D48),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isBn ? 'পুরো ক্যালেন্ডার' : 'Month View',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBE123C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Horizontal Date Strip
          SizedBox(
            height: 82,
            child: ListView.separated(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _dates.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final date = _dates[index];
                final isSelected = WomenHealthFormatters.isSameDay(date, selectedDate);
                final isToday = WomenHealthFormatters.isSameDay(date, today);

                final isPeriod = widget.cycle.isConfigured && widget.cycle.isPeriodDay(date);
                final isFertile = widget.cycle.isConfigured && widget.cycle.isFertileDay(date);
                final isOvulation = widget.cycle.isConfigured && widget.cycle.isOvulationDay(date);

                final dateKey = WomenHealthFormatters.toDateKey(date);
                final hasSymptom = symptomsMap.containsKey(dateKey);

                Color badgeBg = Colors.white;
                Color borderColor = const Color(0xFFE2E8F0);
                if (isSelected) {
                  badgeBg = const Color(0xFF0F172A);
                  borderColor = const Color(0xFF0F172A);
                } else if (isPeriod) {
                  badgeBg = const Color(0xFFFFF1F2);
                  borderColor = const Color(0xFFFECDD3);
                } else if (isOvulation) {
                  badgeBg = const Color(0xFFF5F3FF);
                  borderColor = const Color(0xFFDDD6FE);
                } else if (isFertile) {
                  badgeBg = const Color(0xFFFAF5FF);
                  borderColor = const Color(0xFFE9D5FF);
                }

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(selectedCycleDateProvider.notifier).selectDate(date);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 55,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: borderColor,
                        width: isSelected ? 2.0 : 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Weekday text
                        Text(
                          WomenHealthFormatters.getWeekday(date, isBn: isBn),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white70
                                : (isToday ? const Color(0xFFF43F5E) : const Color(0xFF64748B)),
                          ),
                        ),

                        // Day number
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: isToday && !isSelected
                              ? BoxDecoration(
                                  color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                )
                              : null,
                          child: Text(
                            WomenHealthFormatters.formatDigits(date.day, isBn: isBn),
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? Colors.white
                                  : (isToday ? const Color(0xFFF43F5E) : const Color(0xFF1E293B)),
                            ),
                          ),
                        ),

                        // Phase & Symptom Indicator Micro-icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isPeriod)
                              const Icon(
                                PhosphorIconsFill.drop,
                                size: 10,
                                color: Color(0xFFF43F5E),
                              )
                            else if (isOvulation)
                              const Icon(
                                PhosphorIconsFill.flowerLotus,
                                size: 10,
                                color: Color(0xFF8B5CF6),
                              )
                            else if (isFertile)
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFFA855F7),
                                ),
                              )
                            else
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? Colors.white30 : const Color(0xFFCBD5E1),
                                ),
                              ),
                            if (hasSymptom) ...[
                              const SizedBox(width: 2.5),
                              Container(
                                width: 4.5,
                                height: 4.5,
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
        ],
      ),
    );
  }
}

