import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdigi/features/doctor_info/view_model/doctor_onboarding_notifier.dart';
import 'package:rxdigi/features/doctor_info/widgets/cutom_textfield_widgets.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/card_section_title.dart';
import '../widgets/card_title_section.dart';
import '../widgets/selectable_title_chip.dart';

class Step3Effort extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step3Effort({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<Step3Effort> createState() => _Step3EffortState();
}

class _Step3EffortState extends ConsumerState<Step3Effort> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final onboardingState = ref.watch(doctorOnboardingProvider);
    final notifier = ref.read(doctorOnboardingProvider.notifier);

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
                          l10n.chamberInfo,
                          style: AppTextStyles.largeBlackTextStyle(context)
                              .copyWith(color: AppColors.primaryColor),
                        ),
                        Text(
                          l10n.patientMeet,
                          style: AppTextStyles.smallGreyTextStyle(context),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
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
                            const SizedBox(
                              height: 4,
                            ),
                            CardSectionTitle(title: l10n.clinicName),
                            const SizedBox(height: 12),
                            CustomTextFieldWidgets(
                              hintText: "Ex: Dhaka Medical College",
                              prefixIcon: Icons.local_hospital,
                              onChanged: (value) =>
                                  notifier.updateField(clinicName: value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter clinic name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CardSectionTitle(title: l10n.address),
                            const SizedBox(height: 12),
                            CustomTextFieldWidgets(
                              hintText: "Enter chamber address",
                              prefixIcon: Icons.location_on,
                              onChanged: (value) =>
                                  notifier.updateField(address: value),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            CardSectionTitle(title: l10n.roomNumber),
                            const SizedBox(height: 12),
                            CustomTextFieldWidgets(
                              hintText: "Ex: 402",
                              prefixIcon: Icons.meeting_room,
                              onChanged: (value) =>
                                  notifier.updateField(roomNumber: value),
                            ),
                            const SizedBox(
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
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0XFFEEF2F8),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    l10n.optional,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "PlusJakartaSans",
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                "Consultant",
                                "Senior Consultant",
                                "Professor",
                                "Registrar",
                                "Medical Officer"
                              ].map((pos) {
                                return SelectableTitleChip(
                                  title: pos,
                                  isSelected: onboardingState.position == pos,
                                  onTap: () =>
                                      notifier.updateField(position: pos),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Text(l10n.department,
                                    style: TextStyle(
                                        color: AppColors.textBlackColor,
                                        fontFamily: "PlayfairDisplay",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0XFFEEF2F8),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    l10n.optional,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "PlusJakartaSans",
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            CustomTextFieldWidgets(
                              hintText: "Ex: General Medicine",
                              onChanged: (value) =>
                                  notifier.updateField(department: value),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            CardSectionTitle(title: l10n.phoneNumber),
                            const SizedBox(height: 12),
                            CustomTextFieldWidgets(
                              hintText: "Enter Phone Number",
                              prefixIcon: Icons.phone,
                              onChanged: (value) =>
                                  notifier.updateField(phoneNumber: value),
                            ),
                            const SizedBox(height: 16),
                            CardSectionTitle(title: l10n.serialBooking),
                            const SizedBox(height: 12),
                            CustomTextFieldWidgets(
                              hintText: l10n.serialNumber1,
                              prefixIcon: Icons.phone_android,
                              onChanged: (value) =>
                                  notifier.updateField(serialNumber1: value),
                            ),
                            const SizedBox(height: 12),
                            CustomTextFieldWidgets(
                              hintText: l10n.serialNumber2,
                              prefixIcon: Icons.phone_android,
                              onChanged: (value) =>
                                  notifier.updateField(serialNumber2: value),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CardSectionTitle(
                                          title: "Start Time"),
                                      const SizedBox(height: 8),
                                      CustomTextFieldWidgets(
                                        hintText: "09:00 AM",
                                        onChanged: (value) =>
                                            notifier.updateField(
                                                startTime: value),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const CardSectionTitle(title: "End Time"),
                                      const SizedBox(height: 8),
                                      CustomTextFieldWidgets(
                                        hintText: "05:00 PM",
                                        onChanged: (value) =>
                                            notifier.updateField(
                                                endTime: value),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const CardSectionTitle(title: "Off Day"),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                "Sat",
                                "Sun",
                                "Mon",
                                "Tue",
                                "Wed",
                                "Thu",
                                "Fri"
                              ].map((day) {
                                final isSelected =
                                    onboardingState.offDays.contains(day);
                                return SelectableTitleChip(
                                  title: day,
                                  isSelected: isSelected,
                                  onTap: () {
                                    final currentDays = List<String>.from(
                                        onboardingState.offDays);
                                    if (isSelected) {
                                      currentDays.remove(day);
                                    } else {
                                      currentDays.add(day);
                                    }
                                    notifier.updateField(offDays: currentDays);
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: widget.onBack,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (_formKey.currentState!.validate()) {
                                        await notifier.saveDoctor(ref);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Registration Successful')),
                                        );
                                        widget.onNext();
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
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
                            const SizedBox(height: 60),
                          ]),
                        ),
                      ]),
                )))));
  }
}
