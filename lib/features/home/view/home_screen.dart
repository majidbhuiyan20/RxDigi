import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/core/data/providers/doctor_provider.dart';
import 'package:rxdigi/app/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final latestDoctorAsync = ref.watch(latestDoctorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: latestDoctorAsync.when(
        data: (doctor) {
          if (doctor == null) {
            return const Center(child: Text('No doctor profile found.'));
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${doctor.title ?? ''} ${doctor.fullName}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Specialization: ${doctor.specialization ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Chamber: ${doctor.clinicName}'),
                const SizedBox(height: 16),
                Text('Number: ${doctor.phoneNumber ?? 'N/A'}'),
                Text('Addresss: ${doctor.address ?? 'N/A'}'),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Create Prescription
                  },
                  child: const Text('Create New Prescription'),
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
}
