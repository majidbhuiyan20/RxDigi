import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'card_section_title.dart';
import 'card_title_section.dart';
class ContactSection extends StatelessWidget {
  const ContactSection({
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
          CardTitleSection(icon: Icons.phone, title: l10n.contact,),
          SizedBox(height: 8,),
          CardSectionTitle(title: l10n.mobile,),
          SizedBox(height: 8,),
          TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.phone,
                color: AppColors.textGreyColor,
              ),
              hintText: "Enter your number",
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


          SizedBox(height: 8,),
          CardSectionTitle(title:l10n.email,),

          TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.email_outlined, // your icon here
                color: AppColors.textGreyColor,
              ),
              hintText: "Enter your mail",
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


        ],
      ),
    );
  }
}