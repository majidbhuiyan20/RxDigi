import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

class StepDiagnosis extends ConsumerWidget {
  const StepDiagnosis({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prescriptionProvider);
    final notifier = ref.read(prescriptionProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            context,
            title: 'Chief Complaints *',
            initialValue: state.chiefComplaints,
            onChanged: (val) => notifier.updateChiefComplaints(val),
            commonItems: ['Fever', 'Cough', 'Body Ache', 'Headache', 'Vomiting', 'Loose Motion'],
            hint: 'Describe patient complaints...',
          ),
          const SizedBox(height: 24),
          _buildSectionHeader(
            context,
            title: 'Diagnosis *',
            initialValue: state.diagnosis,
            onChanged: (val) => notifier.updateDiagnosis(val),
            commonItems: ['Fever', 'Cold', 'UTI', 'Pneumonia', 'Gastritis', 'Anemia'],
            hint: 'Enter diagnosis or ICD code...',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Vital Signs',
            hint: 'BP, Pulse, Temp, SpO2...',
            initialValue: state.vitalSigns,
            onChanged: (val) => notifier.updateVitals(val),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Past History',
            hint: 'DM, HTN, Allergy, Surgery history...',
            initialValue: state.pastHistory,
            onChanged: (val) => notifier.updatePastHistory(val),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String? initialValue,
    required Function(String) onChanged,
    required List<String> commonItems,
    required String hint,
  }) {
    final controller = TextEditingController(text: initialValue);
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
            TextButton.icon(
              onPressed: () => _showCustomAddDialog(context, title, (val) {
                final current = initialValue ?? '';
                onChanged(current.isEmpty ? val : '$current, $val');
              }),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Custom'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: commonItems.map((item) => ActionChip(
            label: Text(item),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: AppColors.rxPrimaryColor.withOpacity(0.3)),
            ),
            onPressed: () {
              final current = initialValue ?? '';
              onChanged(current.isEmpty ? item : '$current, $item');
            },
          )).toList(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          key: Key(title),
          initialValue: initialValue,
          maxLines: 2,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint, String? initialValue, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          ),
        ),
      ],
    );
  }

  void _showCustomAddDialog(BuildContext context, String title, Function(String) onAdd) {
    final customController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom $title'),
        content: TextField(
          controller: customController,
          decoration: InputDecoration(hintText: 'Type here...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (customController.text.isNotEmpty) {
                onAdd(customController.text);
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
