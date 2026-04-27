import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rxdigi/app/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../view_model/onboarding_step_notifier.dart';

class StepHeader extends ConsumerWidget {
  final int currentStep;
  final int totalSteps;

  const StepHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop  = MediaQuery.of(context).size.width > 600;
    final l10n       = AppLocalizations.of(context)!;
    final circleSize = isDesktop ? 48.0 : 40.w;
    final lineHeight = 2.0;
    final barHeight  = isDesktop ? 4.0 : 3.0;

    // ✅ localized labels
    final labels = [
      l10n.stepIntroduction,
      l10n.stepQualification,
      l10n.stepEffort,
    ];

    // ✅ fixed line width between circles
    final lineWidth = isDesktop ? 60.0 : 40.w;

    return Container(
      width:  double.infinity,
     color: Color(0XFF0D3592),
      // color:  AppColors.rxPrimaryColor,//const Color(0xFF1A3A8F),
      padding: EdgeInsets.fromLTRB(
        isDesktop ? 40 : 16.w,
        isDesktop ? 24 : 16.h,
        isDesktop ? 40 : 16.w,
        isDesktop ? 16 : 12.h,
      ),
      child: Column(
        children: [

          // ── Circles + connecting lines ──────────────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, // shrink to content
              children: List.generate(totalSteps, (i) {
                final isActive    = i == currentStep;
                final isCompleted = i < currentStep;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => ref
                          .read(onboardingStepProvider.notifier)
                          .goToStep(i),
                      child: _StepCircle(
                        index:       i,
                        isActive:    isActive,
                        isCompleted: isCompleted,
                        size:        circleSize,
                      ),
                    ),
                    if (i < totalSteps - 1)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width:  lineWidth,
                        height: lineHeight,
                        color: isCompleted
                            ? AppColors.greenColor
                            : Colors.white.withOpacity(0.3),
                      ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: isDesktop ? 8 : 6.h),

          // ── Labels — centered under each circle ────────────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, // shrink to content
              children: List.generate(totalSteps, (i) {
                final isActive    = i == currentStep;
                final isCompleted = i < currentStep;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: circleSize,
                      child: Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        maxLines:  1,
                        softWrap:  false,
                        overflow:  TextOverflow.visible,
                        style: TextStyle(
                          fontSize:   isDesktop ? 16 : 11.sp,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w700,
                          color: isCompleted
                              ? AppColors.greenColor
                              : Colors.white,
                        ),
                      ),
                    ),
                    if (i < totalSteps - 1)
                      SizedBox(width: lineWidth), // ✅ same gap as line
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: isDesktop ? 14 : 12.h),

          // ── Progress bar — centered, under circles only ─────────
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, // shrink to content
              children: List.generate(totalSteps, (i) {
                final isFilled = i <= currentStep;

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width:  circleSize,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isFilled
                            ? Colors.white
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    if (i < totalSteps - 1)
                      SizedBox(width: lineWidth), // same gap as line
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: isDesktop ? 10 : 8.h),

          // ── Step counter ──────────────────────────────────────
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${l10n.step} ${currentStep + 1} / $totalSteps          ',
              style: TextStyle(
                fontSize: isDesktop ? 16 : 12.sp,
                color:    Colors.white,
                fontWeight: FontWeight.bold,
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
  final int    index;
  final bool   isActive;
  final bool   isCompleted;
  final double size;

  const _StepCircle({
    required this.index,
    required this.isActive,
    required this.isCompleted,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Colors.white
            : isCompleted
            ? AppColors.greenColor
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
          Icons.check_rounded,fontWeight: FontWeight.bold,
          size:  size * 0.5,
          color: isCompleted ? Colors.white : Color(0xFF1A3A8F),
        )
            : Text(
          '${index + 1}',
          style: TextStyle(
            fontSize:   size * 0.4,
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