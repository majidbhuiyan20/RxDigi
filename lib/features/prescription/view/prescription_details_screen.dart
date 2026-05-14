import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/prescription_model.dart';
import 'package:rxdigi/core/data/models/patient_model.dart';
import 'package:rxdigi/core/data/models/doctor_model.dart';
import 'package:rxdigi/core/data/providers/doctor_provider.dart';
import 'package:rxdigi/core/utils/pdf_generator.dart';

class PrescriptionDetailsScreen extends ConsumerWidget {
  final PrescriptionModel prescription;
  final PatientModel patient;

  const PrescriptionDetailsScreen({
    super.key,
    required this.prescription,
    required this.patient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(latestDoctorProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        title: const Text('Prescription Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadPrescription(ref),
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printPrescription(ref),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePrescription(ref),
          ),
        ],
      ),
      body: doctorAsync.when(
        data: (doctor) => _buildBody(context, doctor),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DoctorModel? doctor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Patient Information',
            icon: Icons.person,
            child: Column(
              children: [
                _buildDetailRow('Name', patient.name),
                _buildDetailRow('Age/Gender', '${patient.age ?? "N/A"}Y / ${patient.gender ?? "N/A"}'),
                _buildDetailRow('Phone', patient.phone ?? 'N/A'),
                _buildDetailRow('Date', DateFormat('dd MMM yyyy, hh:mm a').format(prescription.date)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (prescription.diagnosis?.isNotEmpty == true || prescription.chiefComplaints?.isNotEmpty == true)
            _buildSectionCard(
              title: 'Clinical Findings',
              icon: Icons.medical_services,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prescription.chiefComplaints?.isNotEmpty == true)
                    _buildLongText('Chief Complaints', prescription.chiefComplaints!),
                  if (prescription.diagnosis?.isNotEmpty == true)
                    _buildLongText('Diagnosis', prescription.diagnosis!),
                  if (prescription.vitalSigns?.isNotEmpty == true)
                    _buildLongText('Vital Signs', prescription.vitalSigns!),
                ],
              ),
            ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Medications (Rx)',
            icon: Icons.medication,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: prescription.medicines.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final med = prescription.medicines[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${med.dosageForm ?? ""} ${med.medicineName} ${med.strength ?? ""}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text('Dose: ${med.dose} | Duration: ${med.duration}',
                          style: TextStyle(color: Colors.grey[700])),
                      if (med.instruction?.isNotEmpty == true)
                        Text('Note: ${med.instruction}',
                            style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic, fontSize: 13)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (prescription.advice?.isNotEmpty == true || prescription.nextVisit?.isNotEmpty == true)
            _buildSectionCard(
              title: 'Advice & Follow-up',
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (prescription.advice?.isNotEmpty == true)
                    _buildLongText('General Advice', prescription.advice!),
                  if (prescription.nextVisit?.isNotEmpty == true)
                    _buildDetailRow('Next Visit', prescription.nextVisit!),
                ],
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const Divider(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLongText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _downloadPrescription(WidgetRef ref) async {
    final doctor = ref.read(latestDoctorProvider).value;
    if (doctor != null) {
      await PdfGenerator.downloadPrescription(prescription, patient, doctor);
    }
  }

  void _printPrescription(WidgetRef ref) async {
    final doctor = ref.read(latestDoctorProvider).value;
    if (doctor != null) {
      await PdfGenerator.printPrescription(prescription, patient, doctor);
    }
  }

  void _sharePrescription(WidgetRef ref) async {
    final doctor = ref.read(latestDoctorProvider).value;
    if (doctor != null) {
      await PdfGenerator.sharePrescription(prescription, patient, doctor);
    }
  }
}
