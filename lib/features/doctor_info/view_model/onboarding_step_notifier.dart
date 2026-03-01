import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class OnboardingStepNotifier extends StateNotifier<int> {
  OnboardingStepNotifier() : super(0);

  void goToStep(int step) => state = step;

  void next(int total) {
    if (state < total - 1) {
      state++;
    }
  }

  void previous() {
    if (state > 0) {
      state--;
    }
  }
}

final onboardingStepProvider =
StateNotifierProvider<OnboardingStepNotifier, int>(
        (ref) => OnboardingStepNotifier());