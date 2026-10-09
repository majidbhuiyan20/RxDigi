import 'package:flutter/services.dart';

/// Ultra-responsive native haptic and tactile audio feedback utility.
/// Delivers an Apple Health / iOS grade sensory experience.
class AppFeedback {
  AppFeedback._();

  /// Triggered on subtle checkbox taps or minor interactions.
  static void playLight() {
    HapticFeedback.lightImpact();
  }

  /// Triggered on successful dose taken, habit checked, or positive action.
  static void playSuccess() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Triggered on perfect day completion, milestone unlocked, or celebration.
  static void playMilestone() {
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 100), () {
      HapticFeedback.heavyImpact();
    });
    SystemSound.play(SystemSoundType.click);
  }

  /// Triggered on celebration cards, weekly digests, and trophy shares.
  static void playCelebration() {
    playMilestone();
  }

  /// Triggered on quick tabs, segmented switcher, or date selector.
  static void playSelection() {
    HapticFeedback.selectionClick();
  }

  /// Triggered on warnings, deletion confirmation, or out-of-stock alert.
  static void playWarning() {
    HapticFeedback.heavyImpact();
  }
}
