import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/medicine_in_prescription_model.dart';
import 'package:rxdigi/core/data/models/medicine_model.dart';
import 'package:rxdigi/core/data/models/patient_model.dart';
import 'package:rxdigi/core/data/models/prescription_model.dart';
import 'package:rxdigi/core/data/providers/patient_provider.dart';
import 'package:rxdigi/core/data/providers/prescription_provider.dart';
import 'package:rxdigi/features/prescription_management/widgets/add_medicine_details_dialog.dart';
import 'medicine_search_screen.dart';

class CreatePrescriptionScreen extends ConsumerStatefulWidget {
  const CreatePrescriptionScreen({super.key});

  @override
  ConsumerState<CreatePrescriptionScreen> createState() =>
      _CreatePrescriptionScreenState();
}

class _CreatePrescriptionScreenState
    extends ConsumerState<CreatePrescriptionScreen> {
  late TextEditingController _diagnosisController;
  late TextEditingController _notesController;

  PatientModel? _selectedPatient;
  DateTime? _selectedDate;
  List<MedicineInPrescription> _selectedMedicines = [];

  @override
  void initState() {
    super.initState();
    _diagnosisController = TextEditingController();
    _notesController = TextEditingController();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectMedicines() async {
    final selected = await Navigator.push<List<MedicineModel>>(
      context,
      MaterialPageRoute(
        builder: (_) => MedicineSearchScreen(
          selectedMedicines: _selectedMedicines
              .map((m) => MedicineModel(
                    id: m.medicineId,
                    name: m.medicineName ?? '',
                    genericName: m.genericName,
                    manufacturer: m.manufacturer,
                    strength: m.strength,
                    dosageForm: '',
                    price: 0,
                  ))
              .toList(),
        ),
      ),
    );

    if (selected != null) {
      for (final medicine in selected) {
        // Check if medicine already added
        final existingIndex = _selectedMedicines
            .indexWhere((m) => m.medicineName == medicine.name);

        if (existingIndex < 0) {
          // New medicine - show details dialog
          final result = await showDialog<MedicineInPrescription>(
            context: context,
            builder: (_) => AddMedicineDetailsDialog(medicine: medicine),
          );

          if (result != null) {
            setState(() {
              _selectedMedicines.add(result);
            });
          }
        } else {
          // Medicine already added - update details
          final result = await showDialog<MedicineInPrescription>(
            context: context,
            builder: (_) => AddMedicineDetailsDialog(
              medicine: medicine,
              existingMedicine: _selectedMedicines[existingIndex],
            ),
          );

          if (result != null) {
            setState(() {
              _selectedMedicines[existingIndex] = result;
            });
          }
        }
      }
    }
  }

  Future<void> _savePrescription() async {
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient')),
      );
      return;
    }

    if (_selectedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one medicine')),
      );
      return;
    }

    try {
      final prescription = PrescriptionModel(
        patientId: _selectedPatient!.id ?? 0,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate ?? DateTime.now()),
        diagnosis: _diagnosisController.text,
        notes: _notesController.text,
        medicinesDetails: _selectedMedicines,
      );

      await ref.read(addPrescriptionProvider(prescription).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription created successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final patients = ref.watch(patientListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Prescription'),
        backgroundColor: const Color(0xFF0D3592),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Selection
            Text(
              'Select Patient *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            patients.when(
              data: (patientList) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.borderColor,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  child: DropdownButton<PatientModel>(
                    value: _selectedPatient,
                    hint: const Text('Choose patient'),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: patientList.map((patient) {
                      return DropdownMenuItem(
                        value: patient,
                        child: Text(patient.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPatient = value;
                      });
                    },
                  ),
                );
              },
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 20),

            // Date Selection
            Text(
              'Prescription Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, color: AppColors.textGreyColor),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate ?? DateTime.now()),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Diagnosis
            Text(
              'Diagnosis',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _diagnosisController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter patient diagnosis',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
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
            const SizedBox(height: 20),

            // Medicines
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Medicines *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textBlackColor,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _selectMedicines,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Medicine'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_selectedMedicines.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No medicines added yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _selectedMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = _selectedMedicines[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicine.medicineName ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (medicine.strength != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Strength: ${medicine.strength}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedMedicines.removeAt(index);
                                });
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dose',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    medicine.dose ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duration',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    medicine.duration ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instructions',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    medicine.instruction ?? '',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),

            // Notes
            Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter any additional notes',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderColor),
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
            const SizedBox(height: 32),

            // Save Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.borderColor,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _savePrescription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Create Prescription',
                      style: TextStyle(
                        fontSize: 16,
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
    );
  }
}
