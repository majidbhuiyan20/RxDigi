import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../models/vital_log_model.dart';
import '../provider/vitals_provider.dart';

class AddVitalSheet extends ConsumerStatefulWidget {
  final String initialType;

  const AddVitalSheet({super.key, this.initialType = 'BP'});

  @override
  ConsumerState<AddVitalSheet> createState() => _AddVitalSheetState();
}

class _AddVitalSheetState extends ConsumerState<AddVitalSheet> {
  late String _selectedType;
  final TextEditingController _val1Controller = TextEditingController();
  final TextEditingController _val2Controller = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _sugarCategory = 'Fasting';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _val1Controller.dispose();
    _val2Controller.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveVital() {
    final v1 = double.tryParse(_val1Controller.text.trim());
    if (v1 == null || v1 <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid value')),
      );
      return;
    }

    double? v2;
    if (_selectedType == 'BP' || _selectedType == 'WEIGHT') {
      v2 = double.tryParse(_val2Controller.text.trim());
    }

    String unit = 'mmHg';
    if (_selectedType == 'SUGAR') unit = 'mmol/L';
    if (_selectedType == 'WEIGHT') unit = 'kg';

    final vital = VitalLogModel(
      type: _selectedType,
      value1: v1,
      value2: v2,
      unit: unit,
      category: _selectedType == 'SUGAR' ? _sugarCategory : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      recordedAt: DateTime.now(),
    );

    ref.read(vitalsListProvider.notifier).addVital(vital);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            const SizedBox(height: 16),
            const Text(
              'Log Health Vital',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                _buildTypeChip('BP', 'Blood Pressure', Icons.favorite_rounded, const Color(0xFFE53935)),
                const SizedBox(width: 8),
                _buildTypeChip('SUGAR', 'Sugar', Icons.water_drop_rounded, const Color(0xFF1E88E5)),
                const SizedBox(width: 8),
                _buildTypeChip('WEIGHT', 'Weight/BMI', Icons.monitor_weight_rounded, const Color(0xFF00897B)),
              ],
            ),
            const SizedBox(height: 20),

            if (_selectedType == 'BP') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _val1Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Systolic (Top)',
                        hintText: '120',
                        suffixText: 'mmHg',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _val2Controller,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Diastolic (Bottom)',
                        hintText: '80',
                        suffixText: 'mmHg',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedType == 'SUGAR') ...[
              TextField(
                controller: _val1Controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Blood Glucose',
                  hintText: '5.6',
                  suffixText: 'mmol/L',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _sugarCategory,
                decoration: InputDecoration(
                  labelText: 'Timing',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'Fasting', child: Text('Fasting (খালি পেটে)')),
                  DropdownMenuItem(value: 'Post-Meal', child: Text('2h Post-Meal (খাবার ২ ঘণ্টা পর)')),
                  DropdownMenuItem(value: 'Random', child: Text('Random (যেকোনো সময়)')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _sugarCategory = val);
                },
              ),
            ] else if (_selectedType == 'WEIGHT') ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _val1Controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Weight',
                        hintText: '68',
                        suffixText: 'kg',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _val2Controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Height',
                        hintText: '170',
                        suffixText: 'cm',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'e.g. Felt dizzy, after morning walk...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveVital,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Save Record', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, String label, IconData icon, Color color) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedType = type;
            _val1Controller.clear();
            _val2Controller.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.12) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey.shade600, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
