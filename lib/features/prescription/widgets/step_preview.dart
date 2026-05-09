import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/prescription/provider/prescription_provider.dart';

class StepPreview extends ConsumerWidget {
  const StepPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prescriptionProvider);
    final patient = state.patient;
    final date = DateFormat('dd MMM yyyy').format(DateTime.now());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Doctor Info - Placeholder)
            Text('Dr. Mohammad Rahim', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.topHeaderColor)),
            const Text('MBBS, FCPS (Medicine)', style: TextStyle(fontSize: 12)),
            const Text('BMDC Reg: 12345', style: TextStyle(fontSize: 12)),
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
            
            if (state.vitalSigns != null && state.vitalSigns!.isNotEmpty) ...[
              Text('Vitals: ${state.vitalSigns!}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
            ],

            Text('Rx', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.rxPrimaryColor)),
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
    );
  }
}
