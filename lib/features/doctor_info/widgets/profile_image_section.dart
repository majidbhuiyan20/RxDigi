import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';
import 'card_title_section.dart';
import 'dotted_circular_border.dart';

class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({
    super.key,
    required this.isDesktop,
    required this.l10n,
  });

  final bool isDesktop;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.borderColor,
            width: isDesktop ? 3 : 1.5,
          ),
          color: Colors.white
      ),
      child: Column(
        children: [
          CardTitleSection(
            icon: Icons.camera_alt,
            title: l10n.profileImage,
          ),
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

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.addPhoto, style: AppTextStyles.primaryTextStyle(context).copyWith(color: AppColors.textBlackColor),),
                    SizedBox(height: 4,),
                    Text(l10n.uploadProfessionalPhoto, style: AppTextStyles.smallGreyTextStyle(context).copyWith(fontSize: 16),),
                    SizedBox(height: 4,),
                    Text(l10n.shownInPrescription, style: AppTextStyles.primaryTextStyle(context).copyWith(fontSize: 16),),
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
                            Text(l10n.uploadNow, style: AppTextStyles.primaryTextStyle(context),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}