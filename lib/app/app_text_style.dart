import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';

class AppTextStyles {
  // Oswald Font Family
  static const String oswald = 'Oswald';
  static const String playfair = 'PlayfairDisplay';
  static const String tiroBangla = 'TiroBangla';

  // Oswald variants
  static  TextStyle oswaldFontLogo = TextStyle(
    fontFamily: oswald,
    fontWeight: FontWeight.w700,
    fontSize: 56.sp,
      color: Color(0XFF74C1B7)
  );
  static  TextStyle playfairFontLogo = TextStyle(
    fontFamily: playfair,
    fontWeight: FontWeight.w700,
    fontSize: 56.sp,
    color: Colors.white,


  );
  static  TextStyle largeBlackTextStyle = TextStyle(
    fontFamily: playfair,
    fontWeight: FontWeight.w900,
    fontSize: 28,
    color: AppColors.textBlackColor,
  );
  static  TextStyle smallGreyTextStyle = TextStyle(
    fontFamily: playfair,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: AppColors.textGreyColor,
  );
  static  TextStyle primaryTextStyle = TextStyle(
    fontFamily: playfair,
    fontWeight: FontWeight.w900,
    fontSize: 18,
    color: AppColors.primaryTextColor,
  );


}