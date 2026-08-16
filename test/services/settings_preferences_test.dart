import 'package:flutter_test/flutter_test.dart';
import 'package:kurdistan_paradise_travel_guide/services/settings_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const preferences = SettingsPreferences();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('notifications default to enabled on a fresh installation', () async {
    expect(await preferences.notificationsEnabled(), isTrue);
  });

  test('notification selection is persisted on this device', () async {
    await preferences.setNotificationsEnabled(false);

    expect(await preferences.notificationsEnabled(), isFalse);
  });
}
