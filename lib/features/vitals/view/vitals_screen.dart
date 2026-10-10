import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../models/vital_log_model.dart';
import '../provider/vitals_provider.dart';
import '../widgets/vital_trend_chart.dart';
import '../widgets/doctor_report_export_sheet.dart';
import 'add_vital_sheet.dart';

class VitalsScreen extends ConsumerStatefulWidget {
  const VitalsScreen({super.key});

  @override
  ConsumerState<VitalsScreen> createState() => _VitalsScreenState();
}

class _VitalsScreenState extends ConsumerState<VitalsScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final vitalsAsync = ref.watch(vitalsListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'স্বাস্থ্য পরিমাপক (Vitals)' : 'Health Vitals Tracker',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          vitalsAsync.maybeWhen(
            data: (logs) => logs.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => DoctorReportExportSheet.show(context, logs),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(PhosphorIconsFill.filePdf, size: 14, color: Color(0xFFEF4444)),
                            const SizedBox(width: 4),
                            Text(
                              isBn ? 'ডাক্তার সামারি' : 'Doctor PDF',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => AddVitalSheet.show(context),
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
                      isBn ? 'নতুন পরিমাপ' : 'Log Vital',
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
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Pill Filter Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Container(
                height: 42,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _buildSegmentTab('ALL', isBn ? 'সকল' : 'All', PhosphorIconsRegular.squaresFour),
                    _buildSegmentTab('BP', isBn ? 'রক্তচাপ' : 'BP', PhosphorIconsRegular.heartbeat),
                    _buildSegmentTab('SUGAR', isBn ? 'সুগার' : 'Sugar', PhosphorIconsRegular.drop),
                    _buildSegmentTab('WEIGHT', isBn ? 'ওজন' : 'Weight', PhosphorIconsRegular.scales),
                  ],
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: vitalsAsync.when(
                data: (list) {
                  final filtered = _selectedFilter == 'ALL'
                      ? list
                      : list.where((v) => v.type == _selectedFilter).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState(isBn);
                  }

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 110),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      VitalTrendChart(logs: list, vitalType: _selectedFilter),

                      // Clinical 1-Click Doctor Summary Report Banner
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => DoctorReportExportSheet.show(context, list),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F766E).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(PhosphorIconsFill.filePdf, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isBn ? 'ডাক্তার ভিজিট সামারি PDF' : 'Doctor Visit Summary (PDF)',
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        isBn
                                            ? 'রক্তচাপ ও সুগার চার্টসহ ১-পৃষ্ঠার রিপোর্ট প্রস্তুত'
                                            : 'Export 1-page clinical log for physician',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    isBn ? 'এক্সপোর্ট' : 'Export',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F766E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isBn
                                  ? 'পরিমাপের হিস্ট্রি (Measurement Logs)'
                                  : 'Measurement History',
                              style: const TextStyle(
                                fontSize: 14,
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
                                '${filtered.length} ${isBn ? "টি রেকর্ড" : "records"}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...filtered.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildVitalCard(item, isBn),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentTab(String key, String label, IconData icon) {
    final isSelected = _selectedFilter == key;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedFilter = key);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primaryColor : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isBn) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(PhosphorIconsRegular.heartbeat, size: 56, color: Color(0xFFEF4444)),
            ),
            const SizedBox(height: 18),
            Text(
              isBn ? 'কোনো পরিমাপ রেকর্ড নেই' : 'No Vitals Recorded Yet',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isBn
                  ? 'আপনার রক্তচাপ, ডায়াবেটিস বা ওজন নিয়মিত ট্র্যাক করে সুস্থ থাকুন।'
                  : 'Log blood pressure, blood glucose or weight to track your health trends.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddVitalSheet(
                    initialType: _selectedFilter == 'ALL' ? 'BP' : _selectedFilter,
                  ),
                );
              },
              icon: const Icon(PhosphorIconsBold.plus, color: Colors.white, size: 16),
              label: Text(
                isBn ? 'প্রথম পরিমাপ যোগ করুন' : 'Log First Vital',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalCard(VitalLogModel item, bool isBn) {
    Color cardColor;
    IconData icon;
    String valueText = '';
    String? subtext;

    if (item.type == 'BP') {
      cardColor = const Color(0xFFEF4444);
      icon = PhosphorIconsFill.heartbeat;
      valueText = '${item.value1.toInt()}/${item.value2?.toInt() ?? 0} ${item.unit}';
      subtext = item.getBpStatus();
    } else if (item.type == 'SUGAR') {
      cardColor = const Color(0xFFEA580C);
      icon = PhosphorIconsFill.drop;
      valueText = '${item.value1.toStringAsFixed(1)} ${item.unit}';
      subtext = item.category ?? 'Random';
    } else {
      cardColor = const Color(0xFF0D9488);
      icon = PhosphorIconsFill.scales;
      valueText = '${item.value1.toStringAsFixed(1)} ${item.unit}';
      final bmi = item.getBmi();
      if (bmi != null) {
        subtext = 'BMI: ${bmi.toStringAsFixed(1)}';
      }
    }

    final dateStr = DateFormat('d MMM yyyy, h:mm a').format(item.recordedAt);

    return Dismissible(
      key: Key('vital_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(PhosphorIconsRegular.trash, color: Colors.white, size: 22),
      ),
      onDismissed: (_) async {
        if (item.id != null) {
          await ref.read(vitalsRepositoryProvider).deleteVital(item.id!);
          ref.invalidate(vitalsListProvider);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cardColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (subtext != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: cardColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            subtext,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: cardColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        dateStr,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.notes!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
