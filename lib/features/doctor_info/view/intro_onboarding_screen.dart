import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:prescripto/app/app_colors.dart';
import 'package:prescripto/app/app_routes.dart';
import 'package:prescripto/app/app_text_style.dart';

class IntroOnboardingScreen extends StatefulWidget {
  const IntroOnboardingScreen({super.key});

  @override
  State<IntroOnboardingScreen> createState() => _IntroOnboardingScreenState();
}

class _IntroOnboardingScreenState extends State<IntroOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Digital Prescription",
      description: "Create professional digital prescriptions in seconds. Say goodbye to handwritten errors.",
      imagePath: "assets/icons/onboarding_one.png",
    ),
    OnboardingData(
      title: "Patient Management",
      description: "Keep all your patient records organized and accessible from anywhere, anytime.",
      imagePath: "assets/icons/onboarind_two.png",
    ),
    OnboardingData(
      title: "Clinic Efficiency",
      description: "Manage your chamber schedules and appointments effortlessly with our built-in tools.",
      imagePath: "assets/icons/onboarding_three.png",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 600 : double.infinity),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: AppTextStyles.plusJakartaSans,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return OnboardingPageContent(data: _pages[index]);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? AppColors.primaryColor : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        backgroundColor: AppColors.primaryColor,
                        onPressed: () {
                          if (_currentPage == _pages.length - 1) {
                            Navigator.pushReplacementNamed(context, AppRoutes.onboardingFlow);
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Icon(
                          _currentPage == _pages.length - 1 ? Icons.check : Icons.arrow_forward,
                          color: Colors.white,
                        ),
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

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({required this.title, required this.description, required this.imagePath});
}

class OnboardingPageContent extends StatelessWidget {
  final OnboardingData data;
  const OnboardingPageContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            data.imagePath,
            height: 280.h,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 40),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: AppTextStyles.normalLargeBlackTextStyle(context).copyWith(
              fontSize: 28.sp,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.normalSmallGreyTextStyle(context).copyWith(
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
