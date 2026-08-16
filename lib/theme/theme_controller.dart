import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the app is showing its dark ("Lush Horizon: Moonlit") appearance.
///
/// Shared app-wide so the choice survives navigation: the toggle lives on the
/// Language screen, but the Login screen has to honour the same value.
///
/// The root `MaterialApp` listens to this notifier, so every screen receives
/// the selected app-wide theme immediately.
///
final ValueNotifier<bool> appDarkMode = ValueNotifier<bool>(false);

/// Persists the app-wide theme choice while keeping [appDarkMode] as the
/// lightweight controller existing screens already listen to.
class ThemePreference {
  ThemePreference._();

  static const String _key = 'dark_mode_enabled_v1';

  static Future<void> restore() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      appDarkMode.value = preferences.getBool(_key) ?? false;
    } on Exception catch (error) {
      debugPrint('Could not restore the theme preference: $error');
    }
  }

  static Future<void> setDarkMode(bool value) async {
    appDarkMode.value = value;
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_key, value);
    } on Exception catch (error) {
      debugPrint('Could not save the theme preference: $error');
    }
  }
}
