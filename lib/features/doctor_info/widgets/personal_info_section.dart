import 'package:flutter/material.dart';
import 'package:rxdigi/features/doctor_info/widgets/selectable_title_chip.dart';

import '../../../app/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'card_section_title.dart';
import 'card_title_section.dart';
import 'cutom_textfield_widgets.dart';

class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({
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
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitleSection(icon: Icons.person, title: l10n.personalInfo,),
          SizedBox(height: 8,),
          CardSectionTitle(title: l10n.fullName,),
          SizedBox(height: 8,),
          CustomTextFieldWidgets(
            hintText: "Enter Your Full Name",
            prefixIcon: Icons.person,
          ),
          SizedBox(height: 8,),
          CardSectionTitle(title: l10n.title,),
          SizedBox(height: 8,),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectableTitleChip(title: "Dr.", singleProvider: selectedTitleProvider),
              SelectableTitleChip(title: "Prof. Dr.",  singleProvider: selectedTitleProvider),
              SelectableTitleChip(title: "Assoc. Prof. Dr.", singleProvider: selectedTitleProvider),
              SelectableTitleChip(title: "Asst. Prof. Dr.",  singleProvider: selectedTitleProvider),
            ],
          ),


          SizedBox(height: 8,),
          CardSectionTitle(title: l10n.gender,),
          SizedBox(height: 8,),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SelectableTitleChip(title: l10n.male, singleProvider: selectedGenderProvider),
              SelectableTitleChip(title: l10n.female, singleProvider: selectedGenderProvider),
              SelectableTitleChip(title: l10n.others, singleProvider: selectedGenderProvider),
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
    );
  }
}
