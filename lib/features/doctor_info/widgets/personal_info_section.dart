import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/features/doctor_info/view_model/doctor_onboarding_notifier.dart';
import 'package:rxdigi/features/doctor_info/widgets/selectable_title_chip.dart';

import '../../../app/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'card_section_title.dart';
import 'card_title_section.dart';
import 'cutom_textfield_widgets.dart';

class PersonalInfoSection extends ConsumerWidget {
  const PersonalInfoSection({
    super.key,
    required this.isDesktop,
    required this.l10n,
  });

  final bool isDesktop;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingState = ref.watch(doctorOnboardingProvider);
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
          CardTitleSection(icon: Icons.person, title: l10n.personalInfo,),
          SizedBox(height: 8,),
          CardSectionTitle(title: l10n.fullName,),
          SizedBox(height: 8,),
          CustomTextFieldWidgets(
            hintText: "Enter Your Full Name",
            prefixIcon: Icons.person,
            onChanged: (value) => notifier.updateField(fullName: value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: 8,),
          CardSectionTitle(title: l10n.title,),
          SizedBox(height: 8,),
          FormField<String>(
            initialValue: onboardingState.title,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a title';
              }
              return null;
            },
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SelectableTitleChip(
                        title: "Dr.",
                        isSelected: onboardingState.title == "Dr.",
                        onTap: () {
                          notifier.updateField(title: "Dr.");
                          state.didChange("Dr.");
                        },
                      ),
                      SelectableTitleChip(
                        title: "Prof. Dr.",
                        isSelected: onboardingState.title == "Prof. Dr.",
                        onTap: () {
                          notifier.updateField(title: "Prof. Dr.");
                          state.didChange("Prof. Dr.");
                        },
                      ),
                      SelectableTitleChip(
                        title: "Assoc. Prof. Dr.",
                        isSelected: onboardingState.title == "Assoc. Prof. Dr.",
                        onTap: () {
                          notifier.updateField(title: "Assoc. Prof. Dr.");
                          state.didChange("Assoc. Prof. Dr.");
                        },
                      ),
                      SelectableTitleChip(
                        title: "Asst. Prof. Dr.",
                        isSelected: onboardingState.title == "Asst. Prof. Dr.",
                        onTap: () {
                          notifier.updateField(title: "Asst. Prof. Dr.");
                          state.didChange("Asst. Prof. Dr.");
                        },
                      ),
                    ],
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 8,),
          CardSectionTitle(title: l10n.gender,),
          SizedBox(height: 8,),
          FormField<String>(
            initialValue: onboardingState.gender,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your gender';
              }
              return null;
            },
            builder: (state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      SelectableTitleChip(
                        title: l10n.male,
                        isSelected: onboardingState.gender == l10n.male,
                        onTap: () {
                          notifier.updateField(gender: l10n.male);
                          state.didChange(l10n.male);
                        },
                      ),
                      SelectableTitleChip(
                        title: l10n.female,
                        isSelected: onboardingState.gender == l10n.female,
                        onTap: () {
                          notifier.updateField(gender: l10n.female);
                          state.didChange(l10n.female);
                        },
                      ),
                      SelectableTitleChip(
                        title: l10n.others,
                        isSelected: onboardingState.gender == l10n.others,
                        onTap: () {
                          notifier.updateField(gender: l10n.others);
                          state.didChange(l10n.others);
                        },
                      ),
                    ],
                  ),
                  if (state.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 12),
                      child: Text(
                        state.errorText!,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          SizedBox(height: 8,),
          CardSectionTitle(title: 'BMDC Reg No.',),
          CustomTextFieldWidgets(
            hintText: "Ex: A-4434",
            prefixIcon: Icons.confirmation_num,
            onChanged: (value) => notifier.updateField(bmdcRegNo: value),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter BMDC Reg No.';
              }
              return null;
            },
          ),
          SizedBox(height: 8,),



        ],
      ),
    );
  }
}
