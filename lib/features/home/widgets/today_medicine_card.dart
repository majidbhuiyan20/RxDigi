import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../app/slot_style.dart';
import '../../medicine_reminder/models/medicine_reminder_model.dart';
import '../../medicine_reminder/models/medicine_adherence_model.dart';
import '../../medicine_reminder/provider/medicine_reminder_provider.dart';
import '../../medicine_reminder/view/add_reminder_sheet.dart';
import '../../medicine_reminder/view/medicine_reminder_screen.dart';

class TodayMedicineCard extends ConsumerStatefulWidget {
  const TodayMedicineCard({super.key});

  @override
  ConsumerState<TodayMedicineCard> createState() => _TodayMedicineCardState();
}

class _TodayMedicineCardState extends ConsumerState<TodayMedicineCard> {
  // Filters: 'current', 'pending', 'taken', 'all'
  String _selectedFilter = 'current';
  bool _showAnalytics = false;

  String _getCurrentSlotKey() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'noon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }

  String _getSlotTitle(String slotKey, bool isBn) {
    switch (slotKey) {
      case 'morning':
        return isBn ? 'সকাল' : 'Morning';
      case 'noon':
        return isBn ? 'দুপুর' : 'Noon';
      case 'evening':
        return isBn ? 'সন্ধ্যা' : 'Evening';
      case 'night':
        return isBn ? 'রাত' : 'Night';
      default:
        return slotKey;
    }
  }

