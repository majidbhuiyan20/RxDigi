import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/repositories/common_diagnosis_repository.dart';
import 'package:rxdigi/core/data/repositories/common_complaint_repository.dart';
import 'package:rxdigi/core/data/repositories/common_past_history_repository.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

final commonDiagnosisProvider = FutureProvider<List<String>>((ref) {
  return CommonDiagnosisRepository().getCommonDiagnosis();
});

final commonComplaintsProvider = FutureProvider<List<String>>((ref) {
  return CommonComplaintRepository().getCommonComplaints();
});

final commonPastHistoryProvider = FutureProvider<List<String>>((ref) {
  return CommonPastHistoryRepository().getCommonPastHistory();
});

class StepDiagnosis extends ConsumerWidget {
  const StepDiagnosis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prescriptionProvider);
    final notifier = ref.read(prescriptionProvider.notifier);
    final commonDiagnosisAsync = ref.watch(commonDiagnosisProvider);
    final commonComplaintsAsync = ref.watch(commonComplaintsProvider);
    final commonPastHistoryAsync = ref.watch(commonPastHistoryProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonComplaintsAsync.when(
            data: (commonList) => _buildMultiChipSection(
              context,
              title: 'Chief Complaints *',
              currentValue: state.chiefComplaints,
              onChanged: (val) => notifier.updateChiefComplaints(val),
              commonItems: commonList.isEmpty 
                  ? const ['Fever', 'Cough', 'Body Ache', 'Headache', 'Vomiting', 'Loose Motion', 'Cold', 'Weakness', 'Chest Pain', 'Abdominal Pain']
                  : commonList,
              hint: 'Add custom complaint...',
              onCustomAdd: (val) async {
                 await CommonComplaintRepository().addOrUpdateComplaint(val);
                 ref.invalidate(commonComplaintsProvider);
              }
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          commonDiagnosisAsync.when(
            data: (commonList) => _buildMultiChipSection(
              context,
              title: 'Diagnosis *',
              currentValue: state.diagnosis,
              onChanged: (val) => notifier.updateDiagnosis(val),
              commonItems: commonList.isEmpty 
                  ? const ['Fever', 'Cold', 'UTI', 'Pneumonia', 'Gastritis', 'Anemia', 'Hypertension', 'Diabetes'] 
                  : commonList,
              hint: 'Add custom diagnosis...',
              onCustomAdd: (val) async {
                 await CommonDiagnosisRepository().addOrUpdateDiagnosis(val);
                 ref.invalidate(commonDiagnosisProvider);
              }
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          _buildMultiChipSection(
            context,
            title: 'Vital Signs',
            currentValue: state.vitalSigns,
            onChanged: (val) => notifier.updateVitals(val),
            commonItems: const ['BP', 'Pulse', 'Temp', 'SpO2', 'RR', 'Weight', 'Height'],
            hint: 'Add vital sign (e.g. BP: 120/80)...',
          ),
          const SizedBox(height: 32),
          commonPastHistoryAsync.when(
            data: (commonList) => _buildMultiChipSection(
              context,
              title: 'Past History',
              currentValue: state.pastHistory,
              onChanged: (val) => notifier.updatePastHistory(val),
              commonItems: commonList.isEmpty 
                  ? const ['DM', 'HTN', 'BA', 'CKD', 'IHD', 'Surgery', 'Allergy', 'Asthma']
                  : commonList,
              hint: 'Add past history...',
              onCustomAdd: (val) async {
                 await CommonPastHistoryRepository().addOrUpdatePastHistory(val);
                 ref.invalidate(commonPastHistoryProvider);
              }
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildMultiChipSection(
    BuildContext context, {
    required String title,
    required String? currentValue,
    required Function(String) onChanged,
    required List<String> commonItems,
    required String hint,
    Function(String)? onCustomAdd,
  }) {
    final List<String> selectedItems = currentValue != null && currentValue.trim().isNotEmpty
        ? currentValue.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
            TextButton.icon(
              onPressed: () => _showCustomAddDialog(context, title, hint, (val) {
                if (!selectedItems.contains(val)) {
                  final newList = [val, ...selectedItems];
                  onChanged(newList.join(', '));
                  if (onCustomAdd != null) onCustomAdd(val);
                }
              }),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Custom'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Suggestions (Common items) - Now shown ABOVE the selection box
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonItems.map((item) {
            final isSelected = selectedItems.contains(item);
            return ActionChip(
              label: Text(item),
              backgroundColor: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
              labelStyle: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primaryColor : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppColors.primaryColor : Colors.grey.shade300),
              ),
              onPressed: () {
                if (!isSelected) {
                  final newList = [item, ...selectedItems];
                  onChanged(newList.join(', '));
                } else {
                  final newList = selectedItems.where((e) => e != item).toList();
                  onChanged(newList.join(', '));
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Selected Items (shown as removable chips)
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: selectedItems.isEmpty
              ? Center(
                  child: Text('No items selected', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedItems.map((item) => InputChip(
                    label: Text(item),
                    onDeleted: () {
                      final newList = selectedItems.where((e) => e != item).toList();
                      onChanged(newList.join(', '));
                    },
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    deleteIconColor: Colors.red,
                    side: BorderSide(color: AppColors.primaryColor.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  )).toList(),
                ),
        ),
      ],
    );
  }

  void _showCustomAddDialog(BuildContext context, String title, String hint, Function(String) onAdd) {
    final customController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $title'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: TextField(
          controller: customController,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (customController.text.trim().isNotEmpty) {
                onAdd(customController.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
