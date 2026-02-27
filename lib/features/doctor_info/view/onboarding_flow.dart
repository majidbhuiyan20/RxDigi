import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ── Entry Point ───────────────────────────────────────────────────────────────

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // ── Step data ─────────────────────────────────────────────────────────────
  final List<Map<String, String>> _steps = [
    {'title': 'পরিচয়',  'en': 'Introduction'},
    {'title': 'যোগ্যতা', 'en': 'Qualification'},
    {'title': 'চেষ্টার', 'en': 'Effort'},
    {'title': 'প্রোফাইল','en': 'Profile'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve:    Curves.easeInOut,
      );
    } else {
      // ✅ onboarding complete — navigate to main app
      // Navigator.pushNamedAndRemoveUntil(context, Routes.homeScreen, (_) => false);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve:    Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A3A8F),
      body: SafeArea(
        child: Column(
          children: [
            // ── Step Header ────────────────────────────────────────────
            _StepHeader(
              currentStep: _currentStep,
              totalSteps:  _totalSteps,
              steps:       _steps,
            ),

            // ── Page Content ───────────────────────────────────────────
            Expanded(
              child: PageView(
                controller:    _pageController,
                physics:       const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  _Step1Introduction(onNext: _nextStep),
                  _Step2Qualification(onNext: _nextStep, onBack: _prevStep),
                  _Step3Effort(onNext: _nextStep, onBack: _prevStep),
                  _Step4Profile(onNext: _nextStep, onBack: _prevStep),
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

class _StepHeader extends StatelessWidget {
  final int                        currentStep;
  final int                        totalSteps;
  final List<Map<String, String>>  steps;

  const _StepHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:   const Color(0xFF1A3A8F),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
      child: Column(
        children: [
          // ── Step circles + line ───────────────────────────────────
          Row(
            children: List.generate(totalSteps, (i) {
              final isActive    = i == currentStep;
              final isCompleted = i < currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // ── Circle ───────────────────────────────────────
                    _StepCircle(
                      index:       i,
                      isActive:    isActive,
                      isCompleted: isCompleted,
                    ),
                    // ── Line between circles ─────────────────────────
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
          SizedBox(height: 8.h),

          // ── Step labels ───────────────────────────────────────────
          Row(
            children: List.generate(totalSteps, (i) {
              final isActive    = i == currentStep;
              final isCompleted = i < currentStep;

              return Expanded(
                child: Text(
                  steps[i]['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize:   11.sp,
                    fontWeight: isActive
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: isActive || isCompleted
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: 12.h),

          // ── Progress bar ──────────────────────────────────────────
          Row(
            children: List.generate(totalSteps, (i) {
              final isCompleted = i <= currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  height:              3,
                  margin:              EdgeInsets.only(
                      right: i < totalSteps - 1 ? 2.w : 0),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.white
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
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
                fontSize: 12.sp,
                color:    Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: 4.h),
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
            ? Colors.white.withOpacity(0.9)
            : Colors.white.withOpacity(0.2),
        boxShadow: isActive
            ? [
          BoxShadow(
            color:      Colors.white.withOpacity(0.3),
            blurRadius: 12,
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

// ── Step 1: Introduction ──────────────────────────────────────────────────────

class _Step1Introduction extends StatelessWidget {
  final VoidCallback onNext;

  const _Step1Introduction({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      stepNumber: 1,
      onNext:     onNext,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icon ────────────────────────────────────────────────
          Container(
            width:  100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size:  48.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32.h),

          Text(
            'স্বাগতম!',
            style: TextStyle(
              fontSize:   32.sp,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'RxDigi-তে আপনাকে স্বাগত জানাই। আমাদের সাথে আপনার স্বাস্থ্য যাত্রা শুরু করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize:   15.sp,
                color:      Colors.white.withOpacity(0.8),
                height:     1.6,
              ),
            ),
          ),
          SizedBox(height: 48.h),

          _buildNextButton(context, onNext, 'পরবর্তী'),
        ],
      ),
    );
  }
}

// ── Step 2: Qualification ─────────────────────────────────────────────────────

class _Step2Qualification extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step2Qualification({
    required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      stepNumber: 2,
      onNext:     onNext,
      onBack:     onBack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Icon(
              Icons.school_rounded,
              size:  48.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32.h),

          Text(
            'যোগ্যতা',
            style: TextStyle(
              fontSize:   32.sp,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'আপনার পেশাদার যোগ্যতা এবং অভিজ্ঞতা সম্পর্কে আমাদের জানান।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color:    Colors.white.withOpacity(0.8),
                height:   1.6,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // ── Input ────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildTextField(
              hint:  'আপনার যোগ্যতা লিখুন',
              icon:  Icons.badge_rounded,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildTextField(
              hint:  'অভিজ্ঞতার বছর',
              icon:  Icons.work_history_rounded,
              isNumber: true,
            ),
          ),
          SizedBox(height: 32.h),

          _buildNextButton(context, onNext, 'পরবর্তী'),
        ],
      ),
    );
  }
}

// ── Step 3: Effort ────────────────────────────────────────────────────────────

class _Step3Effort extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step3Effort({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      stepNumber: 3,
      onNext:     onNext,
      onBack:     onBack,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width:  100.w,
            height: 100.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.15),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size:  48.sp,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 32.h),

          Text(
            'চেষ্টার',
            style: TextStyle(
              fontSize:   32.sp,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'আপনার লক্ষ্য নির্ধারণ করুন এবং আপনার প্রচেষ্টার মাত্রা বেছে নিন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                color:    Colors.white.withOpacity(0.8),
                height:   1.6,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // ── Goal options ─────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _GoalSelector(),
          ),
          SizedBox(height: 32.h),

          _buildNextButton(context, onNext, 'পরবর্তী'),
        ],
      ),
    );
  }
}

// ── Step 4: Profile ───────────────────────────────────────────────────────────

class _Step4Profile extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _Step4Profile({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return _StepScaffold(
      stepNumber: 4,
      onNext:     onNext,
      onBack:     onBack,
      isLast:     true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Avatar picker ────────────────────────────────────────
          Stack(
            children: [
              Container(
                width:  90.w,
                height: 90.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(
                      color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.person_rounded,
                  size:  44.sp,
                  color: Colors.white,
                ),
              ),
              Positioned(
                right:  0,
                bottom: 0,
                child: Container(
                  width:  28.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size:  16.sp,
                    color: const Color(0xFF1A3A8F),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          Text(
            'প্রোফাইল',
            style: TextStyle(
              fontSize:   32.sp,
              fontWeight: FontWeight.w800,
              color:      Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'আপনার প্রোফাইল সম্পন্ন করুন।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color:    Colors.white.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(height: 24.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                _buildTextField(hint: 'পুরো নাম',    icon: Icons.person_rounded),
                SizedBox(height: 12.h),
                _buildTextField(hint: 'ফোন নম্বর',   icon: Icons.phone_rounded, isNumber: true),
                SizedBox(height: 12.h),
                _buildTextField(hint: 'ঠিকানা',       icon: Icons.location_on_rounded),
              ],
            ),
          ),
          SizedBox(height: 32.h),

          _buildNextButton(context, onNext, 'সম্পন্ন করুন ✓'),
        ],
      ),
    );
  }
}

// ── Goal Selector (Step 3) ────────────────────────────────────────────────────

class _GoalSelector extends StatefulWidget {
  @override
  State<_GoalSelector> createState() => _GoalSelectorState();
}

class _GoalSelectorState extends State<_GoalSelector> {
  int _selected = 0;

  final List<Map<String, dynamic>> _goals = [
    {'label': 'হালকা',    'icon': Icons.sentiment_satisfied_rounded},
    {'label': 'মাঝারি',   'icon': Icons.sentiment_neutral_rounded},
    {'label': 'কঠিন',     'icon': Icons.local_fire_department_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_goals.length, (i) {
        final isSelected = _selected == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _goals[i]['icon'] as IconData,
                    color: isSelected
                        ? const Color(0xFF1A3A8F)
                        : Colors.white,
                    size: 24.sp,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _goals[i]['label'] as String,
                    style: TextStyle(
                      fontSize:   13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1A3A8F)
                          : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Shared Scaffold ───────────────────────────────────────────────────────────

class _StepScaffold extends StatelessWidget {
  final int          stepNumber;
  final Widget       child;
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final bool         isLast;

  const _StepScaffold({
    required this.stepNumber,
    required this.child,
    required this.onNext,
    this.onBack,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A3A8F), Color(0xFF0D2560)],
          begin:  Alignment.topCenter,
          end:    Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: child,
        ),
      ),
    );
  }
}

// ── Shared Helpers ────────────────────────────────────────────────────────────

Widget _buildNextButton(
    BuildContext context, VoidCallback onNext, String label) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 24.w),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onNext,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF1A3A8F),
          padding:         EdgeInsets.symmetric(vertical: 16.h),
          elevation:       0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize:   16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ),
  );
}

Widget _buildTextField({
  required String   hint,
  required IconData icon,
  bool              isNumber = false,
}) {
  return TextField(
    keyboardType: isNumber
        ? TextInputType.number
        : TextInputType.text,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      hintText:      hint,
      hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.5)),
      prefixIcon: Icon(icon,
          color: Colors.white.withOpacity(0.7)),
      filled:    true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide:   BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
            color: Colors.white.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(
            color: Colors.white, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w, vertical: 14.h),
    ),
  );
}