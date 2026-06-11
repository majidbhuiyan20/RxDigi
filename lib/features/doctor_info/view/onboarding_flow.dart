import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/features/doctor_info/view/step1_introduction.dart';
import 'package:prescripto/features/doctor_info/view/step2_qualification.dart';
import 'package:prescripto/features/doctor_info/view/step3_effort.dart';
import '../../../app/app_routes.dart';
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
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    ref.listen<int>(onboardingStepProvider, (previous, next) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF0D3592),
      body: SafeArea(
        child: Column(
          children: [
            // Header is always full width or centered
            StepHeader(
              currentStep: currentStep,
              totalSteps: _totalSteps,
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 800 : double.infinity,
                    ),
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
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.homeScreenRoute,
                            );
                          },
                          onBack: () => ref
                              .read(onboardingStepProvider.notifier)
                              .previous(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
