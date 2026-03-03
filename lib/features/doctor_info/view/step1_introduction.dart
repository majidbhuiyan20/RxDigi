import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_text_style.dart';
import 'package:rxdigi/l10n/app_localizations.dart';
import 'package:rxdigi/l10n/app_localizations_bn.dart';

import '../widgets/card_title_section.dart';
import '../widgets/dotted_circular_border.dart';

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
          padding:  EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.yourInformation, style: AppTextStyles.largeBlackTextStyle,),
              Text(l10n.infoPrintedOnPrescription, style: AppTextStyles.smallGreyTextStyle,),
              SizedBox(height: 8,),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: AppColors.borderColor,
                    width: isDesktop ? 3 : 1.5,
                  ),
                  color: Colors.white
                ),
                child: Column(
                  children: [
                    CardTitleSection(l10n: l10n),
                    SizedBox(height: 16,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomPaint(
                          painter: DottedCirclePainter(),
                          child: const SizedBox(
                            width: 80,
                            height: 80,
                            child: Center(
                              child: CircleAvatar(
                                radius: 30,
                                backgroundColor: Color(0XFFD7EBFE),
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.addPhoto, style: AppTextStyles.primaryTextStyle.copyWith(color: AppColors.textBlackColor),),
                            SizedBox(height: 4,),
                            Text(l10n.uploadProfessionalPhoto, style: AppTextStyles.smallGreyTextStyle,),
                            SizedBox(height: 4,),
                            Text(l10n.shownInPrescription, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: "TiroBangla"),),
                            SizedBox(height: 8,),
                            GestureDetector(
                              onTap: (){

                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Color(0XFFEBF4FF)
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.camera_alt_outlined, size: 24, color: AppColors.textBlackColor,),
                                    SizedBox(width: 8,),
                                    Text("আপলোড করুন", style: AppTextStyles.primaryTextStyle,),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

