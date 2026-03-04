import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_text_style.dart';
import 'package:rxdigi/l10n/app_localizations.dart';
import 'package:rxdigi/l10n/app_localizations_bn.dart';

import '../widgets/card_section_title.dart';
import '../widgets/card_title_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/dotted_circular_border.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/profile_image_section.dart';
import '../widgets/selectable_title_chip.dart';

class Step1Introduction extends StatelessWidget {
  final VoidCallback onNext;
  const Step1Introduction({super.key, required this.onNext});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop   = MediaQuery.of(context).size.width > 600;
    return SizedBox.expand(
      child: Container(
        color:  AppColors.appBackgroundColor,
        child: Padding(
          padding:  EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.yourInformation, style: AppTextStyles.largeBlackTextStyle(context),),
                Text(l10n.infoPrintedOnPrescription, style: AppTextStyles.smallGreyTextStyle(context),),
                SizedBox(height: 8,),
                ///-----------Profile Image upload information section-------------
                ProfileImageSection(isDesktop: isDesktop, l10n: l10n),
                SizedBox(height: 16,),
                ///----------- End Profile Image upload information section---------
                PersonalInfoSection(isDesktop: isDesktop, l10n: l10n),
                SizedBox(height: 16,),

                ContactSection(isDesktop: isDesktop, l10n: l10n)

              ],
            ),
          ),
        ),
      ),
    );
  }
}









