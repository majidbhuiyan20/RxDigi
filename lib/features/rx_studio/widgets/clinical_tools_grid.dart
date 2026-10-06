import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';
import '../../medicines/view/medicines_screen.dart';
import '../../patients/view/patients_screen.dart';
import '../../prescription/view/new_prescription_screen.dart';
import '../../reports/view/reports_screen.dart';

class ClinicalToolsGrid extends StatelessWidget {
  final dynamic doctor;
  final bool isBn;

  const ClinicalToolsGrid({
    super.key,
    required this.doctor,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
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
}
