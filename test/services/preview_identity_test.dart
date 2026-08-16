import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/services/preview_identity.dart';
import 'package:kurdistan_paradise_travel_guide/services/user_profile_service.dart';

void main() {
  // Every test drives the in-memory cache via `debugSet`, so none of them
  // touch the host machine's real SharedPreferences.
  setUp(() => PreviewIdentity.debugSet());

  group('PreviewIdentity', () {
    test('is empty until something is recorded', () {
      expect(PreviewIdentity.current.hasName, isFalse);
      expect(PreviewIdentity.current.name, isNull);
    });

    test('a blank or whitespace name does not count as recorded', () {
      PreviewIdentity.debugSet(name: '   ');
      expect(PreviewIdentity.current.hasName, isFalse);
    });

    test('records what registration captured', () {
      PreviewIdentity.debugSet(
        name: 'Aram Kareem',
        email: 'aram@example.com',
        phone: '+964 750 111 2222',
      );

      expect(PreviewIdentity.current.hasName, isTrue);
      expect(PreviewIdentity.current.name, 'Aram Kareem');
      expect(PreviewIdentity.current.email, 'aram@example.com');
    });
  });

  group('UserProfileService.bundledProfile', () {
    test('falls back to the reference profile before anyone registers', () {
      final profile = UserProfileService.bundledProfile();
      expect(profile.name, 'Sara Ahmad');
    });

    test('prefers the registered identity over the stand-in', () {
      PreviewIdentity.debugSet(
        name: 'Aram Kareem',
        email: 'aram@example.com',
        phone: '+964 750 111 2222',
      );

      final profile = UserProfileService.bundledProfile();
      // The bug this covers: the side drawer greeted every registered user as
      // "Sara Ahmad", because the stand-in was returned unconditionally.
      expect(profile.name, 'Aram Kareem');
      expect(profile.email, 'aram@example.com');
      expect(profile.phone, '+964 750 111 2222');
    });

    test(
      'a partial identity keeps the stand-in only for the missing parts',
      () {
        PreviewIdentity.debugSet(name: 'Aram Kareem');

        final profile = UserProfileService.bundledProfile();
        expect(profile.name, 'Aram Kareem');
        expect(profile.email, 'Saraahmad@gmail.com');
      },
    );
  });
}
