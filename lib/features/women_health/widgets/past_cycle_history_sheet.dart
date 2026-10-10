import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../utils/women_health_formatters.dart';

class PastCycleHistorySheet extends ConsumerWidget {
  final MenstrualCycleModel cycle;

  const PastCycleHistorySheet({
    super.key,
    required this.cycle,
  });

  static Future<void> show(BuildContext context, MenstrualCycleModel cycle) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PastCycleHistorySheet(cycle: cycle),
    );
  }

  void _showAddPastCycleDialog(BuildContext context, WidgetRef ref, bool isBn) {
    DateTime selectedDate = DateTime.now().subtract(const Duration(days: 30));
    int cycleLength = 28;
    int periodDays = 5;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(PhosphorIconsFill.calendarPlus, color: Color(0xFFE11D48), size: 22),
              const SizedBox(width: 8),
              Text(
                isBn ? 'পূর্ববর্তী সাইকেল যোগ করুন' : 'Log Past Cycle Record',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isBn ? 'পিরিয়ড শুরুর তারিখ:' : 'Period Start Date:',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setDialogState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        WomenHealthFormatters.formatFullDate(selectedDate, isBn: isBn),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const Icon(PhosphorIconsRegular.calendar, size: 18, color: Color(0xFFE11D48)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'সাইকেলের স্থায়িত্ব:' : 'Cycle Length:',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: cycleLength,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: List.generate(25, (i) => i + 20)
                              .map((days) => DropdownMenuItem(
                                    value: days,
                                    child: Text('$days ${isBn ? "দিন" : "d"}'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => cycleLength = val);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'ব্লিডিং দিন:' : 'Bleeding Days:',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: periodDays,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: List.generate(8, (i) => i + 2)
                              .map((days) => DropdownMenuItem(
                                    value: days,
                                    child: Text('$days ${isBn ? "দিন" : "d"}'),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setDialogState(() => periodDays = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isBn ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                AppFeedback.playSuccess();
                Navigator.pop(ctx);
                final newCycle = HistoricalCycleEntry(
                  id: 'cycle_${DateTime.now().millisecondsSinceEpoch}',
                  startDate: selectedDate,
                  endDate: selectedDate.add(Duration(days: periodDays)),
                  cycleLength: cycleLength,
                  periodDuration: periodDays,
                  notes: isBn ? 'ম্যানুয়ালি যোগ করা' : 'Manually recorded',
                );
                await ref.read(womenCycleHistoryProvider.notifier).addCycle(newCycle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isBn ? 'যোগ করুন' : 'Add Record',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final history = ref.watch(womenCycleHistoryProvider);

    final allLengths = [cycle.cycleLength, ...history.map((h) => h.cycleLength)];
    final avgLength = (allLengths.reduce((a, b) => a + b) / allLengths.length).round();
    final minLength = allLengths.reduce((a, b) => a < b ? a : b);
    final maxLength = allLengths.reduce((a, b) => a > b ? a : b);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        PhosphorIconsFill.clockCounterClockwise,
                        color: Color(0xFFE11D48),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'সাইকেল হিস্ট্রি ও ভ্যারিয়েশন' : 'Cycle History & Variations',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          isBn ? 'বিগত মাসগুলোর সাইকেল বিশ্লেষণ' : 'Past menstrual logs analysis',
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
                  icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              children: [
                // Quick Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatTile(
                        label: isBn ? 'গড় সাইকেল' : 'Avg Cycle',
                        value: '$avgLength ${isBn ? "দিন" : "days"}',
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatTile(
                        label: isBn ? 'সর্বনিম্ন' : 'Shortest',
                        value: '$minLength ${isBn ? "দিন" : "days"}',
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatTile(
                        label: isBn ? 'সর্বোচ্চ' : 'Longest',
                        value: '$maxLength ${isBn ? "দিন" : "days"}',
                        color: const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Button: Add Record
                OutlinedButton.icon(
                  onPressed: () => _showAddPastCycleDialog(context, ref, isBn),
                  icon: const Icon(PhosphorIconsRegular.plus, size: 16),
                  label: Text(
                    isBn ? '+ পূর্বের সাইকেল রেকর্ড যোগ করুন' : '+ Log Past Cycle Record',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE11D48),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFFFECDD3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  isBn ? 'সকল সাইকেলের তালিকা:' : 'All Recorded Cycles:',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 10),

                // Current Active Cycle Tile
                _buildHistoryTile(
                  context: context,
                  ref: ref,
                  title: isBn ? 'চলমান সাইকেল (বর্তমান)' : 'Current Active Cycle',
                  startDate: cycle.lastPeriodStartDate,
                  cycleLength: cycle.cycleLength,
                  periodDays: cycle.periodDuration,
                  isIrregular: cycle.isIrregularCycle,
                  isBn: isBn,
                  isCurrent: true,
                ),

                // History entries
                ...history.map((h) => _buildHistoryTile(
                      context: context,
                      ref: ref,
                      id: h.id,
                      title: h.notes ?? (isBn ? 'পূর্ববর্তী সাইকেল' : 'Past Cycle'),
                      startDate: h.startDate,
                      cycleLength: h.cycleLength,
                      periodDays: h.periodDuration,
                      isIrregular: h.isIrregular,
                      isBn: isBn,
                      isCurrent: false,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600)),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile({
    required BuildContext context,
    required WidgetRef ref,
    String? id,
    required String title,
    required DateTime startDate,
    required int cycleLength,
    required int periodDays,
    required bool isIrregular,
    required bool isBn,
    required bool isCurrent,
  }) {
    final dateStr = WomenHealthFormatters.formatDayMonth(startDate, isBn: isBn);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFFFFF1F2) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? const Color(0xFFFECDD3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isIrregular
                      ? const Color(0xFFF43F5E).withValues(alpha: 0.12)
                      : const Color(0xFF10B981).withValues(alpha: 0.12),
                ),
                child: Icon(
                  isIrregular ? PhosphorIconsFill.warning : PhosphorIconsFill.checkCircle,
                  size: 18,
                  color: isIrregular ? const Color(0xFFE11D48) : const Color(0xFF059669),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${WomenHealthFormatters.formatDigits(cycleLength, isBn: isBn)} ${isBn ? "দিন" : "days"}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isIrregular ? const Color(0xFFE11D48) : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    '${isBn ? "ব্লিডিং " : "Bleeding "}${WomenHealthFormatters.formatDigits(periodDays, isBn: isBn)} ${isBn ? "দিন" : "d"}',
                    style: TextStyle(fontSize: 10.5, color: Colors.grey.shade500),
                  ),
                ],
              ),
              if (!isCurrent && id != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.trash, size: 16, color: Color(0xFF94A3B8)),
                  onPressed: () {
                    AppFeedback.playLight();
                    ref.read(womenCycleHistoryProvider.notifier).deleteCycle(id);
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

