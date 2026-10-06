import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../../core/data/providers/doctor_provider.dart';
import '../../../core/data/providers/prescription_provider.dart';
import '../../patients/view/patients_screen.dart';
import '../../prescription/view/new_prescription_screen.dart';
import '../widgets/doctor_header_card.dart';
import '../widgets/practice_metrics_row.dart';
import '../widgets/clinical_tools_grid.dart';
import '../widgets/prescription_item_card.dart';
import '../widgets/rx_empty_state.dart';

class RxStudioScreen extends ConsumerWidget {
  const RxStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final doctorAsync = ref.watch(latestDoctorProvider);
    final prescriptionsAsync = ref.watch(prescriptionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: Text(
          isBn ? 'প্রেসক্রিপশন হাব (Rx Studio)' : 'Rx Studio • Prescriptions',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: isBn ? 'সেটিংস' : 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsScreenRoute),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final doctor = doctorAsync.value;
          if (doctor == null) {
            Navigator.pushNamed(context, AppRoutes.introOnboarding);
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
            );
          }
        },
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.note_add_rounded, color: Colors.white),
        label: Text(
          isBn ? 'নতুন প্রেসক্রিপশন' : 'New Prescription',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: doctorAsync.when(
        data: (doctor) {
          final prescriptions = prescriptionsAsync.value ?? [];
          final now = DateTime.now();
          final todayPrescriptions = prescriptions.where((p) {
            return p.date.year == now.year &&
                p.date.month == now.month &&
                p.date.day == now.day;
          }).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Prescriber Header Card
              DoctorHeaderCard(doctor: doctor, isBn: isBn),
              const SizedBox(height: 16),

              // 2. Practice Metrics Row
              PracticeMetricsRow(
                todayCount: todayPrescriptions.length,
                totalPatients: prescriptions.map((p) => p.patientId).toSet().length,
                totalCount: prescriptions.length,
                isBn: isBn,
              ),
              const SizedBox(height: 20),

              // 3. Clinical & Practice Tools Grid
              ClinicalToolsGrid(doctor: doctor, isBn: isBn),
              const SizedBox(height: 24),

              // 4. Recent Prescriptions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'সাম্প্রতিক প্রেসক্রিপশন' : 'Recent Prescriptions',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (prescriptions.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PatientsScreen()),
                      ),
                      child: Text(
                        isBn ? 'সব দেখুন' : 'View All',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // 5. Prescriptions List or Empty State
              if (prescriptions.isEmpty)
                RxEmptyState(isBn: isBn)
              else
                ...prescriptions.take(8).map(
                      (p) => PrescriptionItemCard(
                        prescription: p,
                        doctor: doctor,
                        isBn: isBn,
                      ),
                    ),

              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
