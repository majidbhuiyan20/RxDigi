import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/menstrual_cycle_model.dart';
import '../provider/women_health_provider.dart';
import '../utils/women_health_formatters.dart';

class WomenCareSupplementsCard extends ConsumerWidget {
  final MenstrualCycleModel cycle;

  const WomenCareSupplementsCard({
    super.key,
    required this.cycle,
  });

  void _showOcpSettingsDialog(BuildContext context, WidgetRef ref, OCPTrackerState ocp, bool isBn) {
    String selectedBrand = ocp.pillBrand;
    int selectedPack = ocp.packDays;
    bool isEnabled = ocp.isEnabled;
    final brands = ['Femicon', 'Ovostat-Gold', 'Marvelon', 'Diane-35', 'Norix 1'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(PhosphorIconsFill.pill, color: Color(0xFF8B5CF6), size: 22),
              const SizedBox(width: 8),
              Text(
                isBn ? 'জন্মনিয়ন্ত্রণ পিল সেটিংস' : 'Birth Control (OCP) Settings',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isBn ? 'পিল ট্র্যাকিং চালু করুন' : 'Enable Pill Tracking',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: isEnabled,
                onChanged: (val) => setDialogState(() => isEnabled = val),
              ),
              const SizedBox(height: 10),
              Text(
                isBn ? 'পিলের ব্র্যান্ড নির্বাচন করুন:' : 'Select Pill Brand:',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: brands.contains(selectedBrand) ? selectedBrand : brands.first,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedBrand = val);
                },
              ),
              const SizedBox(height: 12),
              Text(
                isBn ? 'প্যাক সাইজ:' : 'Pack Size:',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Text(isBn ? '২৮ দিনের প্যাক' : '28 Pills Pack'),
                      selected: selectedPack == 28,
                      onSelected: (_) => setDialogState(() => selectedPack = 28),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: Text(isBn ? '২১ দিনের প্যাক' : '21 Pills Pack'),
                      selected: selectedPack == 21,
                      onSelected: (_) => setDialogState(() => selectedPack = 21),
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
                await ref.read(womenOCPProvider.notifier).updateConfig(
                      isEnabled: isEnabled,
                      pillBrand: selectedBrand,
                      packDays: selectedPack,
                      pillTime: ocp.pillTime,
                    );
                if (isEnabled) {
                  // Optionally sync with medication routine
                  await ref.read(womenOCPProvider.notifier).syncWithMedicationRoutine(ref);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isBn ? 'সংরক্ষণ ও রুটিনে যুক্ত' : 'Save & Sync Routine',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showIronSettingsDialog(BuildContext context, WidgetRef ref, IronSupplementState iron, bool isBn) {
    bool isEnabled = iron.isEnabled;
    String name = iron.supplementName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Row(
            children: [
              const Icon(PhosphorIconsFill.drop, color: Color(0xFFE11D48), size: 22),
              const SizedBox(width: 8),
              Text(
                isBn ? 'আয়রন ও ফলিক এসিড রুটিন' : 'Iron & Folic Acid Routine',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  isBn ? 'আয়রন সাপ্লিমেন্ট ট্র্যাকিং চালু' : 'Enable Iron Tracking',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                value: isEnabled,
                onChanged: (val) => setDialogState(() => isEnabled = val),
              ),
              const SizedBox(height: 8),
              Text(
                isBn
                    ? 'পিরিয়ডের রক্তক্ষরণজনিত ক্লান্তি ও অ্যানিমিয়া রোধে আয়রন ও ফলিক এসিড ট্যাবলেট দুপুর বা রাতের খাবারের পর গ্রহণ করা হয়।'
                    : 'Iron & Folic Acid helps replenish hemoglobin loss during menstruation. Usually taken after lunch or dinner.',
                style: const TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF475569)),
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
                await ref.read(womenIronProvider.notifier).updateConfig(
                      isEnabled: isEnabled,
                      supplementName: name,
                      supplementTime: iron.supplementTime,
                    );
                if (isEnabled) {
                  await ref.read(womenIronProvider.notifier).syncWithMedicationRoutine(ref);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE11D48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                isBn ? 'সংরক্ষণ ও রুটিনে যুক্ত' : 'Save & Sync Routine',
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
    final ocp = ref.watch(womenOCPProvider);
    final iron = ref.watch(womenIronProvider);
    final isPeriodPhase = cycle.currentPhase == CyclePhase.menstrual;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      PhosphorIconsFill.pill,
                      size: 18,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBn ? 'দৈনিক পিল ও সাপ্লিমেন্ট কেয়ার' : 'Daily Pill & Care Routine',
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDDD6FE)),
                ),
                child: Text(
                  isBn ? 'রুটিন লিঙ্কড' : 'Routine Linked',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6D28D9),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ─── Module 1: Birth Control (OCP) Pill ───
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ocp.isEnabled ? const Color(0xFFFAF5FF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: ocp.isEnabled ? const Color(0xFFE9D5FF) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                // 1-Tap Checkbox / Status
                GestureDetector(
                  onTap: () {
                    if (!ocp.isEnabled) {
                      _showOcpSettingsDialog(context, ref, ocp, isBn);
                    } else {
                      AppFeedback.playSuccess();
                      ref.read(womenOCPProvider.notifier).toggleTakenToday();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ocp.isEnabled && ocp.isTakenToday
                          ? const Color(0xFF8B5CF6)
                          : Colors.white,
                      border: Border.all(
                        color: ocp.isEnabled && ocp.isTakenToday
                            ? const Color(0xFF8B5CF6)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      ocp.isTakenToday ? Icons.check : PhosphorIconsRegular.pill,
                      size: 20,
                      color: ocp.isEnabled && ocp.isTakenToday ? Colors.white : Colors.grey.shade400,
                    ),
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
                            isBn ? 'জন্মনিয়ন্ত্রণ পিল (OCP)' : 'Birth Control Pill (OCP)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (ocp.isEnabled) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${isBn ? "দিন " : "Day "}${WomenHealthFormatters.formatDigits(ocp.currentPackDay, isBn: isBn)}/${WomenHealthFormatters.formatDigits(ocp.packDays, isBn: isBn)}',
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF7C3AED),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        ocp.isEnabled
                            ? (ocp.isTakenToday
                                ? (isBn ? '✨ আজকের পিল গ্রহণ করা হয়েছে' : '✨ Taken for today')
                                : '${ocp.pillBrand} • ${isBn ? "আজকের পিল বাকি" : "Due today"}')
                            : (isBn ? 'নিয়মিত বড়ি গ্রহণের রিমাইন্ডার সেট করুন' : 'Tap to set up daily contraceptive pill'),
                        style: TextStyle(
                          fontSize: 11,
                          color: ocp.isTakenToday ? const Color(0xFF7C3AED) : Colors.grey.shade600,
                          fontWeight: ocp.isTakenToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.gear, size: 18, color: Color(0xFF64748B)),
                  onPressed: () => _showOcpSettingsDialog(context, ref, ocp, isBn),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ─── Module 2: Iron & Folic Acid Routine ───
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPeriodPhase ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isPeriodPhase ? const Color(0xFFFECDD3) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (!iron.isEnabled) {
                      _showIronSettingsDialog(context, ref, iron, isBn);
                    } else {
                      AppFeedback.playSuccess();
                      ref.read(womenIronProvider.notifier).toggleTakenToday();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: iron.isEnabled && iron.isTakenToday
                          ? const Color(0xFFE11D48)
                          : Colors.white,
                      border: Border.all(
                        color: iron.isEnabled && iron.isTakenToday
                            ? const Color(0xFFE11D48)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iron.isTakenToday ? Icons.check : PhosphorIconsRegular.drop,
                      size: 20,
                      color: iron.isEnabled && iron.isTakenToday ? Colors.white : Colors.grey.shade400,
                    ),
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
                            isBn ? 'আয়রন ও ফলিক এসিড' : 'Iron & Folic Acid',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          if (isPeriodPhase) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isBn ? 'পিরিয়ডে প্রয়োজন' : 'Recommended',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFBE123C),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        iron.isEnabled
                            ? (iron.isTakenToday
                                ? (isBn ? '✨ আজকের ডোজ সম্পন্ন' : '✨ Dose completed today')
                                : '${iron.supplementName} • ${isBn ? "আজকের ডোজ বাকি" : "Due today"}')
                            : (isPeriodPhase
                                ? (isBn ? 'রক্তক্ষরণজনিত ক্লান্তি রোধে ১-ট্যাপে যোগ করুন' : 'Tap to add to daily routine for anemia care')
                                : (isBn ? 'অ্যানিমিয়া ও রক্তের ঘাটতি রোধে সহায়তা করে' : 'Anemia protection & care')),
                        style: TextStyle(
                          fontSize: 11,
                          color: iron.isTakenToday ? const Color(0xFFBE123C) : Colors.grey.shade600,
                          fontWeight: iron.isTakenToday ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(PhosphorIconsRegular.gear, size: 18, color: Color(0xFF64748B)),
                  onPressed: () => _showIronSettingsDialog(context, ref, iron, isBn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

