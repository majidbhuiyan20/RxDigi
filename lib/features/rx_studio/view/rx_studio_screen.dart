import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/app/app_routes.dart';
import 'package:prescripto/core/data/models/prescription_model.dart';
import 'package:prescripto/core/data/providers/doctor_provider.dart';
import 'package:prescripto/core/data/providers/patient_provider.dart';
import 'package:prescripto/core/data/providers/prescription_provider.dart';
import 'package:prescripto/core/utils/pdf_generator.dart';
import 'package:prescripto/features/medicines/view/medicines_screen.dart';
import 'package:prescripto/features/patients/view/patients_screen.dart';
import 'package:prescripto/features/prescription/view/new_prescription_screen.dart';
import 'package:prescripto/features/prescription/view/prescription_details_screen.dart';
import 'package:prescripto/features/reports/view/reports_screen.dart';

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
              // 👨‍⚕️ Prescriber Header Card
              _buildDoctorHeader(context, doctor, isBn),
              const SizedBox(height: 16),

              // 📈 Practice Metrics
              Row(
                children: [
                  _buildMetricTile(
                    label: isBn ? 'আজকের প্রেসক্রিপশন' : "Today's Rx",
                    value: todayPrescriptions.length.toString(),
                    icon: Icons.today_rounded,
                    color: AppColors.actionBlue,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricTile(
                    label: isBn ? 'সর্বমোট রোগী' : 'Total Patients',
                    value: prescriptions.map((p) => p.patientId).toSet().length.toString(),
                    icon: Icons.people_outline_rounded,
                    color: AppColors.successColor,
                  ),
                  const SizedBox(width: 12),
                  _buildMetricTile(
                    label: isBn ? 'মোট প্রেসক্রিপশন' : 'Total Rx',
                    value: prescriptions.length.toString(),
                    icon: Icons.description_outlined,
                    color: AppColors.actionPurple,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ⚡ Rx Management Hub Grid
              Text(
                isBn ? 'ক্লিনিকাল টুলস' : 'Clinical & Practice Tools',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _buildActionCard(
                    title: isBn ? 'নতুন প্রেসক্রিপশন' : 'Create Rx',
                    subtitle: isBn ? 'প্যাডে প্রেসক্রিপশন তৈরি' : 'Instant digital pad',
                    icon: Icons.add_chart_rounded,
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
                  _buildActionCard(
                    title: isBn ? 'রোগীর তালিকা' : 'Patient Records',
                    subtitle: isBn ? 'সকল রোগীর হিস্টোরি' : 'Search & histories',
                    icon: Icons.groups_rounded,
                    color: AppColors.actionOrange,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PatientsScreen()),
                    ),
                  ),
                  _buildActionCard(
                    title: isBn ? 'ঔষধ ডিরেক্টরি' : 'Drug Index',
                    subtitle: isBn ? 'ব্র্যান্ড ও জেনেরিক ডেটা' : 'Medicines & dosage',
                    icon: Icons.medication_rounded,
                    color: AppColors.actionTeal,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MedicinesScreen()),
                    ),
                  ),
                  _buildActionCard(
                    title: isBn ? 'প্র্যাকটিস রিপোর্ট' : 'Reports & Stats',
                    subtitle: isBn ? 'দৈনিক ও মাসিক হিসাব' : 'Analytics & charts',
                    icon: Icons.bar_chart_rounded,
                    color: AppColors.actionPurple,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ReportsScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 📋 Recent Prescriptions Header
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

              // Prescriptions List
              if (prescriptions.isEmpty)
                _buildEmptyState(context, isBn)
              else
                ...prescriptions.take(8).map((p) => _buildPrescriptionCard(context, ref, p, doctor, isBn)),

              const SizedBox(height: 80),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context, dynamic doctor, bool isBn) {
    if (doctor == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE0F2F1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF80CBC4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF004D40),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.badge_outlined, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBn ? 'ডক্টর প্রোফাইল সেটআপ করুন' : 'Setup Prescriber Profile',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF004D40)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isBn
                        ? 'প্রেসক্রিপশন প্যাড তৈরি করতে আপনার ডিগ্রি ও চেম্বারের তথ্য দিন'
                        : 'Add qualification, degree & clinic pad details',
                    style: TextStyle(fontSize: 12, color: Colors.teal.shade800),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.introOnboarding),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(
                isBn ? 'সেটআপ' : 'Setup',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    final String doctorName = '${doctor.title ?? "Dr."} ${doctor.fullName}';
    final String degree = doctor.degrees ?? 'MBBS, Clinical Practitioner';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  degree,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryColor, size: 20),
            tooltip: isBn ? 'প্রোফাইল পরিবর্তন' : 'Edit Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.introOnboarding),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
            color: color.withOpacity(0.03),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(
    BuildContext context,
    WidgetRef ref,
    PrescriptionModel prescription,
    dynamic doctor,
    bool isBn,
  ) {
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
                  onPressed: () => _confirmDelete(context, ref, prescription, patient.name, isBn),
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

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PrescriptionModel prescription,
    String patientName,
    bool isBn,
  ) {
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
              await ref.read(prescriptionListProvider.notifier).deletePrescription(prescription.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isBn ? 'মুছুন' : 'Delete', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isBn) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.description_outlined, size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            isBn ? 'কোনো প্রেসক্রিপশন পাওয়া যায়নি' : 'No prescriptions yet',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            isBn
                ? 'প্রথম প্রেসক্রিপশন তৈরি করতে নিচের "নতুন প্রেসক্রিপশন" বাটনে চাপুন।'
                : 'Start by creating your first clinical prescription.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
