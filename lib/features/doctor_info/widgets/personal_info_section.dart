import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prescripto/features/doctor_info/view_model/doctor_onboarding_notifier.dart';
import 'package:prescripto/features/doctor_info/widgets/selectable_title_chip.dart';

import '../../../app/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import 'card_section_title.dart';
import 'card_title_section.dart';
import 'cutom_textfield_widgets.dart';

class PersonalInfoSection extends ConsumerStatefulWidget {
  const PersonalInfoSection({
    super.key,
    required this.isDesktop,
    required this.l10n,
  });

  final bool isDesktop;
  final AppLocalizations l10n;

  @override
  ConsumerState<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends ConsumerState<PersonalInfoSection> {
  late TextEditingController _nameController;
  late TextEditingController _regController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(doctorOnboardingProvider);
    _nameController = TextEditingController(text: state.fullName);
    _regController = TextEditingController(text: state.bmdcRegNo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _regController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(doctorOnboardingProvider);
    final notifier = ref.read(doctorOnboardingProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderColor,
          width: widget.isDesktop ? 3 : 1.5,
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardTitleSection(icon: Icons.person, title: widget.l10n.personalInfo,),
          const SizedBox(height: 8,),
          CardSectionTitle(title: widget.l10n.fullName,),
          const SizedBox(height: 8,),
          CustomTextFieldWidgets(
            controller: _nameController,
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
          const SizedBox(height: 8,),
          CardSectionTitle(title: widget.l10n.title,),
          const SizedBox(height: 8,),
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
          const SizedBox(height: 8,),
          CardSectionTitle(title: widget.l10n.gender,),
          const SizedBox(height: 8,),
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
                        title: widget.l10n.male,
                        isSelected: onboardingState.gender == widget.l10n.male,
                        onTap: () {
                          notifier.updateField(gender: widget.l10n.male);
                          state.didChange(widget.l10n.male);
                        },
                      ),
                      SelectableTitleChip(
                        title: widget.l10n.female,
                        isSelected: onboardingState.gender == widget.l10n.female,
                        onTap: () {
                          notifier.updateField(gender: widget.l10n.female);
                          state.didChange(widget.l10n.female);
                        },
                      ),
                      SelectableTitleChip(
                        title: widget.l10n.others,
                        isSelected: onboardingState.gender == widget.l10n.others,
                        onTap: () {
                          notifier.updateField(gender: widget.l10n.others);
                          state.didChange(widget.l10n.others);
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
          const SizedBox(height: 8,),
          const CardSectionTitle(title: 'BMDC Reg No.',),
          CustomTextFieldWidgets(
            controller: _regController,
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
          const SizedBox(height: 16,),
          const CardSectionTitle(title: 'Digital Signature (Optional)',),
          const SizedBox(height: 8,),
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                notifier.updateField(signaturePath: image.path);
              }
            },
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderColor, style: BorderStyle.solid),
              ),
              child: onboardingState.signaturePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(onboardingState.signaturePath!), fit: BoxFit.contain),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.drive_file_rename_outline, color: AppColors.textGreyColor.withOpacity(0.5), size: 32),
                        const SizedBox(height: 8),
                        Text('Tap to upload signature', style: TextStyle(color: AppColors.textGreyColor, fontSize: 13)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8,),
        ],
      ),
    );
  }
}
