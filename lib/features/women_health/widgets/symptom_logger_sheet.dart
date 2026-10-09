import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/daily_symptom_log.dart';
import '../provider/women_health_provider.dart';
import '../../../core/utils/app_feedback.dart';

class SymptomLoggerSheet extends ConsumerStatefulWidget {
  final DailySymptomLog? initialLog;

  const SymptomLoggerSheet({
    super.key,
    this.initialLog,
  });

  static Future<void> show(BuildContext context, {DailySymptomLog? initialLog}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SymptomLoggerSheet(initialLog: initialLog),
    );
  }

  @override
  ConsumerState<SymptomLoggerSheet> createState() => _SymptomLoggerSheetState();
}

class _SymptomLoggerSheetState extends ConsumerState<SymptomLoggerSheet> {
  late FlowLevel _flow;
  late CrampLevel _cramp;
  late MoodType _mood;
  late List<String> _selectedSymptoms;

  final List<String> _allSymptoms = [
    'মাথাব্যথা',
    'পেট ফাঁপা',
    'কোমর ব্যথা',
    'ব্রণ / র‍্যাশ',
    'স্তন সংবেদনশীলতা',
    'অনিদ্রা',
    'মিষ্টি খাওয়ার তীব্র ইচ্ছা',
    'বমি ভাব',
  ];

  @override
  void initState() {
    super.initState();
    final log = widget.initialLog;
    _flow = log?.flow ?? FlowLevel.none;
    _cramp = log?.cramp ?? CrampLevel.none;
    _mood = log?.mood ?? MoodType.calm;
    _selectedSymptoms = List.from(log?.physicalSymptoms ?? []);
  }

  void _save() {
    AppFeedback.playSuccess();
    final today = getTodayKey();
    final newLog = DailySymptomLog(
      dateKey: today,
      flow: _flow,
      cramp: _cramp,
      mood: _mood,
      physicalSymptoms: _selectedSymptoms,
    );
    ref.read(dailySymptomProvider.notifier).saveLog(newLog);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('আজকের লক্ষণ ও মুড সফলভাবে সেভ করা হয়েছে'),
        backgroundColor: Color(0xFF10B981),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
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
                      color: const Color(0xFFF43F5E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.heart,
                      color: Color(0xFFF43F5E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isBn ? 'দৈনিক লক্ষণ ও অনুভূতি রেকর্ড' : 'Log Symptoms & Mood',
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

          const SizedBox(height: 12),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Menstrual Flow
                Text(
                  isBn ? '১. পিরিয়ড ফ্লো (রক্তক্ষরণ)' : '1. Period Flow',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FlowLevel.values.map((f) {
                    final isSelected = _flow == f;
                    return InkWell(
                      onTap: () {
                        AppFeedback.playLight();
                        setState(() => _flow = f);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF43F5E)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF43F5E)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(f.emoji, style: const TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              f.labelBn,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // 2. Cramps / Pain
                Text(
                  isBn ? '২. ক্র্যাম্প বা তলপেটের ব্যথা' : '2. Cramps & Pain',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CrampLevel.values.map((c) {
                    final isSelected = _cramp == c;
                    return InkWell(
                      onTap: () {
                        AppFeedback.playLight();
                        setState(() => _cramp = c);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF8B5CF6)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          c.labelBn,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // 3. Mood
                Text(
                  isBn ? '৩. আজকের মানসিক অনুভূতি (মুড)' : '3. Today\'s Mood',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MoodType.values.map((m) {
                    final isSelected = _mood == m;
                    return InkWell(
                      onTap: () {
                        AppFeedback.playLight();
                        setState(() => _mood = m);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade200,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(m.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              m.labelBn,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 18),

                // 4. Other physical symptoms
                Text(
                  isBn ? '৪. অন্যান্য শারীরিক লক্ষণ' : '4. Other Physical Symptoms',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSymptoms.map((symptom) {
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(
                        symptom,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                      ),
                      selectedColor: const Color(0xFFEC4899),
                      backgroundColor: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      checkmarkColor: Colors.white,
                      onSelected: (val) {
                        AppFeedback.playLight();
                        setState(() {
                          if (val) {
                            _selectedSymptoms.add(symptom);
                          } else {
                            _selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF43F5E),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isBn ? 'রেকর্ড সংরক্ষণ করুন' : 'Save Today\'s Entry',
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
