import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers whether the 3-slide onboarding intro has already been completed.
///
/// Onboarding runs on first install only. The flag is written when the user
/// reaches the end of the last slide — not when they start it — so quitting
/// part-way through shows the intro again next launch.
///
/// This is a plain local preference, not user data: it is deliberately *not*
/// stored in Firestore, because it must work before anyone has signed in and
/// it carries nothing worth syncing between devices.
class OnboardingPreferences {
  const OnboardingPreferences._();

  static const String _seenKey = 'onboarding_completed_v1';

  /// Overrides the stored value in tests, so a widget test never depends on
  /// the host machine's real preferences.
  @visibleForTesting
  static bool? debugOverrideSeen;

  /// Whether onboarding has already been completed on this device.
  ///
  /// Any storage failure is treated as "not seen": showing the intro one
  /// extra time is harmless, whereas throwing here would block the whole
  /// language → login flow.
  static Future<bool> hasSeenOnboarding() async {
    if (debugOverrideSeen != null) return debugOverrideSeen!;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_seenKey) ?? false;
    } on Exception catch (error) {
      debugPrint('Could not read the onboarding flag: $error');
      return false;
    }
  }

  /// Records that onboarding finished, so it never runs again.
  ///
  /// Failing to persist only means the intro is shown once more — not worth
  /// interrupting the user for, so the error is logged and swallowed.
  static Future<void> markOnboardingSeen() async {
    if (debugOverrideSeen != null) {
      debugOverrideSeen = true;
      return;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenKey, true);
    } on Exception catch (error) {
      debugPrint('Could not save the onboarding flag: $error');
    }
  }
}
