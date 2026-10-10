import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
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

  void _openNewPrescription(BuildContext context, dynamic doctor) {
    if (doctor == null) {
      Navigator.pushNamed(context, AppRoutes.introOnboarding);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBn = Localizations.localeOf(context).languageCode == 'bn';
    final doctorAsync = ref.watch(latestDoctorProvider);
    final prescriptionsAsync = ref.watch(prescriptionListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          isBn ? 'প্রেসক্রিপশন হাব' : 'Rx Studio',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _openNewPrescription(context, doctorAsync.value),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(PhosphorIconsBold.plus, size: 14, color: AppColors.primaryColor),
                    const SizedBox(width: 4),
                    Text(
                      isBn ? 'নতুন প্রেসক্রিপশন' : 'New Rx',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(PhosphorIconsRegular.gear, size: 21, color: Color(0xFF0F172A)),
            tooltip: isBn ? 'সেটিংস' : 'Settings',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsScreenRoute),
          ),
          const SizedBox(width: 6),
        ],
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
            physics: const BouncingScrollPhysics(),
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  if (prescriptions.isNotEmpty)
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PatientsScreen()),
                      ),
                      child: Text(
                        isBn ? 'সব দেখুন' : 'View All',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                          fontSize: 12.5,
                        ),
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
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
