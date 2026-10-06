import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/app/app_routes.dart';
import 'package:prescripto/app/app_text_style.dart';
import 'package:prescripto/core/data/providers/doctor_provider.dart';
import 'package:prescripto/core/data/providers/medicine_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Initialize Medicines (load from CSV if not already in DB)
    await ref.read(loadMedicinesFromCsvProvider.future);

    // 2. Short delay for branding
    await Future.delayed(const Duration(seconds: 3));

    // 3. Navigate directly to Main Dashboard
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.homeScreenRoute);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 🔹 App Icon
            Image.asset(
              'assets/icons/prescripto.png',
              width: 180.w,
              height: 180.w,
            ),
            SizedBox(height: 24.h),
            // /// 🔹 App Name
            // Text(
            //   "Prescripto",
            //   style: AppTextStyles.oswaldFontLogo.copyWith(
            //     color: AppColors.primaryColor,
            //     fontSize: 32.sp,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
