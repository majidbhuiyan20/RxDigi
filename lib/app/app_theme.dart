import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      colorSchemeSeed: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.appBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryColor,
      ),
      inputDecorationTheme: _getInputDecorationTheme(),
      filledButtonTheme: _getFilledButtonThemeData()
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(brightness: Brightness.dark,
    inputDecorationTheme: _getInputDecorationTheme(),
      filledButtonTheme: _getFilledButtonThemeData(),

    );
  }


  //Input Decoration Theme
  static InputDecorationTheme _getInputDecorationTheme() {
    return InputDecorationTheme(
      isDense: true,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      hintStyle: TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
        color: AppColors.textGreyColor.withOpacity(0.7),
      ),

      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14,
        color: AppColors.textGreyColor,
      ),

      floatingLabelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: AppColors.primaryTextColor,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.borderColor,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppColors.primaryColor, // your main brand color
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

//Filled Button Theme Style
  static FilledButtonThemeData _getFilledButtonThemeData() {
       return FilledButtonThemeData(
         style: FilledButton.styleFrom(
             fixedSize: Size.fromWidth(double.maxFinite),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
             backgroundColor: AppColors.themeColor,
             textStyle: TextStyle(
                 fontWeight: FontWeight.w700
             )
         ),
       );
  }
}
