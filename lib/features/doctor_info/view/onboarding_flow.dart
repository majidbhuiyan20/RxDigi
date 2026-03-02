import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import 'package:rxdigi/features/doctor_info/view/step1_introduction.dart';
import 'package:rxdigi/features/doctor_info/view/step2_qualification.dart';
import 'package:rxdigi/features/doctor_info/view/step3_effort.dart';
import 'package:rxdigi/features/doctor_info/view/step4_profile.dart';
import '../view_model/onboarding_step_notifier.dart';
import '../widgets/step_header.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _pageController = PageController();
  final int _totalSteps = 4;

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
     // backgroundColor: const Color(0xFF1A3A8F),
      backgroundColor: AppColors.rxPrimaryColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // ✅ desktop: max width 560, mobile: full width
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 560 : double.infinity,
            ),
            child: Column(
              children: [

                // ── Step Header — centered top ─────────────────────
                StepHeader(
                  currentStep: currentStep,
                  totalSteps:  _totalSteps,
                ),

                // ── Pages ──────────────────────────────────────────
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics:    const NeverScrollableScrollPhysics(),
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
                        onNext: () => ref
                            .read(onboardingStepProvider.notifier)
                            .next(_totalSteps),
                        onBack: () => ref
                            .read(onboardingStepProvider.notifier)
                            .previous(),
                      ),
                      Step4Profile(
                        onNext: () => ref
                            .read(onboardingStepProvider.notifier)
                            .next(_totalSteps),
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
        ),
      ),
    );
  }
}