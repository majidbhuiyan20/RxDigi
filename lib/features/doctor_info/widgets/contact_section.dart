import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/features/doctor_info/view_model/doctor_onboarding_notifier.dart';

import '../../../app/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'card_section_title.dart';
import 'card_title_section.dart';
class ContactSection extends ConsumerWidget {
  const ContactSection({
    super.key,
    required this.isDesktop,
    required this.l10n,
  });

  final bool isDesktop;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(doctorOnboardingProvider.notifier);

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
            onChanged: (value) => notifier.updateField(mobile: value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your mobile number';
              }
              return null;
            },
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
            onChanged: (value) => notifier.updateField(email: value),
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                if (!emailRegExp.hasMatch(value)) {
                  return 'Please enter a valid email address';
                }
              }
              return null;
            },
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
