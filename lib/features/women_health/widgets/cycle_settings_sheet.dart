import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../utils/women_health_formatters.dart';
import '../../../core/utils/app_feedback.dart';

class CycleSettingsSheet extends ConsumerStatefulWidget {
  final MenstrualCycleModel currentCycle;

  const CycleSettingsSheet({
    super.key,
    required this.currentCycle,
  });

  static Future<void> show(BuildContext context, MenstrualCycleModel currentCycle) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CycleSettingsSheet(currentCycle: currentCycle),
    );
  }

  @override
  ConsumerState<CycleSettingsSheet> createState() => _CycleSettingsSheetState();
}

class _CycleSettingsSheetState extends ConsumerState<CycleSettingsSheet> {
  late DateTime _lastPeriodDate;
  late int _cycleLength;
  late int _periodDuration;

  @override
  void initState() {
    super.initState();
    _lastPeriodDate = widget.currentCycle.lastPeriodStartDate;
    _cycleLength = widget.currentCycle.cycleLength;
    _periodDuration = widget.currentCycle.periodDuration;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFF43F5E),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _lastPeriodDate = picked);
    }
  }

  void _save(bool isBn) {
    AppFeedback.playSuccess();
    ref.read(womenCycleProvider.notifier).updateCycleSettings(
          cycleLength: _cycleLength,
          periodDuration: _periodDuration,
          lastPeriodStartDate: _lastPeriodDate,
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isBn ? 'সাইকেল সেটিংস আপডেট করা হয়েছে' : 'Cycle settings updated successfully'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final dateFormatted = WomenHealthFormatters.formatFullDate(_lastPeriodDate, isBn: isBn);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      PhosphorIconsFill.gear,
                      color: Color(0xFFF43F5E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'সাইকেল ও পিরিয়ড সেটিংস' : 'Cycle Settings',
                    style: const TextStyle(
                      fontSize: 17,
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

          const SizedBox(height: 18),

          // 1. Last Period Start Date Picker
          Text(
            isBn ? 'শেষ পিরিয়ড শুরুর তারিখ' : 'Last Period Start Date',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsRegular.calendarCheck, size: 20, color: Color(0xFFF43F5E)),
                  const SizedBox(width: 10),
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isBn ? 'পরিবর্তন করুন' : 'Change',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF43F5E),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 2. Average Cycle Length (days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'মাসিক চক্রের স্থায়ীত্ব (Cycle Length)' : 'Cycle Length',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_cycleLength ${isBn ? 'দিন' : 'days'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFF43F5E),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _cycleLength.toDouble(),
            min: 21,
            max: 40,
            divisions: 19,
            activeColor: const Color(0xFFF43F5E),
            inactiveColor: Colors.grey.shade200,
            onChanged: (val) {
              setState(() => _cycleLength = val.round());
            },
          ),
          Text(
            isBn ? 'স্বাভাবিক রেঞ্জ: ২১ থেকে ৩৫ দিন (গড়: ২৮ দিন)' : 'Normal range: 21 to 35 days (Average: 28 days)',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 18),

          // 3. Period Duration (days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'রক্তক্ষরণের সময়কাল (Period Duration)' : 'Period Duration',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_periodDuration ${isBn ? 'দিন' : 'days'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _periodDuration.toDouble(),
            min: 3,
            max: 9,
            divisions: 6,
            activeColor: const Color(0xFF8B5CF6),
            inactiveColor: Colors.grey.shade200,
            onChanged: (val) {
              setState(() => _periodDuration = val.round());
            },
          ),
          Text(
            isBn ? 'স্বাভাবিক রেঞ্জ: ৩ থেকে ৭ দিন' : 'Normal range: 3 to 7 days',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),

          const SizedBox(height: 24),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _save(isBn),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isBn ? 'সেটিংস সংরক্ষণ করুন' : 'Save Settings',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
