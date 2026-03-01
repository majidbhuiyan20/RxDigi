import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/features/doctor_info/view/step1_introduction.dart';
import 'package:rxdigi/features/doctor_info/view/step2_qualification.dart';
import 'package:rxdigi/features/doctor_info/view/step3_effort.dart';
import 'package:rxdigi/features/doctor_info/view/step4_profile.dart';
import '../view_model/onboarding_step_notifier.dart';

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

    ref.listen<int>(onboardingStepProvider, (previous, next) {
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 400),
        curve:    Curves.easeInOut,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A3A8F),
      body: SafeArea(
        child: Column(
          children: [

            // ── Step Header ──────────────────────────────────────────
            StepHeader(
              currentStep: currentStep,
              totalSteps:  _totalSteps,
            ),

            // ── Pages ────────────────────────────────────────────────
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
    );
  }
}

// ── Step Header ───────────────────────────────────────────────────────────────

class StepHeader extends ConsumerWidget {
  final int currentStep;
  final int totalSteps;

  const StepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  static const List<String> _labels = [
    'পরিচয়',
    'যোগ্যতা',
    'চেষ্টার',
    'প্রোফাইল',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color:   const Color(0xFF1A3A8F),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          // ── Row: circles + connecting lines ──────────────────────
          Row(

            children: List.generate(totalSteps, (i) {
              final isActive    = i == currentStep;
              final isCompleted = i < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // ── Circle ─────────────────────────────────────
                    GestureDetector(
                      onTap: () => ref
                          .read(onboardingStepProvider.notifier)
                          .goToStep(i),
                      child: _StepCircle(
                        index:       i,
                        isActive:    isActive,
                        isCompleted: isCompleted,
                      ),
                    ),

                    // ── Connecting line ────────────────────────────
                    if (i < totalSteps - 1)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          height: 2,
                          color: isCompleted
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 10.h),

          // ── Labels row ────────────────────────────────────────────
          Row(
            children: List.generate(totalSteps, (i) {
              final isActive    = i == currentStep;
              final isCompleted = i < currentStep;

              // each label aligns under its circle
              return Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 40.w, // same width as circle
                      child: Text(
                        _labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize:   10.sp,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive || isCompleted
                              ? Colors.white
                              : Colors.white.withOpacity(0.45),
                        ),
                      ),
                    ),
                    if (i < totalSteps - 1) const Expanded(child: SizedBox()),
                  ],
                ),
              );
            }),
          ),
          SizedBox(height: 14.h),

          // ── Progress bar (4 segments) ─────────────────────────────
          Row(
            children: List.generate(totalSteps, (i) {
              final isFilled = i <= currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height: 3.5,
                  margin: EdgeInsets.only(
                      right: i < totalSteps - 1 ? 3.w : 0),
                  decoration: BoxDecoration(
                    color: isFilled
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 8.h),

          // ── Step counter ──────────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'ধাপ ${currentStep + 1} / $totalSteps',
              style: TextStyle(
                fontSize: 11.sp,
                color:    Colors.white.withOpacity(0.65),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step Circle ───────────────────────────────────────────────────────────────

class _StepCircle extends StatelessWidget {
  final int  index;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.index,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width:  40.w,
      height: 40.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Colors.white
            : isCompleted
            ? Colors.white.withOpacity(0.85)
            : Colors.white.withOpacity(0.2),
        boxShadow: isActive
            ? [
          BoxShadow(
            color:        Colors.white.withOpacity(0.35),
            blurRadius:   14,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? Icon(
          Icons.check_rounded,
          size:  20.sp,
          color: const Color(0xFF1A3A8F),
        )
            : Text(
          '${index + 1}',
          style: TextStyle(
            fontSize:   16.sp,
            fontWeight: FontWeight.w700,
            color: isActive
                ? const Color(0xFF1A3A8F)
                : Colors.white.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}