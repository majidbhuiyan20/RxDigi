import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/core/data/models/patient_model.dart';
import 'package:rxdigi/core/data/models/prescription_model.dart';
import 'package:rxdigi/core/data/providers/prescription_provider.dart';
import 'package:rxdigi/core/data/providers/doctor_provider.dart';
import 'package:rxdigi/core/utils/pdf_generator.dart';

class PatientDetailsScreen extends ConsumerWidget {
  final PatientModel patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prescriptionsAsync = ref.watch(prescriptionListProvider);
    final doctorAsync = ref.watch(latestDoctorProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: AppColors.topHeaderColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Prescription History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  prescriptionsAsync.when(
                    data: (prescriptions) {
                      final patientPrescriptions = prescriptions
                          .where((p) => p.patientId == patient.id)
                          .toList();

                      if (patientPrescriptions.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text('No prescriptions found for this patient.'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: patientPrescriptions.length,
                        itemBuilder: (context, index) {
                          final prescription = patientPrescriptions[index];
                          return _PrescriptionHistoryCard(
                            prescription: prescription,
                            patient: patient,
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => Center(child: Text('Error: $err')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: Text(
                  patient.name[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${patient.gender ?? 'N/A'}, ${patient.age ?? 'N/A'} years',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.phone, 'Phone', patient.phone ?? 'Not provided'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on, 'Address', patient.address ?? 'Not provided'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _PrescriptionHistoryCard extends ConsumerWidget {
  final PrescriptionModel prescription;
  final PatientModel patient;

  const _PrescriptionHistoryCard({
    required this.prescription,
    required this.patient,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(latestDoctorProvider);
    final dateStr = DateFormat('dd MMM yyyy').format(prescription.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          'Prescription - $dateStr',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          prescription.diagnosis?.isNotEmpty == true
              ? 'Diagnosis: ${prescription.diagnosis}'
              : 'No diagnosis recorded',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (prescription.chiefComplaints?.isNotEmpty == true) ...[
                  const Text('Complaints:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(prescription.chiefComplaints!),
                  const SizedBox(height: 8),
                ],
                const Text('Medicines:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...prescription.medicines.map((m) => Padding(
                      padding: const EdgeInsets.only(left: 8, top: 2),
                      child: Text('• ${m.dosageForm} ${m.medicineName} (${m.dose})'),
                    )),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _printPrescription(context, ref),
                      icon: const Icon(Icons.print),
                      label: const Text('Print'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _sharePrescription(context, ref),
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _printPrescription(BuildContext context, WidgetRef ref) async {
    final doctor = ref.read(latestDoctorProvider).value;
    if (doctor == null) return;

    await PdfGenerator.printPrescription(prescription, patient, doctor);
  }

  void _sharePrescription(BuildContext context, WidgetRef ref) async {
    final doctor = ref.read(latestDoctorProvider).value;
    if (doctor == null) return;

    await PdfGenerator.sharePrescription(prescription, patient, doctor);
  }
}
