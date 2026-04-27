import 'package:flutter/material.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/medicine_in_prescription_model.dart';
import 'package:rxdigi/core/data/models/medicine_model.dart';

class AddMedicineDetailsDialog extends StatefulWidget {
  final MedicineModel medicine;
  final MedicineInPrescription? existingMedicine;

  const AddMedicineDetailsDialog({
    super.key,
    required this.medicine,
    this.existingMedicine,
  });

  @override
  State<AddMedicineDetailsDialog> createState() =>
      _AddMedicineDetailsDialogState();
}

class _AddMedicineDetailsDialogState extends State<AddMedicineDetailsDialog> {
  late TextEditingController _doseController;
  late TextEditingController _durationController;
  late TextEditingController _instructionController;

  final List<String> _commonDoses = [
    '1+0+0',
    '0+1+0',
    '0+0+1',
    '1+0+1',
    '1+1+1',
    '1+1+0',
    '0+1+1',
  ];

  final List<String> _commonDurations = [
    '3 days',
    '5 days',
    '7 days',
    '10 days',
    '14 days',
    '21 days',
    '30 days',
  ];

  final List<String> _commonInstructions = [
    'Before meal',
    'After meal',
    'With meal',
    'Twice daily',
    'Three times daily',
    'Morning & Evening',
    'Bedtime',
    'Before sleep',
  ];

  @override
  void initState() {
    super.initState();
    _doseController = TextEditingController(
      text: widget.existingMedicine?.dose ?? '',
    );
    _durationController = TextEditingController(
      text: widget.existingMedicine?.duration ?? '',
    );
    _instructionController = TextEditingController(
      text: widget.existingMedicine?.instruction ?? '',
    );
  }

  @override
  void dispose() {
    _doseController.dispose();
    _durationController.dispose();
    _instructionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add Medicine Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              
              // Medicine Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.medicine.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Strength: ${widget.medicine.strength}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Dose Field
              Text(
                'Dose Pattern *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _doseController,
                decoration: InputDecoration(
                  hintText: 'e.g., 1+0+1',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.borderColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonDoses.length,
                  itemBuilder: (context, index) {
                    final dose = _commonDoses[index];
                    final isSelected = _doseController.text == dose;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(dose),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _doseController.text = dose;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primaryColor.withOpacity(0.3),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Duration Field
              Text(
                'Duration *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _durationController,
                decoration: InputDecoration(
                  hintText: 'e.g., 5 days',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.borderColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonDurations.length,
                  itemBuilder: (context, index) {
                    final duration = _commonDurations[index];
                    final isSelected = _durationController.text == duration;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(duration),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _durationController.text = duration;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primaryColor.withOpacity(0.3),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Instructions Field
              Text(
                'Instructions *',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlackColor,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _instructionController,
                decoration: InputDecoration(
                  hintText: 'e.g., After meal',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColors.borderColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _commonInstructions.length,
                  itemBuilder: (context, index) {
                    final instruction = _commonInstructions[index];
                    final isSelected = _instructionController.text == instruction;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(instruction, maxLines: 1, overflow: TextOverflow.ellipsis),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _instructionController.text = instruction;
                          });
                        },
                        backgroundColor: Colors.white,
                        selectedColor: AppColors.primaryColor.withOpacity(0.3),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryColor
                              : Colors.grey[300]!,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: AppColors.borderColor,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_doseController.text.isEmpty ||
                            _durationController.text.isEmpty ||
                            _instructionController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill all fields'),
                            ),
                          );
                          return;
                        }

                        final medicineInPrescription =
                            MedicineInPrescription.fromMedicineModel(
                          widget.medicine,
                          dose: _doseController.text,
                          duration: _durationController.text,
                          instruction: _instructionController.text,
                        );

                        Navigator.pop(context, medicineInPrescription);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
