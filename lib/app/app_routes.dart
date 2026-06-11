import 'package:flutter/material.dart';
import 'package:prescripto/features/doctor_info/view/intro_onboarding_screen.dart';
import 'package:prescripto/features/doctor_info/view/onboarding_flow.dart';
import 'package:prescripto/features/home/view/main_navigation_screen.dart';
import 'package:prescripto/features/settings/view/settings_screen.dart';
import '../features/splash/splash_screen.dart';
import 'app_string.dart';

class AppRoutes {
  static const String splashRoute = "/";
  static const String homeScreenRoute = "/homeScreen";
  static const String settingsScreenRoute = "/settingsScreen";
  static const String mainNavigationRoute = "/mainNavigation";
  static const String loginRoute = "/loginScreen";
  static const String personalInfoScreen = "/personalInfoScreen";
  static const String onboardingFlow = "/onboardingFlow";
  static const String introOnboarding = "/introOnboarding";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case AppRoutes.splashRoute:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.settingsScreenRoute:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.introOnboarding:
        return MaterialPageRoute(builder: (_) => const IntroOnboardingScreen());
      case AppRoutes.onboardingFlow:
        return MaterialPageRoute(builder: (_) => const OnboardingFlow());
      case AppRoutes.homeScreenRoute:
      case AppRoutes.mainNavigationRoute:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      default:
        return undefinedRoute();
    }
  }

  static Route<dynamic> undefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(AppString.noRoute),
        ),
        body: const Center(
          child: Text(AppString.noRoute),
        ),
      ),
    );
  }
}
