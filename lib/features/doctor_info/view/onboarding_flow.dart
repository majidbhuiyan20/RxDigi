import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/doctor_info/view/step1_introduction.dart';
import 'package:rxdigi/features/doctor_info/view/step2_qualification.dart';
import 'package:rxdigi/features/doctor_info/view/step3_effort.dart';
import 'package:rxdigi/features/prescription/view/prescription_preview.dart';
import '../view_model/onboarding_step_notifier.dart';
import '../widgets/step_header.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();
  final int _totalSteps = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(onboardingStepProvider);
    final isDesktop   = MediaQuery.of(context).size.width > 600;

    ref.listen<int>(onboardingStepProvider, (previous, next) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve:    Curves.easeInOut,
      );
    });

    return Scaffold(
     backgroundColor: const Color(0xFF0D3592),
      //backgroundColor: AppColors.rxPrimaryColor,
      body: SafeArea(
        child: Column(
          children: [
            StepHeader(
              currentStep: currentStep,
              totalSteps: _totalSteps,
            ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Step1Introduction(
                    onNext: () => ref
                        .read(onboardingStepProvider.notifier)
                        .next(_totalSteps),
                  ),
                  Step2Qualification(
                    onNext: () => ref
                        .read(onboardingStepProvider.notifier)
                        .next(_totalSteps),
                    onBack: () => ref
                        .read(onboardingStepProvider.notifier)
                        .previous(),
                  ),
                  Step3Effort(
                    onNext: () {
                      // Navigate to prescription preview instead of next step
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrescriptionPreview(),
                        ),
                      );
                    },
                    onBack: () => ref
                        .read(onboardingStepProvider.notifier)
                        .previous(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}