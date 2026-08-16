import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/services/email_verification_service.dart';
import 'package:kurdistan_paradise_travel_guide/services/password_reset_service.dart';

void main() {
  group('EmailVerificationService — preview mode', () {
    // No Firebase project exists yet, so these tests exercise the debug
    // stand-in. It is guarded by kDebugMode as well as the Firebase check, so
    // a release build can never take this path.
    test('is active while Firebase is unconfigured in a debug build', () {
      expect(EmailVerificationService.isPreviewMode, isTrue);
    });

    test('sending a code does not throw', () async {
      await expectLater(EmailVerificationService().sendCode(), completes);
    });

    test('accepts any six-digit code', () async {
      await expectLater(
        EmailVerificationService().verifyCode('123456'),
        completes,
      );
    });

    test('still rejects a code of the wrong length', () async {
      // Even the stand-in enforces the shape, so the screen's error path is
      // reachable during design review.
      await expectLater(
        EmailVerificationService().verifyCode('123'),
        throwsA(
          isA<ResetException>().having(
            (e) => e.kind,
            'kind',
            ResetErrorKind.incorrectCode,
          ),
        ),
      );
    });
  });
}
