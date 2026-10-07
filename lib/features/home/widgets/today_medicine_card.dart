import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../app/slot_style.dart';
import '../../medicine_reminder/models/medicine_reminder_model.dart';
import '../../medicine_reminder/provider/medicine_reminder_provider.dart';
import '../../medicine_reminder/view/add_reminder_sheet.dart';
import '../../medicine_reminder/view/medicine_reminder_screen.dart';

class TodayMedicineCard extends ConsumerWidget {
  const TodayMedicineCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final remindersAsync = ref.watch(activeRemindersProvider);
    final adherenceAsync = ref.watch(todayAdherenceMapProvider);

    return remindersAsync.when(
      data: (reminders) {
        final adherenceMap = adherenceAsync.value ?? {};

        // Calculate dose counts
        int totalTodayDoses = 0;
        int takenTodayDoses = 0;
        for (final r in reminders) {
          if (r.id != null) {
            if (r.morning) {
              totalTodayDoses++;
              if (adherenceMap['${r.id}_morning'] == true) takenTodayDoses++;
            }
            if (r.noon) {
              totalTodayDoses++;
              if (adherenceMap['${r.id}_noon'] == true) takenTodayDoses++;
            }
            if (r.evening) {
              totalTodayDoses++;
              if (adherenceMap['${r.id}_evening'] == true) takenTodayDoses++;
            }
            if (r.night) {
              totalTodayDoses++;
              if (adherenceMap['${r.id}_night'] == true) takenTodayDoses++;
            }
          }
        }

        final double progress = totalTodayDoses > 0 ? (takenTodayDoses / totalTodayDoses) : 0.0;
        final int percent = (progress * 100).toInt();

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
              // Header Row
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
                      Text(
                        isBn ? 'আজকের ঔষধের রুটিন' : "Today's Medicine Routine",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
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
              const SizedBox(height: 16),

              // Progress Bar
              if (totalTodayDoses > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBn
                          ? '$totalTodayDoses টির মধ্যে $takenTodayDoses টি সম্পন্ন'
                          : '$takenTodayDoses of $totalTodayDoses doses taken',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: percent == 100 ? const Color(0xFF16A34A) : AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
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
                const SizedBox(height: 16),
              ],

              // Empty or Medicine Slots
              if (reminders.isEmpty)
                _buildNoRemindersCard(context, isBn)
              else ...[
                _buildSlotSection(context, ref, SlotStyle.morning, isBn ? 'সকাল' : 'Morning', reminders, adherenceMap, isBn),
                _buildSlotSection(context, ref, SlotStyle.noon, isBn ? 'দুপুর' : 'Noon', reminders, adherenceMap, isBn),
                _buildSlotSection(context, ref, SlotStyle.evening, isBn ? 'সন্ধ্যা' : 'Evening', reminders, adherenceMap, isBn),
                _buildSlotSection(context, ref, SlotStyle.night, isBn ? 'রাত' : 'Night', reminders, adherenceMap, isBn),

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
                            isBn ? 'সকল ঔষধের সময়সূচী দেখুন' : 'Manage All Medications',
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
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildNoRemindersCard(BuildContext context, bool isBn) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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

  Widget _buildSlotSection(
    BuildContext context,
    WidgetRef ref,
    SlotStyle style,
    String slotTitle,
    List<MedicineReminderModel> reminders,
    Map<String, bool> adherenceMap,
    bool isBn,
  ) {
    final slotKey = style.key;
    final slotMeds = reminders.where((r) {
      if (slotKey == 'morning') return r.morning;
      if (slotKey == 'noon') return r.noon;
      if (slotKey == 'evening') return r.evening;
      if (slotKey == 'night') return r.night;
      return false;
    }).toList();

    if (slotMeds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SlotIcon(style, size: 18),
              const SizedBox(width: 6),
              Text(
                slotTitle,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...slotMeds.map((med) {
            final isTaken = adherenceMap['${med.id}_$slotKey'] == true;
            final time = slotKey == 'morning'
                ? med.morningTime
                : slotKey == 'noon'
                    ? med.noonTime
                    : slotKey == 'evening'
                        ? med.eveningTime
                        : med.nightTime;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isTaken ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isTaken ? const Color(0xFF86EFAC) : Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (med.id != null) {
                        ref.read(medicineReminderNotifierProvider.notifier).toggleAdherence(
                              reminderId: med.id!,
                              slot: slotKey,
                              isCurrentlyTaken: isTaken,
                            );
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: isTaken ? Colors.green : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isTaken ? Colors.green : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isTaken
                          ? const Icon(PhosphorIconsBold.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              med.medicineName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: isTaken ? TextDecoration.lineThrough : null,
                                color: isTaken ? Colors.grey.shade600 : Colors.black87,
                              ),
                            ),
                            if (med.dosageStrength.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                med.dosageStrength,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isTaken ? Colors.grey : Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${med.dosageForm} • ${med.instructions} • $time',
                              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                            ),
                            if (med.isLowStock || med.isOutOfStock) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: med.isOutOfStock ? Colors.red.shade50 : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  med.isOutOfStock ? (isBn ? 'স্টক শেষ' : 'Empty') : (isBn ? 'বাকি ${med.currentStock}' : '${med.currentStock} left'),
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
                  if (isTaken)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isBn ? 'গৃহীত' : 'Taken',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
