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

    final List<String> commonComplaints = ['Fever', 'Cough', 'Cold', 'Headache', 'Abdominal Pain', 'Weakness'];
    final List<String> commonDiagnosis = ['Viral Fever', 'Acute Pharyngitis', 'UTI', 'Hypertension', 'Diabetes Mellitus'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Chief Complaints'),
          const SizedBox(height: 8),
          _buildQuickChips(commonComplaints, (val) {
             final current = state.chiefComplaints ?? '';
             notifier.updateChiefComplaints(current.isEmpty ? val : '$current, $val');
          }),
          const SizedBox(height: 12),
          _buildTextField(
            initialValue: state.chiefComplaints,
            hint: 'Describe patient problems...',
            onChanged: notifier.updateChiefComplaints,
            maxLines: 3,
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Diagnosis'),
          const SizedBox(height: 8),
          _buildQuickChips(commonDiagnosis, (val) {
             final current = state.diagnosis ?? '';
             notifier.updateDiagnosis(current.isEmpty ? val : '$current, $val');
          }),
          const SizedBox(height: 12),
          _buildTextField(
            initialValue: state.diagnosis,
            hint: 'Enter diagnosis or ICD code...',
            onChanged: notifier.updateDiagnosis,
            maxLines: 2,
          ),

          const SizedBox(height: 24),
          _buildSectionTitle('Vital Signs (Optional)'),
          const SizedBox(height: 12),
          _buildTextField(
            initialValue: state.vitalSigns,
            hint: 'BP: 120/80, Pulse: 72, Temp: 98.6...',
            onChanged: notifier.updateVitals,
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor),
    );
  }

  Widget _buildQuickChips(List<String> items, Function(String) onSelect) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) => ActionChip(
        label: Text(item),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.rxPrimaryColor.withOpacity(0.3)),
        ),
        onPressed: () => onSelect(item),
      )).toList(),
    );
  }

  Widget _buildTextField({
    String? initialValue,
    required String hint,
    required Function(String) onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
