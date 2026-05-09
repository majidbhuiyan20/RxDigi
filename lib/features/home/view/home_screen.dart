import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_routes.dart';
import 'package:rxdigi/app/app_text_style.dart';
import 'package:rxdigi/core/data/providers/doctor_provider.dart';
import 'package:rxdigi/core/data/providers/prescription_provider.dart';

import 'package:rxdigi/core/data/models/prescription_model.dart';
import 'package:rxdigi/core/data/providers/patient_provider.dart';
import 'package:rxdigi/features/medicines/view/medicines_screen.dart';
import 'package:rxdigi/features/patients/view/patient_details_screen.dart';
import 'package:rxdigi/features/patients/view/patients_screen.dart';

import '../../../core/data/providers/prescription_provider.dart' as core_providers;
import '../../../core/utils/pdf_generator.dart';
import '../../prescription/provider/prescription_provider.dart';
import '../../prescription/view/new_prescription_screen.dart';
import '../../reports/view/reports_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestDoctorAsync = ref.watch(latestDoctorProvider);
    final prescriptionsAsync = ref.watch(prescriptionListProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      body: SafeArea(
        child: latestDoctorAsync.when(
          data: (doctor) {
            if (doctor == null) {
              return const Center(child: Text('No doctor profile found.'));
            }

            // আজকের তারিখ
            final String todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

            // আজকের সামারি ক্যালকুলেশন
            int todayCount = 0;
            if (prescriptionsAsync.hasValue) {
              final now = DateTime.now();
              todayCount = prescriptionsAsync.value!.where((p) {
                if (p.createdAt == null) return false;
                return p.createdAt!.year == now.year &&
                    p.createdAt!.month == now.month &&
                    p.createdAt!.day == now.day;
              }).length;
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- ১. ডক্টরের পরিচয় ও হেডার ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.topHeaderColor,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
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
                                    'Good Day,',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 16,
                                      fontFamily: 'PlusJakartaSans',
                                    ),
                                  ),
                                  Text(
                                    '${doctor.title ?? ''} ${doctor.fullName}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'PlayfairDisplay',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // সেটিংস আইকন
                            GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.settingsScreenRoute),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.settings, color: Colors.white, size: 24),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          doctor.degrees ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontFamily: 'PlusJakartaSans',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.local_hospital, color: Colors.white70, size: 14),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                doctor.clinicName ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // আজকের তারিখ
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            todayDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- ২. Quick Actions Grid ---
                        Text(
                          "Quick Actions",
                          style: AppTextStyles.largeBlackTextStyle(context).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            _buildQuickAction(
                              context,
                              title: "New Rx",
                              icon: Icons.add_rounded,
                              color: AppColors.actionBlue,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
                              ),
                            ),
                            _buildQuickAction(
                              context,
                              title: "Patients",
                              icon: Icons.people_rounded,
                              color: AppColors.actionOrange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const PatientsScreen()),
                                );
                              },
                            ),
                            _buildQuickAction(
                              context,
                              title: "Medicines",
                              icon: Icons.medication_rounded,
                              color: AppColors.actionTeal,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const MedicinesScreen()),
                              ),
                            ),
                            _buildQuickAction(
                              context,
                              title: "Reports",
                              icon: Icons.analytics_rounded,
                              color: AppColors.actionPurple,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ReportsScreen()),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- ৩. আজকের Summary ---
                        Text(
                          "Today's Overview",
                          style: AppTextStyles.largeBlackTextStyle(context).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildSummaryCard(
                              context,
                              title: "Prescriptions",
                              count: todayCount.toString(),
                              icon: Icons.assignment_rounded,
                              color: AppColors.infoColor,
                            ),
                            const SizedBox(width: 16),
                            _buildSummaryCard(
                              context,
                              title: "Patients",
                              count: todayCount.toString(),
                              icon: Icons.person_pin_rounded,
                              color: AppColors.successColor,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- ৪. Recent Prescriptions ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Recent Prescriptions",
                              style: AppTextStyles.largeBlackTextStyle(context).copyWith(fontSize: 18),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to a full list or patients screen
                              },
                              child: Text("View All", style: TextStyle(color: AppColors.primaryColor)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        prescriptionsAsync.when(
                          data: (prescriptions) {
                            if (prescriptions.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderColor),
                                ),
                                child: const Center(
                                  child: Text("No prescriptions yet"),
                                ),
                              );
                            }
                            
                            final recent = prescriptions.take(5).toList();
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recent.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final p = recent[index];
                                return _buildRecentPrescriptionCard(context, ref, p);
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text('Error: $err'),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context,
      {required String title, required String count, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textGreyColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'PlusJakartaSans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context,
      {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPrescriptionCard(BuildContext context, WidgetRef ref, PrescriptionModel prescription) {
    final patientAsync = ref.watch(getPatientProvider(prescription.patientId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.description_outlined, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                patientAsync.when(
                  data: (patient) => Text(
                    patient?.name ?? 'Unknown Patient',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  loading: () => const Text('Loading...'),
                  error: (_, __) => const Text('Error loading patient'),
                ),
                Text(
                  DateFormat('dd MMM, yyyy • hh:mm a').format(prescription.date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.grey.shade400),
            onSelected: (value) async {
              final patient = patientAsync.asData?.value;
              if (patient == null) return;

              if (value == 'edit') {
                ref.read(prescriptionProvider.notifier).setPrescription(prescription, patient);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
                );
              } else if (value == 'delete') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Prescription'),
                    content: const Text('Are you sure you want to delete this prescription?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(core_providers.deletePrescriptionProvider(prescription.id!).future);
                  ref.invalidate(core_providers.prescriptionListProvider);
                }
              } else if (value == 'print') {
                final doctor = await ref.read(latestDoctorProvider.future);
                if (doctor != null) {
                  await PdfGenerator.printPrescription(prescription, patient, doctor);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
              const PopupMenuItem(value: 'print', child: Row(children: [Icon(Icons.print, size: 20), SizedBox(width: 8), Text('Print')])),
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
      ),
    );
  }
}
