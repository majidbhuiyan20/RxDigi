import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_routes.dart';
import 'package:rxdigi/app/app_text_style.dart';
import 'package:rxdigi/core/data/providers/doctor_provider.dart';
import 'package:rxdigi/core/data/providers/medicine_provider.dart';

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
    await Future.delayed(const Duration(seconds: 2));

    // 3. Check if doctor profile exists
    final latestDoctor = await ref.read(latestDoctorProvider.future);

    if (mounted) {
      if (latestDoctor != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.homeScreenRoute);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color(0XFF195FC7)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// 🔹 RxDigi Styled Text
            RichText(
              text: TextSpan(

                children: [
                  TextSpan(
                    text: "Rx",
                    style: AppTextStyles.playfairFontLogo,
                  ),
                  TextSpan(
                    text: "Digi",
                    style: AppTextStyles.oswaldFontLogo,
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
