import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/app/app_routes.dart';
import 'package:prescripto/app/app_text_style.dart';
import 'package:prescripto/core/data/providers/doctor_provider.dart';
import 'package:prescripto/core/data/providers/prescription_provider.dart';

import 'package:prescripto/core/data/models/prescription_model.dart';
import 'package:prescripto/core/data/providers/patient_provider.dart';
import 'package:prescripto/features/medicines/view/medicines_screen.dart';
import 'package:prescripto/features/patients/view/patients_screen.dart';
import 'package:prescripto/features/prescription/view/prescription_details_screen.dart';
import 'package:prescripto/features/health_tips/models/health_tip_model.dart';
import 'package:prescripto/features/health_tips/provider/health_tips_provider.dart';
import 'package:prescripto/features/health_tips/view/health_tips_screen.dart';
import 'package:prescripto/features/health_tips/view/health_tip_detail_screen.dart';
import 'package:prescripto/features/vitals/models/vital_log_model.dart';
import 'package:prescripto/features/vitals/provider/vitals_provider.dart';
import 'package:prescripto/features/vitals/view/vitals_screen.dart';
import 'package:prescripto/features/vitals/view/add_vital_sheet.dart';

import '../../../core/utils/pdf_generator.dart';
import '../../prescription/view/new_prescription_screen.dart';
import '../../reports/view/reports_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestDoctorAsync = ref.watch(latestDoctorProvider);
    final prescriptionsAsync = ref.watch(prescriptionListProvider);
    final latestBp = ref.watch(latestBpProvider);
    final latestSugar = ref.watch(latestSugarProvider);
    final latestWeight = ref.watch(latestWeightProvider);
    final tipsAsync = ref.watch(healthTipsListProvider);
    final isTipBn = ref.watch(tipLanguageIsBnProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      body: latestDoctorAsync.when(
        data: (doctor) {
          final String todayDate = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
          final String titleName = doctor != null
              ? '${doctor.title ?? 'Dr.'} ${doctor.fullName.split(' ').first}'
              : 'RxDigi Health Hub';

          int todayPrescriptionCount = 0;
          int todayUniquePatientsCount = 0;

          if (prescriptionsAsync.hasValue) {
            final now = DateTime.now();
            final todayPrescriptions = prescriptionsAsync.value!.where((p) {
              return p.date.year == now.year &&
                  p.date.month == now.month &&
                  p.date.day == now.day;
            }).toList();

            todayPrescriptionCount = todayPrescriptions.length;
            todayUniquePatientsCount = todayPrescriptions.map((p) => p.patientId).toSet().length;
          }

          return Column(
            children: [
              // --- 1. Top Header ---
              Container(
                height: 60 + MediaQuery.of(context).padding.top,
                width: double.infinity,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: MediaQuery.of(context).padding.top,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.topHeaderColor, AppColors.primaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            titleName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            todayDate,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsScreenRoute),
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Prescriber Profile Setup Prompt (If doctor is null)
                      if (doctor == null)
                        Container(
                          margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2F1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF80CBC4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.badge_outlined, color: Color(0xFF00695C), size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Doctor or Prescriber?',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF004D40))),
                                    Text('Tap to setup clinic pad & qualifications',
                                      style: TextStyle(fontSize: 11.5, color: Colors.teal.shade800)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, AppRoutes.introOnboarding),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF004D40),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Setup',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ),

                      // --- 2. Health Vitals Section ---
                      _buildVitalsSection(context, latestBp, latestSugar, latestWeight),

                      // --- 3. Featured Health Tip of the Day ---
                      _buildFeaturedTip(context, ref, tipsAsync, isTipBn),

                      // --- 4. Prescriptions Counter (If doctor or has prescriptions) ---
                      if (doctor != null || todayPrescriptionCount > 0)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                          child: Row(
                            children: [
                              _buildSummaryCard(
                                context,
                                title: "Prescriptions",
                                count: todayPrescriptionCount.toString(),
                                icon: Icons.assignment_outlined,
                                color: AppColors.actionBlue,
                              ),
                              const SizedBox(width: 14),
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

                      const SizedBox(height: 16),

                      // --- 5. Quick Actions Grid ---
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Quick Actions",
                              style: AppTextStyles.largeBlackTextStyle(context).copyWith(fontSize: 18, letterSpacing: -0.5),
                            ),
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.5,
                              children: [
                                _buildQuickAction(
                                  context,
                                  title: "New Rx",
                                  icon: Icons.add_circle_outline,
                                  color: AppColors.actionBlue,
                                  onTap: () {
                                    if (doctor == null) {
                                      Navigator.pushNamed(context, AppRoutes.introOnboarding);
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const NewPrescriptionScreen()),
                                      );
                                    }
                                  },
                                ),
                                _buildQuickAction(
                                  context,
                                  title: "Health Vitals",
                                  icon: Icons.monitor_heart_outlined,
                                  color: const Color(0xFFE53935),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const VitalsScreen()),
                                  ),
                                ),
                                _buildQuickAction(
                                  context,
                                  title: "Health Tips",
                                  icon: Icons.health_and_safety_outlined,
                                  color: const Color(0xFF00897B),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HealthTipsScreen()),
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

                            // --- 6. Recent Prescriptions ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Recent Activity",
                                  style: AppTextStyles.largeBlackTextStyle(context).copyWith(fontSize: 18, letterSpacing: -0.5),
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

                            prescriptionsAsync.when(
                              data: (prescriptions) {
                                if (prescriptions.isEmpty) {
                                  return _buildEmptyState();
                                }

                                final recent = prescriptions.take(8).toList();
                                return  ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: recent.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 10),
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            color: color.withOpacity(0.03),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                /* Container(
                    height: 40,
                    width: 40,
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
                          fontSize: 18,
                        ),
                      ),
                    ),
                ), */
                const SizedBox(width: 4),
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
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade300, size: 20),
                    onPressed: () => _confirmDeletePrescription(context, ref, prescription, patient.name),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
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

  Widget _buildVitalsSection(
    BuildContext context,
    VitalLogModel? bp,
    VitalLogModel? sugar,
    VitalLogModel? weight,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Health Vitals',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VitalsScreen()),
                  );
                },
                child: Text(
                  'View Log',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildVitalItem(
                context,
                title: 'Blood Pressure',
                value: bp != null ? '${bp.value1.toInt()}/${bp.value2?.toInt() ?? 0}' : '-- / --',
                unit: 'mmHg',
                badge: bp?.getBpStatus() ?? '+ Log BP',
                icon: Icons.favorite_rounded,
                color: const Color(0xFFE53935),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddVitalSheet(initialType: 'BP'),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildVitalItem(
                context,
                title: 'Blood Glucose',
                value: sugar != null ? sugar.value1.toStringAsFixed(1) : '--.-',
                unit: 'mmol/L',
                badge: sugar?.category ?? '+ Log Sugar',
                icon: Icons.water_drop_rounded,
                color: const Color(0xFF1E88E5),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddVitalSheet(initialType: 'SUGAR'),
                  );
                },
              ),
              const SizedBox(width: 8),
              _buildVitalItem(
                context,
                title: 'Weight & BMI',
                value: weight != null ? weight.value1.toStringAsFixed(1) : '--.-',
                unit: 'kg',
                badge: weight?.getBmi() != null ? 'BMI ${weight!.getBmi()!.toStringAsFixed(1)}' : '+ Log Weight',
                icon: Icons.monitor_weight_rounded,
                color: const Color(0xFF00897B),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AddVitalSheet(initialType: 'WEIGHT'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalItem(
    BuildContext context, {
    required String title,
    required String value,
    required String unit,
    required String badge,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 14),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: color),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Text(
                unit,
                style: TextStyle(fontSize: 9.5, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedTip(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<HealthTipModel>> tipsAsync,
    bool isBn,
  ) {
    return tipsAsync.when(
      data: (tips) {
        if (tips.isEmpty) return const SizedBox.shrink();
        final featured = tips.first;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HealthTipDetailScreen(tip: featured),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E7D32),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: Colors.white, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  isBn ? 'দৈনিক স্বাস্থ্য টিপস' : 'Daily Health Tip',
                                  style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            featured.getCategory(isBn),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1B5E20)),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(tipLanguageIsBnProvider.notifier).state = !isBn;
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isBn ? 'EN' : 'বাং',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    featured.getTitle(isBn),
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    featured.getSummary(isBn),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade900,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
