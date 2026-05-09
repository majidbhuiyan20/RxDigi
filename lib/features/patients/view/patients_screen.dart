import 'package:flutter/material.dart';
import 'package:rxdigi/app/app_colors.dart';

class PatientsScreen extends StatelessWidget {
  const PatientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackgroundColor,
      appBar: AppBar(
        title: const Text('Patients'),
        backgroundColor: AppColors.topHeaderColor,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Patient List Coming Soon...'),
      ),
    );
  }
}
