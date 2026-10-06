import 'package:flutter/material.dart';
import '../../../app/app_colors.dart';
import '../../../app/app_routes.dart';

class DoctorHeaderCard extends StatelessWidget {
  final dynamic doctor;
  final bool isBn;

  const DoctorHeaderCard({
    super.key,
    required this.doctor,
    required this.isBn,
  });

  @override
  Widget build(BuildContext context) {
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
}
