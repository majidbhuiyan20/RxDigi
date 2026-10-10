import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../app/slot_style.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../core/utils/bangla_utility.dart';
import '../models/medicine_reminder_model.dart';
import '../provider/medicine_reminder_provider.dart';
import '../services/medicine_safety_advisor.dart';
import 'add_reminder_sheet.dart';
import '../widgets/adherence_progress_card.dart';
import '../widgets/medicine_reminder_card.dart';
import '../widgets/reminder_empty_state.dart';
import '../widgets/pharmacy_shopping_list_sheet.dart';

class MedicineReminderScreen extends ConsumerStatefulWidget {
  const MedicineReminderScreen({super.key});

  @override
  ConsumerState<MedicineReminderScreen> createState() => _MedicineReminderScreenState();
}

class _MedicineReminderScreenState extends ConsumerState<MedicineReminderScreen> {
  // 0 = আজকের রুটিন (Today's Timeline), 1 = সকল ঔষধ (All Meds)
  int _selectedTab = 0;

  String _getCurrentSlotKey() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'noon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  IconData _getFormIcon(String form) {
    switch (form.toLowerCase()) {
      case 'tablet':
      case 'capsule':
        return PhosphorIconsRegular.pill;
      case 'syrup':
      case 'drop':
        return PhosphorIconsRegular.drop;
      case 'injection':
        return PhosphorIconsRegular.syringe;
      default:
        return PhosphorIconsRegular.firstAid;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final remindersAsync = ref.watch(allRemindersProvider);
    final adherenceAsync = ref.watch(todayAdherenceMapProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'মেডিসিন রুটিন ও রিমাইন্ডার' : 'Medicine Routine & Schedule',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          IconButton(
            tooltip: isBn ? 'ফার্মেসি ক্রয়ের তালিকা' : 'Pharmacy Shopping List',
            icon: const Icon(PhosphorIconsRegular.shoppingCart, size: 21, color: Color(0xFF0F172A)),
            onPressed: () {
              AppFeedback.playSelection();
              PharmacyShoppingListSheet.show(context, isBn);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                AppFeedback.playLight();
                AddReminderSheet.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsBold.plus, size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'নতুন ঔষধ' : 'Add Med',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── 1. Segmented Navigation Tabs ───
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSegmentButton(
                      index: 0,
                      label: isBn ? 'আজকের রুটিন' : "Today's Routine",
                      icon: PhosphorIconsFill.calendarCheck,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildSegmentButton(
                      index: 1,
                      label: isBn ? 'সকল ঔষধ' : 'All Medicines',
                      icon: PhosphorIconsFill.pill,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // ─── 2. Tab Body ───
          Expanded(
            child: remindersAsync.when(
              data: (reminders) {
                if (reminders.isEmpty) {
                  return ReminderEmptyState(isBn: isBn);
                }

                final activeReminders = reminders.where((r) => r.isActive).toList();
                final adherenceMap = adherenceAsync.value ?? {};

                if (_selectedTab == 0) {
                  return _buildTodayTimelineTab(activeReminders, adherenceMap, isBn);
                } else {
                  return _buildAllMedicationsTab(reminders, activeReminders, adherenceMap, isBn);
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        AppFeedback.playSelection();
        setState(() => _selectedTab = index);
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── TAB 0: TODAY'S TIMELINE CHECKLIST ───
  Widget _buildTodayTimelineTab(
    List<MedicineReminderModel> activeReminders,
    Map<String, bool> adherenceMap,
    bool isBn,
  ) {
    if (activeReminders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(PhosphorIconsRegular.bed, size: 40, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),
              Text(
                isBn ? 'আজকের জন্য কোনো সক্রিয় ঔষধ নেই' : 'No active medications for today',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 6),
              Text(
                isBn ? 'আপনার প্রেসক্রিপশনের ঔষধ যোগ করতে উপরের বাটন চাপুন।' : 'Tap + Add Med to set up your schedule.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // Slots definitions
    final slotConfigs = [
      {'key': 'morning', 'title': isBn ? 'সকাল' : 'Morning', 'style': SlotStyle.morning},
      {'key': 'noon', 'title': isBn ? 'দুপুর' : 'Noon', 'style': SlotStyle.noon},
      {'key': 'evening', 'title': isBn ? 'সন্ধ্যা' : 'Evening', 'style': SlotStyle.evening},
      {'key': 'night', 'title': isBn ? 'রাত' : 'Night', 'style': SlotStyle.night},
    ];

    // Compute stats
    int totalDoses = 0;
    int takenDoses = 0;
    for (final r in activeReminders) {
      if (r.id != null) {
        if (r.morning) {
          totalDoses++;
          if (adherenceMap['${r.id}_morning'] == true) takenDoses++;
        }
        if (r.noon) {
          totalDoses++;
          if (adherenceMap['${r.id}_noon'] == true) takenDoses++;
        }
        if (r.evening) {
          totalDoses++;
          if (adherenceMap['${r.id}_evening'] == true) takenDoses++;
        }
        if (r.night) {
          totalDoses++;
          if (adherenceMap['${r.id}_night'] == true) takenDoses++;
        }
      }
    }

    final double progress = totalDoses > 0 ? (takenDoses / totalDoses) : 0.0;
    final int percent = (progress * 100).toInt();
    final currentSlotKey = _getCurrentSlotKey();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      physics: const BouncingScrollPhysics(),
      children: [
        // Date & Daily Summary Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(PhosphorIconsRegular.calendarBlank, size: 16, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 6),
                      Text(
                        isBn
                            ? BanglaUtility.formatFullDateBn(DateTime.now())
                            : 'Today, ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: percent == 100 ? const Color(0xFF10B981) : const Color(0xFF38BDF8).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isBn ? '${BanglaUtility.toBn(percent)}% সম্পন্ন' : '$percent% Done',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: percent == 100 ? Colors.white : const Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn
                        ? '${BanglaUtility.toBn(totalDoses)}টির মধ্যে ${BanglaUtility.toBn(takenDoses)}টি ঔষধ খাওয়া হয়েছে'
                        : '$takenDoses of $totalDoses scheduled doses taken',
                    style: TextStyle(fontSize: 12.5, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent == 100 ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Timeline Groups by Slot
        ...slotConfigs.map((cfg) {
          final slotKey = cfg['key'] as String;
          final slotTitle = cfg['title'] as String;
          final slotStyle = cfg['style'] as SlotStyle;

          // Find medicines for this slot
          final slotMeds = activeReminders.where((r) {
            switch (slotKey) {
              case 'morning':
                return r.morning;
              case 'noon':
                return r.noon;
              case 'evening':
                return r.evening;
              case 'night':
                return r.night;
              default:
                return false;
            }
          }).toList();

          if (slotMeds.isEmpty) return const SizedBox.shrink();

          // Time for this slot (from first med or default)
          final slotTime = slotKey == 'morning'
              ? slotMeds.first.morningTime
              : slotKey == 'noon'
                  ? slotMeds.first.noonTime
                  : slotKey == 'evening'
                      ? slotMeds.first.eveningTime
                      : slotMeds.first.nightTime;

          final allSlotTaken = slotMeds.every((r) => adherenceMap['${r.id}_$slotKey'] == true);
          final isCurrentSlot = slotKey == currentSlotKey;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCurrentSlot ? slotStyle.color.withValues(alpha: 0.35) : const Color(0xFFE2E8F0),
                width: isCurrentSlot ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Slot Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: slotStyle.color.withValues(alpha: 0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(19)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: slotStyle.color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(slotStyle.icon, size: 16, color: slotStyle.color),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                slotTitle,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: slotStyle.color,
                                ),
                              ),
                              if (isCurrentSlot) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: slotStyle.color,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isBn ? 'এখনকার' : 'Now',
                                    style: const TextStyle(fontSize: 9.5, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            isBn ? BanglaUtility.formatTimeBn(slotTime) : slotTime,
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (allSlotTaken)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(PhosphorIconsBold.check, size: 12, color: Color(0xFF10B981)),
                              const SizedBox(width: 4),
                              Text(
                                isBn ? 'সব সম্পন্ন' : 'Completed',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          isBn ? '${BanglaUtility.toBn(slotMeds.length)}টি ঔষধ' : '${slotMeds.length} Meds',
                          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                ),

                // Dose Items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: slotMeds.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, indent: 60, endIndent: 16),
                  itemBuilder: (context, idx) {
                    final med = slotMeds[idx];
                    final isTaken = adherenceMap['${med.id}_$slotKey'] == true;
                    final advice = MedicineSafetyAdvisor.getAdvice(med.medicineName, med.dosageStrength);

                    return _buildTimelineDoseRow(
                      med: med,
                      slotKey: slotKey,
                      isTaken: isTaken,
                      advice: advice,
                      isBn: isBn,
                    );
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTimelineDoseRow({
    required MedicineReminderModel med,
    required String slotKey,
    required bool isTaken,
    required SafetyAdvice? advice,
    required bool isBn,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          // 1-Tap Checkbox
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              if (med.id != null) {
                if (!isTaken) {
                  AppFeedback.playSuccess();
                } else {
                  AppFeedback.playSelection();
                }
                ref.read(medicineReminderNotifierProvider.notifier).toggleAdherence(
                      reminderId: med.id!,
                      slot: slotKey,
                      isCurrentlyTaken: isTaken,
                    );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isTaken ? const Color(0xFF16A34A) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTaken ? const Color(0xFF16A34A) : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isTaken
                  ? const Icon(PhosphorIconsBold.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Dosage Form Icon
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isTaken ? Colors.grey.shade100 : AppColors.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getFormIcon(med.dosageForm),
              size: 18,
              color: isTaken ? Colors.grey : AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),

          // Medicine Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        med.medicineName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                          color: isTaken ? Colors.grey.shade500 : const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    if (med.dosageStrength.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        med.dosageStrength,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isTaken ? Colors.grey : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Instruction Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        med.instructions,
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ),

                    // Course Badge
                    if (med.isCourseBased) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: med.isCourseCompleted ? Colors.green.shade50 : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          med.isCourseCompleted
                              ? (isBn ? 'কোর্স সমাপ্ত' : 'Done')
                              : (isBn
                                  ? 'দিন ${BanglaUtility.toBn(med.currentCourseDay)}/${BanglaUtility.toBn(med.durationDays)}'
                                  : 'Day ${med.currentCourseDay}/${med.durationDays}'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: med.isCourseCompleted ? Colors.green.shade700 : const Color(0xFF1D4ED8),
                          ),
                        ),
                      ),
                    ],

                    // Stock Pill
                    if (med.isLowStock || med.isOutOfStock) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: med.isOutOfStock ? Colors.red.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          med.isOutOfStock
                              ? (isBn ? 'স্টক শেষ' : 'Out')
                              : (isBn ? 'বাকি ${BanglaUtility.toBn(med.currentStock)}' : '${med.currentStock} left'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: med.isOutOfStock ? Colors.red.shade700 : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Options Popup Menu (Snooze, Advice, Edit)
          PopupMenuButton<String>(
            icon: Icon(PhosphorIconsRegular.dotsThreeVertical, size: 18, color: Colors.grey.shade600),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'snooze') {
                AppFeedback.playLight();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isBn
                        ? '${med.medicineName} এর জন্য ১৫ মিনিট পরে স্নুজ রিমাইন্ডার সেট করা হয়েছে'
                        : 'Snoozed ${med.medicineName} for 15 minutes'),
                    backgroundColor: AppColors.primaryColor,
                    duration: const Duration(seconds: 2),
                  ),
                );
              } else if (val == 'advice' && advice != null) {
                AppFeedback.playLight();
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: advice.themeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(advice.icon, color: advice.themeColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isBn ? 'সেবন নির্দেশিকা' : 'Clinical Safety Advice',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    content: Text(
                      isBn ? advice.fullAdviceBn : advice.fullAdviceEn,
                      style: const TextStyle(fontSize: 13.5, height: 1.45, color: Color(0xFF334155)),
                    ),
                    actions: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: advice.themeColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          isBn ? 'বুঝেছি' : 'Got it',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              } else if (val == 'edit') {
                AppFeedback.playLight();
                AddReminderSheet.show(context, existingReminder: med);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'snooze',
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.clockCountdown, size: 16, color: Color(0xFFEA580C)),
                    const SizedBox(width: 8),
                    Text(isBn ? '১৫ মিনিট স্নুজ করুন' : 'Snooze 15 mins', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
              if (advice != null)
                PopupMenuItem(
                  value: 'advice',
                  child: Row(
                    children: [
                      Icon(PhosphorIconsRegular.info, size: 16, color: advice.themeColor),
                      const SizedBox(width: 8),
                      Text(isBn ? 'সেবন নির্দেশিকা' : 'Safety Advice', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(PhosphorIconsRegular.pencilSimple, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Text(isBn ? 'সম্পাদনা করুন' : 'Edit Medicine', style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TAB 1: ALL MEDICATIONS (MEDICINE BOX) ───
  Widget _buildAllMedicationsTab(
    List<MedicineReminderModel> reminders,
    List<MedicineReminderModel> activeReminders,
    Map<String, bool> adherenceMap,
    bool isBn,
  ) {
    int totalDosesToday = 0;
    int takenTodayDoses = 0;
    for (final r in activeReminders) {
      if (r.id != null) {
        if (r.morning) {
          totalDosesToday++;
          if (adherenceMap['${r.id}_morning'] == true) takenTodayDoses++;
        }
        if (r.noon) {
          totalDosesToday++;
          if (adherenceMap['${r.id}_noon'] == true) takenTodayDoses++;
        }
        if (r.evening) {
          totalDosesToday++;
          if (adherenceMap['${r.id}_evening'] == true) takenTodayDoses++;
        }
        if (r.night) {
          totalDosesToday++;
          if (adherenceMap['${r.id}_night'] == true) takenTodayDoses++;
        }
      }
    }

    final percent = totalDosesToday > 0 ? (takenTodayDoses / totalDosesToday) : 0.0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        // Daily Summary Progress Card
        AdherenceProgressCard(
          activeCount: activeReminders.length,
          takenCount: takenTodayDoses,
          totalCount: totalDosesToday,
          progress: percent,
          isBn: isBn,
        ),
        const SizedBox(height: 20),

        // Title Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isBn ? 'আপনার সকল ঔষধের বক্স' : 'Your Medicine Cabinet',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isBn ? '${reminders.length} টি ঔষধ' : '${reminders.length} Meds',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Medication Cards
        ...reminders.map((reminder) => MedicineReminderCard(reminder: reminder, isBn: isBn)),
      ],
    );
  }
}
