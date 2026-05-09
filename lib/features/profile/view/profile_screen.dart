import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_routes.dart';
import 'package:rxdigi/core/data/providers/doctor_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorAsync = ref.watch(latestDoctorProvider);

    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settingsScreenRoute),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: doctorAsync.when(
        data: (doctor) {
          if (doctor == null) return const Center(child: Text('No Profile Found'));
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(doctor),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Professional Information'),
                      _buildInfoCard([
                        _buildProfileItem(Icons.school_outlined, 'Degrees', doctor.degrees ?? 'N/A'),
                        _buildProfileItem(Icons.psychology_outlined, 'Specialization', doctor.specialization ?? 'N/A'),
                        _buildProfileItem(Icons.badge_outlined, 'BMDC Reg No', doctor.bmdcRegNo ?? 'N/A'),
                        _buildProfileItem(Icons.work_outline, 'Position', doctor.position ?? 'N/A'),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Contact Information'),
                      _buildInfoCard([
                        _buildProfileItem(Icons.phone_outlined, 'Mobile', doctor.mobile),
                        _buildProfileItem(Icons.email_outlined, 'Email', doctor.email),
                        if (doctor.phoneNumber != null)
                          _buildProfileItem(Icons.call_outlined, 'Clinic Phone', doctor.phoneNumber!),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Clinic Details'),
                      _buildInfoCard([
                        _buildProfileItem(Icons.local_hospital_outlined, 'Clinic Name', doctor.clinicName),
                        _buildProfileItem(Icons.location_on_outlined, 'Address', doctor.address),
                        if (doctor.roomNumber != null)
                          _buildProfileItem(Icons.meeting_room_outlined, 'Room/Chamber', doctor.roomNumber!),
                        if (doctor.startTime != null && doctor.endTime != null)
                          _buildProfileItem(Icons.access_time, 'Visiting Hours', '${doctor.startTime} - ${doctor.endTime}'),
                      ]),
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
    );
  }

  Widget _buildHeader(dynamic doctor) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 40),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              child: Text(
                doctor.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${doctor.title ?? ''} ${doctor.fullName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            doctor.specialization ?? 'Specialist',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Edit Profile Logic
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.textBlackColor,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          final index = entry.key;
          final widget = entry.value;
          final isLast = index == children.length - 1;
          
          return Column(
            children: [
              widget,
              if (!isLast)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 60,
                  endIndent: 20,
                  color: AppColors.borderColor.withOpacity(0.5),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textGreyColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textBlackColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
