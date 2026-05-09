import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/app/app_text_style.dart';
import 'package:rxdigi/l10n/app_localizations.dart';
import 'package:rxdigi/l10n/app_localizations_bn.dart';

import '../../common_widgets/primary_button.dart';
import '../widgets/card_section_title.dart';
import '../widgets/card_title_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/dotted_circular_border.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/profile_image_section.dart';
import '../widgets/selectable_title_chip.dart';

class Step1Introduction extends StatefulWidget {
  final VoidCallback onNext;
  const Step1Introduction({super.key, required this.onNext});

  @override
  State<Step1Introduction> createState() => _Step1IntroductionState();
}

class _Step1IntroductionState extends State<Step1Introduction> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return SizedBox.expand(
      child: Container(
        color: AppColors.appBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.yourInformation,
                    style: AppTextStyles.largeBlackTextStyle(context)
                        .copyWith(color: AppColors.primaryColor),
                  ),
                  Text(
                    l10n.infoPrintedOnPrescription,
                    style: AppTextStyles.smallGreyTextStyle(context),
                  ),
                  const SizedBox(height: 16),
                  PersonalInfoSection(isDesktop: isDesktop, l10n: l10n),
                  const SizedBox(height: 16),
                  ContactSection(isDesktop: isDesktop, l10n: l10n),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onNext, // Allow skip or just move on
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
                                'Skip',
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Step 1 Saved')),
                              );
                              widget.onNext();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text(
                                'Next',
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
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}











