import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Device-local Settings preferences that do not belong in Firestore.
class SettingsPreferences {
  const SettingsPreferences();

  static const String _notificationsKey = 'notifications_enabled_v1';
  static const String _languageKey = 'settings_language_v1';
  static const String _unitsKey = 'settings_units_v1';

  Future<bool> notificationsEnabled() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_notificationsKey) ?? true;
    } on Exception catch (error) {
      debugPrint('Could not read notification preference: $error');
      return true;
    }
  }

  Future<void> setNotificationsEnabled(bool value) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_notificationsKey, value);
    } on Exception catch (error) {
      debugPrint('Could not save notification preference: $error');
      rethrow;
    }
  }

  Future<String> languageCode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguageCode(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_languageKey, value);
  }

  Future<String> units() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_unitsKey) ?? 'km';
  }

  Future<void> setUnits(String value) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_unitsKey, value);
  }
}
