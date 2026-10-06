import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../app/app_colors.dart';
import '../../../core/data/models/prescription_model.dart';
import '../../../core/data/providers/patient_provider.dart';
import '../../../core/data/providers/prescription_provider.dart';
import '../../../core/utils/pdf_generator.dart';
import '../../prescription/view/prescription_details_screen.dart';

class PrescriptionItemCard extends ConsumerWidget {
  final PrescriptionModel prescription;
  final dynamic doctor;
  final bool isBn;

  const PrescriptionItemCard({
    super.key,
    required this.prescription,
    required this.doctor,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(getPatientProvider(prescription.patientId));

    return patientAsync.when(
      data: (patient) {
        if (patient == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
            leading: CircleAvatar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.12),
              child: Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                style: const TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              patient.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              DateFormat('dd MMM, yyyy • hh:mm a').format(prescription.date),
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.print_outlined, color: AppColors.primaryColor, size: 20),
                  tooltip: isBn ? 'প্রিন্ট / PDF' : 'Print / PDF',
                  onPressed: () async {
                    if (doctor != null) {
                      await PdfGenerator.printPrescription(prescription, patient, doctor);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                  tooltip: isBn ? 'মুছুন' : 'Delete',
                  onPressed: () => _confirmDelete(context, ref, patient.name),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String patientName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isBn ? 'প্রেসক্রিপশন মুছে ফেলবেন?' : 'Delete Prescription?'),
        content: Text(
          isBn
              ? '$patientName এর প্রেসক্রিপশন স্থায়ীভাবে মুছে ফেলা হবে।'
              : 'Are you sure you want to delete the prescription for $patientName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isBn ? 'বাতিল' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(prescriptionRepositoryProvider);
              await repo.delete(prescription.id!);
              ref.invalidate(prescriptionListProvider);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isBn ? 'মুছুন' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
