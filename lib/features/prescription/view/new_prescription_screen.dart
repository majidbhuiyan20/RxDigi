import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';
import 'package:rxdigi/features/prescription/widgets/step_patient_info.dart';
import 'package:rxdigi/features/prescription/widgets/step_diagnosis.dart';
import 'package:rxdigi/features/prescription/widgets/step_medicines.dart';
import 'package:rxdigi/features/prescription/widgets/step_advice.dart';
import 'package:rxdigi/features/prescription/widgets/step_preview.dart';

class NewPrescriptionScreen extends ConsumerStatefulWidget {
  const NewPrescriptionScreen({super.key});

  @override
  ConsumerState<NewPrescriptionScreen> createState() => _NewPrescriptionScreenState();
}

class _NewPrescriptionScreenState extends ConsumerState<NewPrescriptionScreen> {
  int _currentStep = 0;

  final List<String> _stepTitles = [
    'Patient',
    'Diagnosis',
    'Medicines',
    'Advice',
    'Preview',
  ];

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('New Prescription', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.topHeaderColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Show discard dialog or just pop
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          _buildStepIndicator(),
          Expanded(
            child: _buildStepContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      color: AppColors.topHeaderColor,
      child: Row(
        children: List.generate(_stepTitles.length, (index) {
          bool isActive = index <= _currentStep;
          bool isCurrent = index == _currentStep;
          
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _stepTitles[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isCurrent ? Colors.white : Colors.white.withOpacity(0.6),
                    fontSize: 10,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return const StepPatientInfo();
      case 1:
        return const StepDiagnosis();
      case 2:
        return const StepMedicines();
      case 3:
        return const StepAdvice();
      case 4:
        return const StepPreview();
      default:
        return const Center(child: Text('Unknown Step'));
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _prevStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _currentStep == _stepTitles.length - 1 
                  ? _finishPrescription 
                  : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.rxPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(_currentStep == _stepTitles.length - 1 ? 'Save & Print' : 'Next Step'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _finishPrescription() {
    // Logic to save to database and navigate to sharing/printing
  }
}
