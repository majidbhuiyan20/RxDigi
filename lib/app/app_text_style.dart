import 'package:flutter/material.dart';
import 'package:prescripto/app/app_colors.dart';

class AppTextStyles {
  static const String oswald = 'Oswald';
  static const String playfair = 'PlayfairDisplay';
  static const String tiroBangla = 'TiroBangla';
  static const String plusJakartaSans = 'PlusJakartaSans';

  // 🔹 Detect Bangla
  static bool _isBangla(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'bn';
  }

  static String _getFont(BuildContext context) {
    return _isBangla(context) ? tiroBangla : playfair;
  }

  static String _getNormalFont(BuildContext context) {
    return _isBangla(context) ? tiroBangla : plusJakartaSans;
  }

  // 🔹 Logo Styles
  static TextStyle oswaldFontLogo = TextStyle(
    fontFamily: oswald,
    fontWeight: FontWeight.w700,
    fontSize: 56,
    color: const Color(0XFF74C1B7),
  );
  static TextStyle primaryBlackBoldText = TextStyle(
    fontFamily: oswald,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: const Color(0XFF384357),
  );

  static TextStyle playfairFontLogo = TextStyle(
    fontFamily: playfair,
    fontWeight: FontWeight.w700,
    fontSize: 56,
    color: Colors.white,
  );

  // 🔹 Large Black
  static TextStyle largeBlackTextStyle(BuildContext context) {
    return TextStyle(
      fontFamily: _getFont(context),
      fontWeight: FontWeight.w900,
      fontSize: 28,
      color: AppColors.textBlackColor,
    );
  }

  // 🔹 Small Grey
  static TextStyle smallGreyTextStyle(BuildContext context) {
    return TextStyle(
      fontFamily: _getFont(context),
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: AppColors.textGreyColor,
    );
  }

  // 🔹 Normal Font Styles (Sans-serif)
  static TextStyle normalLargeBlackTextStyle(BuildContext context) {
    return TextStyle(
      fontFamily: _getNormalFont(context),
      fontWeight: FontWeight.w700,
      fontSize: 28,
      color: AppColors.textBlackColor,
    );
  }

  static TextStyle normalSmallGreyTextStyle(BuildContext context) {
    return TextStyle(
      fontFamily: _getNormalFont(context),
      fontWeight: FontWeight.w500,
      fontSize: 16,
      color: AppColors.textGreyColor,
    );
  }

  // 🔹 Primary Text
  static TextStyle primaryTextStyle(BuildContext context) {
    return TextStyle(
      fontFamily: _getFont(context),
      fontWeight: FontWeight.w900,
      fontSize: 18,
      color: AppColors.primaryTextColor,
    );
  }
}