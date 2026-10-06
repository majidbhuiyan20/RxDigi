import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prescripto/features/doctor_info/view_model/doctor_onboarding_notifier.dart';
import 'package:prescripto/features/doctor_info/widgets/card_section_title.dart';
import 'package:prescripto/features/doctor_info/widgets/card_title_section.dart';
import 'package:prescripto/features/doctor_info/widgets/cutom_textfield_widgets.dart';
import 'package:prescripto/features/doctor_info/widgets/selectable_title_chip.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_text_style.dart';
import '../../../l10n/app_localizations.dart';

class _DottedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  _DottedBorderPainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(30));

    _drawDottedBorder(canvas, paint, rRect);
  }

  void _drawDottedBorder(Canvas canvas, Paint paint, RRect rRect) {
    final pathMetrics = _createDottedPath(rRect).computeMetrics();

    for (var metric in pathMetrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  Path _createDottedPath(RRect rRect) {
    final path = Path();
    path.addRRect(rRect);
    return path;
  }

  @override
  bool shouldRepaint(_DottedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

class Step2Qualification extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2Qualification({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<Step2Qualification> createState() => _Step2QualificationState();
}

class _Step2QualificationState extends ConsumerState<Step2Qualification> {
  final _formKey = GlobalKey<FormState>();
  final List<String> customPrimaryDegrees = [];
  final List<String> customHigherDegrees = [];
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _subSpecialityController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _passingYearController = TextEditingController();
  late final AppLocalizations l10n;

  // Specialization dropdown
  final List<String> specializations = [
    'Cardiology',
    'Dermatology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Radiology',
    'Surgery',
    'General Practice',
    'Internal Medicine',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(doctorOnboardingProvider);
      _specializationController.text = state.specialization ?? '';
      _subSpecialityController.text = state.subSpecialization ?? '';
      _collegeController.text = state.collegeName ?? '';
      _passingYearController.text = state.passingYear ?? '';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context)!;
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _specializationController.dispose();
    _subSpecialityController.dispose();
    _collegeController.dispose();
    _passingYearController.dispose();
    super.dispose();
  }

  void _showAddCustomDegreeDialog({required bool isPrimary}) {
    _degreeController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPrimary ? "Add Custom Primary Degree" : "Add Custom Higher Degree"),
        content: TextField(
          controller: _degreeController,
          decoration: InputDecoration(
            hintText: "Enter degree name (e.g., MD, PhD)",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              if (_degreeController.text.isNotEmpty) {
                final degree = _degreeController.text;
                setState(() {
                  if (isPrimary) {
                    customPrimaryDegrees.add(degree);
                  } else {
                    customHigherDegrees.add(degree);
                  }
                });
                final currentDegrees = ref.read(doctorOnboardingProvider).degrees;
                ref.read(doctorOnboardingProvider.notifier).updateField(
                  degrees: [...currentDegrees, degree]
                );
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final onboardingState = ref.watch(doctorOnboardingProvider);
    final onboardingNotifier = ref.read(doctorOnboardingProvider.notifier);

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
                  Text(l10n.educationAndSpecialization, style: AppTextStyles.largeBlackTextStyle(context)),
                  Text(l10n.provideYourDegreeInfo, style: AppTextStyles.smallGreyTextStyle(context)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: isDesktop ? 3 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        CardTitleSection(icon: Icons.school_rounded, title: l10n.degrees),
                        const SizedBox(height: 4),
                        CardSectionTitle(title: l10n.selectPrimaryDegree),
                        const SizedBox(height: 12),
                        FormField<List<String>>(
                          initialValue: onboardingState.degrees,
                          validator: (value) {
                            if (onboardingState.degrees.isEmpty) {
                              return 'Please select at least one degree';
                            }
                            return null;
                          },
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    ...["MBBS", "BCS(Health)", "FCPS", "BDS", "BMMS", "BHMS", "MBChB"].map((degree) {
                                      return SelectableTitleChip(
                                        title: degree,
                                        isSelected: onboardingState.degrees.contains(degree),
                                        onTap: () {
                                          final current = onboardingState.degrees;
                                          if (current.contains(degree)) {
                                            onboardingNotifier.updateField(degrees: current.where((e) => e != degree).toList());
                                            state.didChange(current.where((e) => e != degree).toList());
                                          } else {
                                            onboardingNotifier.updateField(degrees: [...current, degree]);
                                            state.didChange([...current, degree]);
                                          }
                                        },
                                      );
                                    }),
                                    ...customPrimaryDegrees.map((degree) => SelectableTitleChip(
                                      title: degree,
                                      isSelected: onboardingState.degrees.contains(degree),
                                      onTap: () {
                                        final current = onboardingState.degrees;
                                        if (current.contains(degree)) {
                                          onboardingNotifier.updateField(degrees: current.where((e) => e != degree).toList());
                                          state.didChange(current.where((e) => e != degree).toList());
                                        } else {
                                          onboardingNotifier.updateField(degrees: [...current, degree]);
                                          state.didChange([...current, degree]);
                                        }
                                      },
                                    )),
                                    GestureDetector(
                                      onTap: () => _showAddCustomDegreeDialog(isPrimary: true),
                                      child: CustomPaint(
                                        painter: _DottedBorderPainter(
                                          color: Colors.black87,
                                          strokeWidth: 1.5,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(30),
                                            color: Colors.white,
                                          ),
                                          child: const Text(
                                            "+ Others",
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
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
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text("Higher Degree", style: TextStyle(color: AppColors.textBlackColor, fontFamily: "PlusJakartaSans", fontWeight: FontWeight.w700, fontSize: 16)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0XFFEEF2F8),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text("Select Multiple", style: TextStyle(fontWeight: FontWeight.w500, fontFamily: AppTextStyles.plusJakartaSans)),
                            )
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            ...["MD(Cardiology)", "CDC(Diabetes)", "MRCP", "FRCP", "PhD", "MPH", "DLO"].map((degree) {
                              return SelectableTitleChip(
                                title: degree,
                                isSelected: onboardingState.degrees.contains(degree),
                                onTap: () {
                                  final current = onboardingState.degrees;
                                  if (current.contains(degree)) {
                                    onboardingNotifier.updateField(degrees: current.where((e) => e != degree).toList());
                                  } else {
                                    onboardingNotifier.updateField(degrees: [...current, degree]);
                                  }
                                },
                              );
                            }),
                            ...customHigherDegrees.map((degree) => SelectableTitleChip(
                              title: degree,
                              isSelected: onboardingState.degrees.contains(degree),
                              onTap: () {
                                final current = onboardingState.degrees;
                                if (current.contains(degree)) {
                                  onboardingNotifier.updateField(degrees: current.where((e) => e != degree).toList());
                                } else {
                                  onboardingNotifier.updateField(degrees: [...current, degree]);
                                }
                              },
                            )),
                            GestureDetector(
                              onTap: () => _showAddCustomDegreeDialog(isPrimary: false),
                              child: CustomPaint(
                                painter: _DottedBorderPainter(
                                  color: Colors.black87,
                                  strokeWidth: 1.5,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.white,
                                  ),
                                  child: const Text(
                                    "+ Custom",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: isDesktop ? 3 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const CardTitleSection(icon: Icons.local_hospital, title: "Specialization"),
                        const SizedBox(height: 4),
                        const CardSectionTitle(title: "Specialization"),
                        const SizedBox(height: 12),
                        CustomTextFieldWidgets(
                          controller: _specializationController,
                          onChanged: (value) => onboardingNotifier.updateField(specialization: value),
                          hintText: "Ex: Cardiology",
                          prefixIcon: Icons.local_hospital,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter specialization';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text("Sub-Speciality", style: TextStyle(color: AppColors.textBlackColor, fontFamily: "PlusJakartaSans", fontWeight: FontWeight.w700, fontSize: 16)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0XFFEEF2F8),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Text("Optional", style: TextStyle(fontWeight: FontWeight.w500, fontFamily: "PlusJakartaSans", fontSize: 16)),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _subSpecialityController,
                          onChanged: (value) => onboardingNotifier.updateField(subSpecialization: value),
                          decoration: InputDecoration(
                            hintText: "EX: Interventional Cardiology",
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
                        const SizedBox(height: 16),
                        const CardSectionTitle(title: "Experience"),
                        const SizedBox(height: 16),
                        FormField<String>(
                          initialValue: onboardingState.experience,
                          validator: (value) {
                            if (onboardingState.experience == null) {
                              return 'Please select your experience';
                            }
                            return null;
                          },
                          builder: (state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    ...["1-3 Years", "3-5 Years", "5-10 Years", "10-20 Years", "20+ Years"].map((exp) {
                                      return SelectableTitleChip(
                                        title: exp,
                                        isSelected: onboardingState.experience == exp,
                                        onTap: () {
                                          onboardingNotifier.updateField(experience: exp);
                                          state.didChange(exp);
                                        },
                                      );
                                    }),
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
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.borderColor,
                        width: isDesktop ? 3 : 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const CardTitleSection(icon: Icons.speaker, title: "Educational Institution"),
                        const SizedBox(height: 4),
                        const CardSectionTitle(title: "Enter College Name(MBBS)"),
                        const SizedBox(height: 12),
                        CustomTextFieldWidgets(
                          controller: _collegeController,
                          onChanged: (value) => onboardingNotifier.updateField(collegeName: value),
                          hintText: "Ex: Dhaka Medical College",
                          prefixIcon: Icons.school,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter college name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const CardSectionTitle(title: "Passing Year"),
                        const SizedBox(height: 12),
                        CustomTextFieldWidgets(
                          controller: _passingYearController,
                          onChanged: (value) => onboardingNotifier.updateField(passingYear: value),
                          hintText: "Ex: 2015",
                          prefixIcon: Icons.calendar_today,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter passing year';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onBack,
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
                          onTap: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Step 2 Saved')),
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
