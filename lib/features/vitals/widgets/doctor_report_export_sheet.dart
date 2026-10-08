import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../app/app_colors.dart';
import '../../../core/utils/app_feedback.dart';
import '../models/vital_log_model.dart';
import '../services/doctor_vitals_report_generator.dart';

class DoctorReportExportSheet extends StatefulWidget {
  final List<VitalLogModel> logs;

  const DoctorReportExportSheet({
    super.key,
    required this.logs,
  });

  static Future<void> show(BuildContext context, List<VitalLogModel> logs) {
    AppFeedback.playLight();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DoctorReportExportSheet(logs: logs),
    );
  }

  @override
  State<DoctorReportExportSheet> createState() => _DoctorReportExportSheetState();
}

class _DoctorReportExportSheetState extends State<DoctorReportExportSheet> {
  int _selectedDays = 14;
  bool _isGenerating = false;

  int _getFilteredCount() {
    if (_selectedDays == 0) return widget.logs.length;
    final cutoff = DateTime.now().subtract(Duration(days: _selectedDays));
    return widget.logs.where((l) => l.recordedAt.isAfter(cutoff)).length;
  }

  Future<void> _handleAction(bool isShare) async {
    setState(() => _isGenerating = true);
    AppFeedback.playSuccess();
    try {
      if (isShare) {
        await DoctorVitalsReportGenerator.shareReport(
          logs: widget.logs,
          daysFilter: _selectedDays,
        );
      } else {
        await DoctorVitalsReportGenerator.printReport(
          logs: widget.logs,
          daysFilter: _selectedDays,
        );
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF তৈরি করতে সমস্যা হয়েছে: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final count = _getFilteredCount();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(PhosphorIconsFill.filePdf, size: 26, color: Color(0xFFEF4444)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isBn ? 'ডাক্তার ভিজিট সামারি PDF' : 'Doctor Summary Report (PDF)',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isBn
                            ? 'ক্লিনিক্যাল ১-পৃষ্ঠার রিপোর্ট প্রস্তুত করুন'
                            : 'Generate 1-page clinical vitals summary',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(PhosphorIconsBold.x, size: 18),
                  color: Colors.grey.shade600,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Timeframe Segmented Selection
            Text(
              isBn ? 'রিপোর্টের সময়কাল নির্বাচন করুন' : 'Select Timeframe Window',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildTimeOption(7, isBn ? '৭ দিন' : '7 Days'),
                const SizedBox(width: 8),
                _buildTimeOption(14, isBn ? '১৪ দিন' : '14 Days'),
                const SizedBox(width: 8),
                _buildTimeOption(30, isBn ? '৩০ দিন' : '30 Days'),
                const SizedBox(width: 8),
                _buildTimeOption(0, isBn ? 'সব' : 'All'),
              ],
            ),
            const SizedBox(height: 16),

            // Summary Info Badge
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(PhosphorIconsFill.checkCircle, size: 20, color: AppColors.primaryColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'এই রিপোর্টে মোট $count টি পরিমাপের ডেটা ও AHA চার্ট জোন অন্তর্ভুক্ত হবে।'
                          : '$count logs with AHA/WHO clinical zones will be compiled.',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Action Buttons
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: AppColors.primaryColor),
                ),
              )
            else
              Row(
                children: [
                  // Print / Preview Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleAction(false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.primaryColor, width: 1.5),
                      ),
                      icon: const Icon(PhosphorIconsBold.printer, size: 18, color: AppColors.primaryColor),
                      label: Text(
                        isBn ? 'প্রিভিউ / প্রিন্ট' : 'Preview & Print',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // WhatsApp / Share Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAction(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      icon: const Icon(PhosphorIconsFill.shareNetwork, size: 18, color: Colors.white),
                      label: Text(
                        isBn ? 'ডাক্তারকে পাঠান' : 'Share to Doctor',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOption(int days, String label) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          AppFeedback.playSelection();
          setState(() => _selectedDays = days);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : Colors.transparent,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : const Color(0xFF475569),
            ),
          ),
        ),
      ),
    );
  }
}
