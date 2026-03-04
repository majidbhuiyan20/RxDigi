import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_text_style.dart';
import 'package:rxdigi/l10n/app_localizations.dart';
import 'package:rxdigi/l10n/app_localizations_bn.dart';

import '../widgets/card_section_title.dart';
import '../widgets/card_title_section.dart';
import '../widgets/dotted_circular_border.dart';
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
                Container(
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
                ),
                SizedBox(height: 16,),
                ///----------- End Profile Image upload information section---------
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: isDesktop ? 3 : 1.5,
                      ),
                      color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CardTitleSection(icon: Icons.person, title: l10n.personalInfo,),
                      SizedBox(height: 8,),
                      CardSectionTitle(title: l10n.fullName,),
                      SizedBox(height: 8,),
                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person, // your icon here
                            color: AppColors.textGreyColor,
                          ),
                          hintText: "Enter your name",
                          hintStyle: TextStyle(
                            color: AppColors.textGreyColor.withOpacity(0.7),
                            fontSize: 16,
                          ),
            
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),
                      CardSectionTitle(title: l10n.title,),
                      SizedBox(height: 8,),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SelectableTitleChip(title: "Dr.", provider: selectedTitleProvider),
                          SelectableTitleChip(title: "Prof. Dr.", provider: selectedTitleProvider),
                          SelectableTitleChip(title: "Assoc. Prof. Dr.", provider: selectedTitleProvider),
                          SelectableTitleChip(title: "Asst. Prof. Dr.", provider: selectedTitleProvider),
                        ],
                      ),
            
            
                      SizedBox(height: 8,),
                      CardSectionTitle(title: l10n.gender,),
                      SizedBox(height: 8,),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          SelectableTitleChip(title: l10n.male, provider: selectedGenderProvider),
                          SelectableTitleChip(title: l10n.female, provider: selectedGenderProvider),
                          SelectableTitleChip(title: l10n.others, provider: selectedGenderProvider),
                        ],
                      ),


                      SizedBox(height: 8,),
                      CardSectionTitle(title: 'BMDC Reg No.',),

                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.confirmation_num, // your icon here
                            color: AppColors.textGreyColor,
                          ),
                          hintText: "Ex: A-4434",
                          hintStyle: TextStyle(
                            color: AppColors.textGreyColor.withOpacity(0.7),
                            fontSize: 16,
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                      ),
                      SizedBox(height: 8,),
                      CardSectionTitle(title: l10n.nationalId,),

                      TextFormField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.format_list_numbered_rtl, // your icon here
                            color: AppColors.textGreyColor,
                          ),
                          hintText: "ID: 120434343",
                          hintStyle: TextStyle(
                            color: AppColors.textGreyColor.withOpacity(0.7),
                            fontSize: 16,
                          ),

                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.borderColor),
                          ),
                        ),
                      ),
            
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}



