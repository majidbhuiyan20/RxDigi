import 'package:flutter/material.dart';
import 'package:rxdigi/features/doctor_info/widgets/cutom_textfield_widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/card_section_title.dart';
import '../widgets/card_title_section.dart';
import '../widgets/selectable_title_chip.dart';

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
                      Text(
                        l10n.patientMeet,
                        style: AppTextStyles.smallGreyTextStyle(context),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.borderColor,
                              width: isDesktop ? 3 : 1.5,
                            )),
                        child: Column(children: [
                          CardTitleSection(
                              icon: Icons.local_hospital,
                              title: l10n.mainChamber),
                          SizedBox(
                            height: 4,
                          ),
                          CardSectionTitle(title: l10n.clinicName),
                          SizedBox(height: 12),
                          CustomTextFieldWidgets(
                            hintText: "Ex: Dhaka Medical College",
                            prefixIcon: Icons.local_hospital,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              Text(l10n.titlePosition,
                                  style: TextStyle(
                                      color: AppColors.textBlackColor,
                                      fontFamily: "PlayfairDisplay",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(0XFFEEF2F8),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  l10n.optional,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "PlusJakartaSans",
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 12,),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              SelectableTitleChip(title: "Consultant", singleProvider: selectedPositionProvider),
                              SelectableTitleChip(title: "Senior Consultant",  singleProvider: selectedPositionProvider),
                              SelectableTitleChip(title: "Professor", singleProvider: selectedPositionProvider),
                              SelectableTitleChip(title: "Registrar",  singleProvider: selectedPositionProvider),
                              SelectableTitleChip(title: "Medical Officer",  singleProvider: selectedPositionProvider),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Row(
                            children: [
                              Text(l10n.department,
                                  style: TextStyle(
                                      color: AppColors.textBlackColor,
                                      fontFamily: "PlayfairDisplay",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16)),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color(0XFFEEF2F8),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  l10n.optional,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "PlusJakartaSans",
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            ],
                          ),
SizedBox(height: 12,),
                          CustomTextFieldWidgets(hintText: "Ex: General Medicine",),
                          SizedBox(height: 16,),
                          CardSectionTitle(title: l10n.phoneNumber),
                          SizedBox(height: 12),
                          CustomTextFieldWidgets(
                            hintText: "Enter Phone Number",
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CardSectionTitle(title: "Start Time"),
                                    SizedBox(height: 8),
                                    CustomTextFieldWidgets(hintText: "09:00 AM"),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CardSectionTitle(title: "End Time"),
                                    SizedBox(height: 8),
                                    CustomTextFieldWidgets(hintText: "05:00 PM"),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: widget.onBack,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.borderColor,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Back',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: widget.onNext,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Complete',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 60),
                        ]),
                      ),
                    ])))));
  }
}
