import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/features/doctor_info/widgets/card_title_section.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/profile_image_section.dart';

class Step2Qualification extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2Qualification({
    super.key,
    required this.onNext,
    required this.onBack,
  });

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
                Text(l10n.educationAndSpecialization, style: AppTextStyles.largeBlackTextStyle(context),),
                Text(l10n.provideYourDegreeInfo, style: AppTextStyles.smallGreyTextStyle(context),),
                SizedBox(height: 16,),
                 Container(
                   padding: EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     color: Colors.white,
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(
                       color: AppColors.borderColor,
                       width: isDesktop ? 3 : 1.5,
                     )
                   ),
                   child: Column(
                     children: [
                       CardTitleSection(icon: Icons.school_rounded, title: l10n.degrees),
                       SizedBox(height: 12,),

                     ],
                   ),
                 ),
                 SizedBox(height: 60,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}