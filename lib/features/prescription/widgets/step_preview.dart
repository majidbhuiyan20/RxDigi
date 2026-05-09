import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/prescription_model.dart';
import 'package:rxdigi/core/data/providers/doctor_provider.dart';
import 'package:rxdigi/core/data/providers/patient_provider.dart';
import 'package:rxdigi/core/data/providers/prescription_provider.dart' as core_providers;
import 'package:rxdigi/core/utils/pdf_generator.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

class StepPreview extends ConsumerStatefulWidget {
  const StepPreview({super.key});

  @override
  ConsumerState<StepPreview> createState() => _StepPreviewState();
}

class _StepPreviewState extends ConsumerState<StepPreview> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(prescriptionProvider);
    final doctorAsync = ref.watch(latestDoctorProvider);
    final patient = state.patient;
    final date = DateFormat('dd MMM yyyy').format(DateTime.now());

    return doctorAsync.when(
      data: (doctor) {
        if (doctor == null) return const Center(child: Text('Doctor profile not found'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Real Doctor Info)
                    Text('${doctor.title ?? ''} ${doctor.fullName}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
                    Text(doctor.degrees ?? '', style: const TextStyle(fontSize: 12)),
                    Text(doctor.specialization ?? '', style: const TextStyle(fontSize: 12)),
                    if (doctor.bmdcRegNo != null)
                      Text('BMDC Reg: ${doctor.bmdcRegNo}', style: const TextStyle(fontSize: 12)),
                    const Divider(height: 32, thickness: 1.5),

                    // Patient Info Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('Name: ${patient?.name ?? "N/A"}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        Text('Age: ${patient?.age ?? "N/A"}Y / ${patient?.gender?.substring(0, 1) ?? "N/A"}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date: $date'),
                        Text('Phone: ${patient?.phone ?? "N/A"}'),
                      ],
                    ),
                    const Divider(height: 32),

                    // Complaints & Diagnosis
                    if (state.chiefComplaints != null && state.chiefComplaints!.isNotEmpty) ...[
                      const Text('C/C:', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      Text(state.chiefComplaints!),
                      const SizedBox(height: 12),
                    ],

                    if (state.diagnosis != null && state.diagnosis!.isNotEmpty) ...[
                      const Text('Diagnosis:', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      Text(state.diagnosis!, style: const TextStyle(fontWeight: FontWeight.w500)),
                      const SizedBox(height: 12),
                    ],

                    if (state.pastHistory != null && state.pastHistory!.isNotEmpty) ...[
                      const Text('Past History:', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                      Text(state.pastHistory!),
                      const SizedBox(height: 12),
                    ],
                    
                    if (state.vitalSigns != null && state.vitalSigns!.isNotEmpty) ...[
                      Text('Vitals: ${state.vitalSigns!}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 12),
                    ],

                    Text('Rx', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
                    const SizedBox(height: 8),

                    // Medicines List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.medicines.length,
                      itemBuilder: (context, index) {
                        final med = state.medicines[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${index + 1}. ', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${med.medicineName} ${med.strength ?? ""}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('${med.dose} — ${med.instruction} — ${med.duration}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    if (state.labTests.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text('Investigations:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...state.labTests.map((test) => Text('• $test')),
                    ],

                    if (state.advice != null && state.advice!.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text('Advice:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(state.advice!),
                    ],

                    if (state.nextVisit != null && state.nextVisit!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text('Follow-up: ${state.nextVisit}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                    
                    const SizedBox(height: 60),
                    const Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        children: [
                          Divider(indent: 200),
                          Text('Doctor\'s Signature', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _printPrescription(state, doctor),
                      icon: const Icon(Icons.print),
                      label: const Text('Print Preview'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : () => _savePrescription(state),
                      icon: _isSaving 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Rx'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  void _printPrescription(PrescriptionState state, dynamic doctor) async {
    final prescription = PrescriptionModel(
      patientId: state.patient!.id ?? -1,
      doctorId: doctor.id,
      date: DateTime.now(),
      chiefComplaints: state.chiefComplaints,
      diagnosis: state.diagnosis,
      vitalSigns: state.vitalSigns,
      pastHistory: state.pastHistory,
      medicines: state.medicines,
      advice: state.advice,
      nextVisit: state.nextVisit,
      labTests: state.labTests,
    );
    await PdfGenerator.printPrescription(prescription, state.patient!, doctor);
  }

  void _savePrescription(PrescriptionState state) async {
    setState(() => _isSaving = true);
    final notifier = ref.read(prescriptionProvider.notifier);
    
    final id = await notifier.savePrescription();

    if (id != -1 && mounted) {
      ref.invalidate(core_providers.prescriptionListProvider);
      ref.invalidate(patientListProvider);
      notifier.reset();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prescription saved successfully')),
      );
      
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save prescription')),
      );
    }
  }
}