  bool _isSlotOverdue(String slotKey) {
    final hour = DateTime.now().hour;
    switch (slotKey) {
      case 'morning':
        return hour >= 12;
      case 'noon':
        return hour >= 17;
      case 'evening':
        return hour >= 21;
      case 'night':
        return false;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final remindersAsync = ref.watch(activeRemindersProvider);
    final adherenceAsync = ref.watch(todayAdherenceMapProvider);
    final weeklyReportAsync = ref.watch(weeklyAdherenceReportProvider);

    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return _buildNoRemindersCard(context, isBn);
        }

        final adherenceMap = adherenceAsync.value ?? {};
        final weeklyReport = weeklyReportAsync.value;

        // Flatten all scheduled doses for today
        final allDoses = <_DoseItem>[];
        for (final r in reminders) {
          if (r.id == null) continue;
          if (r.morning) {
            final isTaken = adherenceMap['${r.id}_morning'] == true;
            allDoses.add(_DoseItem(
              reminder: r,
              slotKey: 'morning',
              slotTitle: _getSlotTitle('morning', isBn),
              slotStyle: SlotStyle.morning,
              time: r.morningTime,
              isTaken: isTaken,
              isOverdue: !isTaken && _isSlotOverdue('morning'),
            ));
          }
          if (r.noon) {
            final isTaken = adherenceMap['${r.id}_noon'] == true;
            allDoses.add(_DoseItem(
              reminder: r,
              slotKey: 'noon',
              slotTitle: _getSlotTitle('noon', isBn),
              slotStyle: SlotStyle.noon,
              time: r.noonTime,
              isTaken: isTaken,
              isOverdue: !isTaken && _isSlotOverdue('noon'),
            ));
          }
          if (r.evening) {
            final isTaken = adherenceMap['${r.id}_evening'] == true;
            allDoses.add(_DoseItem(
              reminder: r,
              slotKey: 'evening',
              slotTitle: _getSlotTitle('evening', isBn),
              slotStyle: SlotStyle.evening,
              time: r.eveningTime,
              isTaken: isTaken,
              isOverdue: !isTaken && _isSlotOverdue('evening'),
            ));
          }
          if (r.night) {
            final isTaken = adherenceMap['${r.id}_night'] == true;
            allDoses.add(_DoseItem(
              reminder: r,
              slotKey: 'night',
              slotTitle: _getSlotTitle('night', isBn),
              slotStyle: SlotStyle.night,
              time: r.nightTime,
              isTaken: isTaken,
              isOverdue: !isTaken && _isSlotOverdue('night'),
            ));
          }
        }

        final totalDoses = allDoses.length;
        final takenDoses = allDoses.where((d) => d.isTaken).length;
        final pendingDoses = allDoses.where((d) => !d.isTaken).length;
        final overdueDoses = allDoses.where((d) => d.isOverdue).length;
        final currentSlot = _getCurrentSlotKey();
        final currentSlotDoses = allDoses.where((d) => d.slotKey == currentSlot).toList();

        final double progress = totalDoses > 0 ? (takenDoses / totalDoses) : 0.0;
        final int percent = (progress * 100).toInt();

        // Filter the doses list
        List<_DoseItem> displayedDoses;
        switch (_selectedFilter) {
          case 'current':
            displayedDoses = currentSlotDoses;
            break;
          case 'pending':
            displayedDoses = allDoses.where((d) => !d.isTaken).toList();
            break;
          case 'taken':
            displayedDoses = allDoses.where((d) => d.isTaken).toList();
            break;
          case 'all':
          default:
            displayedDoses = allDoses;
            break;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey.shade100, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header with Title & Add button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          PhosphorIconsFill.bellRinging,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBn ? 'আজকের ঔষধের রুটিন' : "Today's Medication",
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                              letterSpacing: -0.2,
                            ),
                          ),
                          Text(
                            isBn
                                ? '$totalDoses টির মধ্যে $takenDoses টি সম্পন্ন'
                                : '$takenDoses of $totalDoses doses taken',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => AddReminderSheet.show(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsBold.plus, size: 14, color: AppColors.primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            isBn ? 'যোগ করুন' : 'Add',
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 2. Progress Bar & Overdue Alert Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (overdueDoses > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(PhosphorIconsFill.warningCircle, size: 12, color: Color(0xFFDC2626)),
                          const SizedBox(width: 4),
                          Text(
                            isBn ? '$overdueDoses টি সময় পার হয়েছে!' : '$overdueDoses dose overdue!',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Text(
                      isBn ? 'অগ্রগতি' : 'Progress',
                      style: TextStyle(fontSize: 11.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: percent == 100 ? const Color(0xFF16A34A) : AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    percent == 100 ? const Color(0xFF16A34A) : AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Smart Filter Tabs (Current Slot, Pending, Taken, All)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(
                      key: 'current',
                      label: isBn
                          ? 'এখনকার (${_getSlotTitle(currentSlot, isBn)})'
                          : 'Next Up (${_getSlotTitle(currentSlot, isBn)})',
                      count: currentSlotDoses.length,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      key: 'pending',
                      label: isBn ? 'খাওয়া বাকি' : 'Pending',
                      count: pendingDoses,
                      alert: overdueDoses > 0,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      key: 'taken',
                      label: isBn ? 'গৃহীত' : 'Taken',
                      count: takenDoses,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      key: 'all',
                      label: isBn ? 'সব' : 'All Doses',
                      count: totalDoses,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4. Dose Items List or Filter-Specific Empty State
              if (displayedDoses.isEmpty)
                _buildFilteredEmptyState(isBn)
              else
                ...displayedDoses.map((dose) => _buildDoseItem(context, dose, isBn)),

              const SizedBox(height: 6),

              // 5. Expandable 7-Day Consistency & Analytics Section
              // 5. 7-Day Consistency & Adherence Analytics Section
              if (weeklyReport != null) ...[
                const SizedBox(height: 12),
                _buildWeeklyAnalyticsDrawer(weeklyReport, isBn),
              ],

              // 6. Manage all medications bottom link
              const SizedBox(height: 6),
              Center(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MedicineReminderScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          PhosphorIconsRegular.calendarBlank,
                          size: 15,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isBn ? 'সকল ঔষধের পূর্ণ তালিকা ও অ্যালার্ম' : 'Manage All Medications & Alarms',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildFilterChip({
    required String key,
    required String label,
    required int count,
    bool alert = false,
  }) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedFilter = key;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (alert ? const Color(0xFFFEF2F2) : AppColors.primaryColor.withOpacity(0.12))
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (alert ? const Color(0xFFEF4444) : AppColors.primaryColor)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected
                    ? (alert ? const Color(0xFFDC2626) : AppColors.primaryColor)
                    : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? (alert ? const Color(0xFFEF4444) : AppColors.primaryColor)
                    : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseItem(BuildContext context, _DoseItem dose, bool isBn) {
    final med = dose.reminder;
    final isTaken = dose.isTaken;
    final isOverdue = dose.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isTaken
            ? const Color(0xFFF0FDF4)
            : (isOverdue ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTaken
              ? const Color(0xFF86EFAC)
              : (isOverdue ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 1-Tap Checkbox with Haptic Feedback
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.mediumImpact();
              if (med.id != null) {
                ref.read(medicineReminderNotifierProvider.notifier).toggleAdherence(
                      reminderId: med.id!,
                      slot: dose.slotKey,
                      isCurrentlyTaken: isTaken,
                    );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isTaken ? const Color(0xFF16A34A) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isTaken
                      ? const Color(0xFF16A34A)
                      : (isOverdue ? const Color(0xFFF59E0B) : Colors.grey.shade400),
                  width: 2,
                ),
              ),
              child: isTaken
                  ? const Icon(PhosphorIconsBold.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Medicine Name, Form, Time & Status
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          decoration: isTaken ? TextDecoration.lineThrough : null,
                          color: isTaken ? Colors.grey.shade600 : const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    if (med.dosageStrength.isNotEmpty) ...[
                      const SizedBox(width: 5),
                      Text(
                        med.dosageStrength,
                        style: TextStyle(
                          fontSize: 11,
                          color: isTaken ? Colors.grey : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    // Slot badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: dose.slotStyle.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${dose.slotTitle} • ${dose.time}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: dose.slotStyle.color,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      med.instructions,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    if (med.isLowStock || med.isOutOfStock) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: med.isOutOfStock ? Colors.red.shade50 : Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          med.isOutOfStock
                              ? (isBn ? 'স্টক শেষ' : 'Empty')
                              : (isBn ? 'বাকি ${med.currentStock}' : '${med.currentStock} left'),
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

          // Status Badge
          if (isTaken)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isBn ? 'গৃহীত' : 'Taken',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            )
          else if (isOverdue)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isBn ? 'সময় পার' : 'Late',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWeeklyAnalyticsDrawer(WeeklyAdherenceReport report, bool isBn) {
    final percent = (report.adherenceRate * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isBn ? 'গত ৭ দিনের নিয়মানুবর্তিতা' : '7-Day Adherence Score',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              Text(
                '$percent% ${percent >= 80 ? (isBn ? "চমৎকার!" : "Great!") : ""}',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: percent >= 80 ? const Color(0xFF0F766E) : const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 7-Day Consistency Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: report.dailyStats.map((stat) {
              final isToday = stat.dateString == getTodayDateString();
              Color dotColor;
              if (stat.isNoMeds) {
                dotColor = const Color(0xFFE2E8F0);
              } else if (stat.isFull) {
                dotColor = const Color(0xFF10B981); // Green
              } else if (stat.isPartial) {
                dotColor = const Color(0xFFF59E0B); // Amber
              } else {
                dotColor = const Color(0xFFEF4444); // Red missed
              }

              return Column(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: dotColor.withOpacity(0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isToday ? const Color(0xFF0F766E) : dotColor,
                        width: isToday ? 2 : 1.2,
                      ),
                    ),
                    child: Center(
                      child: stat.isFull
                          ? Icon(PhosphorIconsBold.check, size: 12, color: dotColor)
                          : (stat.isMissed
                              ? Icon(PhosphorIconsBold.x, size: 10, color: dotColor)
                              : null),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isBn ? stat.dayNameBn : stat.dayNameEn,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                      color: isToday ? const Color(0xFF0F766E) : Colors.grey.shade600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendDot(const Color(0xFF10B981), isBn ? 'গৃহীত' : 'Taken'),
              const SizedBox(width: 12),
              _buildLegendDot(const Color(0xFFF59E0B), isBn ? 'আংশিক' : 'Partial'),
              const SizedBox(width: 12),
              _buildLegendDot(const Color(0xFFEF4444), isBn ? 'মিসড' : 'Missed'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _buildFilteredEmptyState(bool isBn) {
    String message;
    IconData icon;
    if (_selectedFilter == 'current') {
      message = isBn
          ? 'এই সময়ে কোনো ওষুধ নির্ধারিত নেই বা ইতিমধ্যে গ্রহণ সম্পন্ন হয়েছে!'
          : 'No medications due for this slot or all taken!';
      icon = PhosphorIconsRegular.sun;
    } else if (_selectedFilter == 'pending') {
      message = isBn
          ? 'দারুণ! আজকের আর কোনো ওষুধ খাওয়া বাকি নেই।'
          : 'Great! No pending doses left today.';
      icon = PhosphorIconsRegular.checkCircle;
    } else if (_selectedFilter == 'taken') {
      message = isBn
          ? 'আজকে এখনও কোনো ওষুধ খাওয়ার হিস্ট্রি যোগ হয়নি।'
          : 'No medications taken yet today.';
      icon = PhosphorIconsRegular.clockCountdown;
    } else {
      message = isBn ? 'কোনো ওষুধ পাওয়া যায়নি' : 'No medications found';
      icon = PhosphorIconsRegular.pill;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 26, color: Colors.grey.shade400),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRemindersCard(BuildContext context, bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(PhosphorIconsRegular.pill, size: 28, color: Color(0xFF0284C7)),
          ),
          const SizedBox(height: 10),
          Text(
            isBn ? 'আজকের জন্য কোনো ঔষধ নির্ধারিত নেই' : 'No medications scheduled today',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isBn
                ? 'আপনার নিয়মিত ঔষধের রিমাইন্ডার সেট করে দৈনিক সুস্থতা বজায় রাখুন।'
                : 'Add your regular tablets, syrups or vitamins to track daily intake.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600, height: 1.4),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => AddReminderSheet.show(context),
            icon: const Icon(PhosphorIconsBold.plus, size: 15, color: Colors.white),
            label: Text(
              isBn ? 'মেডিসিন রিমাইন্ডার যোগ করুন' : 'Add Medication Reminder',
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoseItem {
  final MedicineReminderModel reminder;
  final String slotKey;
  final String slotTitle;
  final SlotStyle slotStyle;
  final String time;
  final bool isTaken;
  final bool isOverdue;

  _DoseItem({
    required this.reminder,
    required this.slotKey,
    required this.slotTitle,
    required this.slotStyle,
    required this.time,
    required this.isTaken,
    required this.isOverdue,
  });
}
