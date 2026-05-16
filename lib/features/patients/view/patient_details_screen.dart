import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/core/data/models/patient_model.dart';
import 'package:prescripto/core/data/models/prescription_model.dart';
import 'package:prescripto/core/data/providers/prescription_provider.dart';
import 'package:prescripto/core/data/providers/doctor_provider.dart';
import 'package:prescripto/core/utils/pdf_generator.dart';
import 'package:prescripto/core/data/providers/patient_provider.dart';
import 'package:prescripto/features/prescription/provider/prescription_provider.dart';
import 'package:prescripto/features/prescription/view/new_prescription_screen.dart';
import 'package:prescripto/features/prescription/view/prescription_details_screen.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDeletePatient(context, ref),
          ),
        ],
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prescription History',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () => _addNewPrescription(context, ref),
                        icon: const Icon(Icons.add),
                        label: const Text('New Rx'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  prescriptionsAsync.when(
                    data: (prescriptions) {
                      final patientPrescriptions = prescriptions
                          .where((p) => p.patientId == patient.id)
                          .toList()
                        ..sort((a, b) => b.date.compareTo(a.date));

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

  void _addNewPrescription(BuildContext context, WidgetRef ref) {
    // Reset and set the current patient
    ref.read(prescriptionProvider.notifier).reset();
    ref.read(prescriptionProvider.notifier).setPatient(patient);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NewPrescriptionScreen(),
      ),
    );
  }

  void _confirmDeletePatient(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient?'),
        content: Text('Are you sure you want to delete ${patient.name}? This will also delete all their prescription history.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (patient.id != null) {
                // First delete all prescriptions for this patient
                final repository = ref.read(prescriptionRepositoryProvider);
                final prescriptions = await repository.getPrescriptionsByPatient(patient.id!);
                for (var p in prescriptions) {
                  if (p.id != null) {
                    await ref.read(prescriptionRepositoryProvider).delete(p.id!);
                  }
                }
                
                // Then delete the patient
                await ref.read(patientRepositoryProvider).delete(patient.id!);
                
                // Invalidate providers
                ref.invalidate(patientListProvider);
                ref.invalidate(prescriptionListProvider);
                
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to patient list
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Patient deleted successfully')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
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
    final dateStr = DateFormat('dd MMM yyyy').format(prescription.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.description_outlined, color: AppColors.primaryColor),
        ),
        title: Text(
          'Prescription - $dateStr',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              prescription.diagnosis?.isNotEmpty == true
                  ? 'Diagnosis: ${prescription.diagnosis}'
                  : 'No diagnosis recorded',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '${prescription.medicines.length} Medicines',
              style: TextStyle(color: AppColors.primaryColor, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
              onPressed: () => _confirmDeletePrescription(context, ref),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrescriptionDetailsScreen(
                prescription: prescription,
                patient: patient,
              ),
            ),
          );
        },
      ),
    );
  }

  void _confirmDeletePrescription(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prescription?'),
        content: const Text('Are you sure you want to delete this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (prescription.id != null) {
                await ref.read(prescriptionRepositoryProvider).delete(prescription.id!);
                ref.invalidate(prescriptionListProvider);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prescription deleted')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
