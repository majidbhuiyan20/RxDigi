import 'package:flutter/material.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _moveToNextScreen();
  }

  void _moveToNextScreen() async{
    await Future.delayed(const Duration(seconds: 2));
    Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.rxPrimaryColor,
              AppColors.rxSecondaryColor,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// 🔹 RxDigi Styled Text
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
                children: [
                  TextSpan(
                    text: "Rx",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: "Digi",
                    style: TextStyle(color: AppColors.rxSecondaryColor),
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
