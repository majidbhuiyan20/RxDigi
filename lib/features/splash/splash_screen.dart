import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_routes.dart';
import 'package:rxdigi/app/app_text_style.dart';

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
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow);
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
