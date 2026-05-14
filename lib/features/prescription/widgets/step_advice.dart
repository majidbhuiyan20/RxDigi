import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/repositories/common_advice_repository.dart';
import 'package:rxdigi/core/data/repositories/common_lab_test_repository.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

final commonAdviceProvider = FutureProvider<List<String>>((ref) {
  return CommonAdviceRepository().getCommonAdvice();
});

final commonLabTestProvider = FutureProvider<List<String>>((ref) {
  return CommonLabTestRepository().getCommonLabTests();
});

class StepAdvice extends ConsumerWidget {
  const StepAdvice({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prescriptionProvider);
    final notifier = ref.read(prescriptionProvider.notifier);
    final commonAdviceAsync = ref.watch(commonAdviceProvider);
    final commonLabTestsAsync = ref.watch(commonLabTestProvider);

    final List<String> defaultAdvice = [
      'Drink plenty of water',
      'Take complete rest',
      'Avoid cold food/drinks',
      'Walk for 30 minutes daily',
      'Stop smoking',
      'Avoid oily and spicy food',
      'Eat fresh fruits and vegetables',
      'Maintain personal hygiene'
    ];

    final List<String> defaultTests = [
      'CBC', 'CRP', 'Blood Sugar (F/PP)', 'Urine R/M/E', 'X-ray Chest P/A View', 'ECG', 'USG of W/A', 'Lipid Profile'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          commonAdviceAsync.when(
            data: (commonList) => _buildMultiChipSection(
              context,
              title: 'Advice',
              currentValue: state.advice,
              onChanged: (val) => notifier.updateAdvice(val),
              commonItems: commonList.isEmpty ? defaultAdvice : commonList,
              hint: 'Add custom advice...',
              onCustomAdd: (val) async {
                await CommonAdviceRepository().addOrUpdateAdvice(val);
                ref.invalidate(commonAdviceProvider);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          commonLabTestsAsync.when(
            data: (commonList) => _buildLabTestSection(
              context,
              state,
              notifier,
              commonList.isEmpty ? defaultTests : commonList,
              onCustomAdd: (val) async {
                await CommonLabTestRepository().addOrUpdateLabTest(val);
                ref.invalidate(commonLabTestProvider);
              },
            ),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
          const Text('Follow-up / Next Visit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
          const SizedBox(height: 12),
          TextFormField(
            key: Key('next_visit_${state.nextVisit}'),
            initialValue: state.nextVisit,
            onChanged: notifier.updateNextVisit,
            decoration: InputDecoration(
              hintText: 'e.g. After 7 days or 15/05/2026',
              prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryColor),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
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
        ? currentValue.split('. ').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
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
                  onChanged(newList.join('. '));
                  if (onCustomAdd != null) onCustomAdd(val);
                }
              }),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Custom'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Suggestions (Common items)
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
                  onChanged(newList.join('. '));
                  if (onCustomAdd != null) onCustomAdd(item);
                } else {
                  final newList = selectedItems.where((e) => e != item).toList();
                  onChanged(newList.join('. '));
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Selected Items (shown as removable chips)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: selectedItems.isEmpty
              ? Center(child: Text('No $title selected', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: selectedItems.map((item) => InputChip(
                    label: Text(item),
                    onDeleted: () {
                      final newList = selectedItems.where((e) => e != item).toList();
                      onChanged(newList.join('. '));
                    },
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    deleteIconColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  )).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildLabTestSection(
    BuildContext context,
    PrescriptionState state,
    PrescriptionNotifier notifier,
    List<String> commonItems, {
    Function(String)? onCustomAdd,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Lab Tests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
            TextButton.icon(
              onPressed: () => _showCustomAddDialog(context, 'Lab Test', 'e.g. MRI Brain', (val) {
                notifier.addLabTest(val);
                if (onCustomAdd != null) onCustomAdd(val);
              }),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Custom'),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Suggestions
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonItems.map((test) {
            final isSelected = state.labTests.contains(test);
            return ActionChip(
              label: Text(test),
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
                if (isSelected) {
                  notifier.removeLabTest(test);
                } else {
                  notifier.addLabTest(test);
                  if (onCustomAdd != null) onCustomAdd(test);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        // Selected Tests as Chips
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: state.labTests.isEmpty
              ? Center(child: Text('No Lab Tests selected', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)))
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.labTests.map((test) => InputChip(
                    label: Text(test),
                    onDeleted: () => notifier.removeLabTest(test),
                    backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                    deleteIconColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
