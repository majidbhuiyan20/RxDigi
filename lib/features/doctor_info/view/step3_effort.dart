import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/card_section_title.dart';
import '../widgets/card_title_section.dart';

class Step3Effort extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3Effort({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return SizedBox.expand(
        child: Container(
            color: AppColors.appBackgroundColor,
            child: Padding(
                padding: EdgeInsets.all(16),
                child: SingleChildScrollView(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(
                        l10n.chamberInfo,
                        style: AppTextStyles.largeBlackTextStyle(context)
                            .copyWith(color: AppColors.primaryColor),
                      ),
                          Text(l10n.patientMeet, style: AppTextStyles.smallGreyTextStyle(context),),
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
                          SizedBox(height: 4,),
                            CardSectionTitle(title: l10n.selectPrimaryDegree),
                       SizedBox(height: 12),])
                      ),


                        ])))));
  }
}
