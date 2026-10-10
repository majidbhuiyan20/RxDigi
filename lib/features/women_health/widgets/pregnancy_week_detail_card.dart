import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/pregnancy_model.dart';
import '../provider/pregnancy_provider.dart';
import '../utils/women_health_formatters.dart';

class PregnancyWeekDetailCard extends ConsumerStatefulWidget {
  final PregnancyModel pregnancy;

  const PregnancyWeekDetailCard({
    super.key,
    required this.pregnancy,
  });

  @override
  ConsumerState<PregnancyWeekDetailCard> createState() =>
      _PregnancyWeekDetailCardState();
}

class _PregnancyWeekDetailCardState
    extends ConsumerState<PregnancyWeekDetailCard> {
  int _activeTab = 0; // 0: Baby, 1: Mother, 2: Care

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final selectedWeek = ref.watch(selectedPregnancyWeekProvider);
    final weekInfo = PregnancyWeekCatalog.getWeekInfo(selectedWeek);
    final isCurrentWeek = selectedWeek == widget.pregnancy.currentWeek;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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
          // Header Row: Week Title + Jump to Current Week Pill
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
                      PhosphorIconsFill.sparkle,
                      size: 16,
                      color: Color(0xFFE11D48),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn
                        ? 'সপ্তাহ ${WomenHealthFormatters.formatDigits(selectedWeek, isBn: true)} এর বিশেষ গাইড'
                        : 'Week $selectedWeek Clinical Guide',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (!isCurrentWeek)
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(selectedPregnancyWeekProvider.notifier)
                        .selectWeek(widget.pregnancy.currentWeek);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isBn ? 'বর্তমান সপ্তাহ' : 'Current Week',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Horizontal Weeks Selector Reel
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: PregnancyWeekCatalog.weeks.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final w = PregnancyWeekCatalog.weeks[index];
                final isSelected = w.week == selectedWeek;
                final isActualCurrent = w.week == widget.pregnancy.currentWeek;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(selectedPregnancyWeekProvider.notifier)
                        .selectWeek(w.week);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : (isActualCurrent
                              ? const Color(0xFFFFF1F2)
                              : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0F172A)
                            : (isActualCurrent
                                ? const Color(0xFFFECDD3)
                                : Colors.grey.shade200),
                        width: isSelected || isActualCurrent ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(w.fruitEmoji, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          '${isBn ? "সপ্তাহ " : "W"}${WomenHealthFormatters.formatDigits(w.week, isBn: isBn)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isActualCurrent
                                    ? const Color(0xFFE11D48)
                                    : const Color(0xFF475569)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3 Segmented Tabs
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildTabButton(0, isBn ? '👶 শিশুর বিকাশ' : '👶 Baby'),
                _buildTabButton(1, isBn ? '🤰 মায়ের শরীর' : '🤰 Mom'),
                _buildTabButton(2, isBn ? '🥗 পুষ্টি ও যত্ন' : '🥗 Care'),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Tab Body Content
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildTabContent(weekInfo, isBn),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String label) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          AppFeedback.playLight();
          setState(() => _activeTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent(PregnancyWeekInfo weekInfo, bool isBn) {
    switch (_activeTab) {
      case 0:
        return Container(
          key: const ValueKey('baby_tab'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFAF5FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE9D5FF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(PhosphorIconsFill.sparkle, color: Color(0xFF7C3AED), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isBn ? 'ভ্রূণের অঙ্গ ও শারীরিক বৃদ্ধি:' : 'Fetal Growth & Milestones:',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6D28D9),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isBn ? weekInfo.babyDevelopmentBn : weekInfo.babyDevelopmentEn,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        );
      case 1:
        return Container(
          key: const ValueKey('mother_tab'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(PhosphorIconsFill.heart, color: Color(0xFFBE123C), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isBn ? 'মায়ের শারীরিক পরিবর্তন ও লক্ষণ:' : 'Mother\'s Body & Symptoms:',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF9F1239),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isBn ? weekInfo.motherChangesBn : weekInfo.motherChangesEn,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        );
      case 2:
      default:
        return Container(
          key: const ValueKey('care_tab'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(PhosphorIconsFill.shieldCheck, color: Color(0xFF047857), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    isBn ? 'পুষ্টি, বিশ্রাম ও ক্লিনিক্যাল পরামর্শ:' : 'Nutrition, Rest & Clinical Tips:',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF065F46),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isBn ? weekInfo.careTipBn : weekInfo.careTipEn,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        );
    }
  }
}
