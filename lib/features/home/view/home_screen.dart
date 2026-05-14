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
import 'package:rxdigi/features/patients/view/patients_screen.dart';
import 'package:rxdigi/features/prescription/view/prescription_details_screen.dart';

import '../../../core/utils/pdf_generator.dart';
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
      body: latestDoctorAsync.when(
        data: (doctor) {
          if (doctor == null) {
            return const Center(child: Text('No doctor profile found.'));
          }

          final String todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

          int todayPrescriptionCount = 0;
          int todayUniquePatientsCount = 0;

          if (prescriptionsAsync.hasValue) {
            final now = DateTime.now();
            final todayPrescriptions = prescriptionsAsync.value!.where((p) {
              // Using prescription.date instead of createdAt for business logic
              return p.date.year == now.year &&
                  p.date.month == now.month &&
                  p.date.day == now.day;
            }).toList();

            todayPrescriptionCount = todayPrescriptions.length;
            todayUniquePatientsCount = todayPrescriptions.map((p) => p.patientId).toSet().length;
          }

          return Column(
            children: [
              // --- 1. Enhanced Header (Fixed) ---
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.of(context).padding.top + 16,
                  24,
                  40,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.topHeaderColor, AppColors.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
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
                                todayDate.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PlusJakartaSans',
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Welcome, ${doctor.title ?? ''} ${doctor.fullName.split(' ').first}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PlayfairDisplay',
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.settingsScreenRoute),
                          child: Hero(
                            tag: 'settings_icon',
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: const Icon(Icons.settings_outlined, color: Colors.white, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white70, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            doctor.clinicName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontFamily: 'PlusJakartaSans',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Transform.translate(
                          offset: const Offset(0, -20),
                          child: Row(
                            children: [
                              _buildSummaryCard(
                                context,
                                title: "Prescriptions",
                                count: todayPrescriptionCount.toString(),
                                icon: Icons.assignment_outlined,
                                color: AppColors.actionBlue,
                              ),
                              const SizedBox(width: 16),
                              _buildSummaryCard(
                                context,
                                title: "Today's Patients",
                                count: todayUniquePatientsCount.toString(),
                                icon: Icons.groups_outlined,
                                color: AppColors.successColor,
                              ),
                            ],
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- 2. Quick Actions ---
                            const SizedBox(height: 12),
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
                              childAspectRatio: 2.2,
                              children: [
                                _buildQuickAction(
                                  context,
                                  title: "New Rx",
                                  icon: Icons.add_circle_outline,
                                  color: AppColors.actionBlue,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
                                  ),
                                ),
                                _buildQuickAction(
                                  context,
                                  title: "Patients",
                                  icon: Icons.person_search_outlined,
                                  color: AppColors.actionOrange,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const PatientsScreen()),
                                  ),
                                ),
                                _buildQuickAction(
                                  context,
                                  title: "Medicines",
                                  icon: Icons.inventory_2_outlined,
                                  color: AppColors.actionTeal,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const MedicinesScreen()),
                                  ),
                                ),
                                _buildQuickAction(
                                  context,
                                  title: "Reports",
                                  icon: Icons.bar_chart_outlined,
                                  color: AppColors.actionPurple,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ReportsScreen()),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // --- 3. Recent Prescriptions ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Recent Activity",
                                  style: AppTextStyles.largeBlackTextStyle(context).copyWith(fontSize: 18),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const PatientsScreen()),
                                    );
                                  },
                                  child: Text("View All", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            prescriptionsAsync.when(
                              data: (prescriptions) {
                                if (prescriptions.isEmpty) {
                                  return _buildEmptyState();
                                }

                                final recent = prescriptions.take(10).toList();
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
                              loading: () => const Center(child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: CircularProgressIndicator(),
                              )),
                              error: (err, stack) => Text('Error: $err'),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 64, color: AppColors.textGreyColor.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            "No prescriptions yet",
            style: TextStyle(color: AppColors.textGreyColor, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start by creating your first prescription",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGreyColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context,
      {required String title, required String count, required IconData icon, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              count,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentPrescriptionCard(BuildContext context, WidgetRef ref, PrescriptionModel prescription) {
    final patientAsync = ref.watch(getPatientProvider(prescription.patientId));

    return patientAsync.when(
      data: (patient) {
        if (patient == null) return const SizedBox.shrink();
        
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
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
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        patient.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
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
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM, yyyy • hh:mm a').format(prescription.date),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.print_outlined, color: AppColors.primaryColor, size: 20),
                    onPressed: () async {
                      final doctor = ref.read(latestDoctorProvider).value;
                      if (doctor != null) {
                        await PdfGenerator.printPrescription(prescription, patient, doctor);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                    onPressed: () => _confirmDeletePrescription(context, ref, prescription, patient.name),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _confirmDeletePrescription(BuildContext context, WidgetRef ref, PrescriptionModel prescription, String patientName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prescription?'),
        content: Text('Are you sure you want to delete the prescription for $patientName?'),
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
