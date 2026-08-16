import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/l10n/app_localizations.dart';
import 'package:kurdistan_paradise_travel_guide/screens/account_edit_screens.dart';
import 'package:kurdistan_paradise_travel_guide/services/account_settings_service.dart';
import 'package:kurdistan_paradise_travel_guide/theme/app_theme.dart';

void main() {
  testWidgets(
    'email change confirms the old account before showing new email',
    (tester) async {
      final service = _FakeAccountSettingsService();
      await _pump(tester, service);

      expect(find.text('Current email'), findsOneWidget);
      expect(find.text('Current password'), findsOneWidget);
      expect(find.text('New email'), findsNothing);

      await tester.enterText(find.byType(TextField).at(1), 'AppPassword!1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(service.confirmedEmail, 'old@example.com');
      expect(service.confirmedPassword, 'AppPassword!1');
      expect(find.byType(NewEmailVerificationScreen), findsOneWidget);
      expect(find.text('New email'), findsOneWidget);
      expect(find.text('Verification Code'), findsOneWidget);
    },
  );

  testWidgets('new email page sends and verifies a six-digit code', (
    tester,
  ) async {
    final service = _FakeAccountSettingsService();
    await _pump(tester, service);
    await tester.enterText(find.byType(TextField).at(1), 'AppPassword!1');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'new@example.com');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('Send Code'));
    await tester.pumpAndSettle();

    expect(service.sentTo, 'new@example.com');
    expect(find.text('Verify & Save'), findsOneWidget);

    await tester.tap(find.text('Verify & Save'));
    await tester.pumpAndSettle();
    expect(service.verifiedEmail, 'new@example.com');
    expect(service.verifiedCode, '123456');
  });
}

Future<void> _pump(WidgetTester tester, AccountSettingsService service) async {
  tester.view.physicalSize = const Size(430, 1000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightForLocale(const Locale('en')),
      home: ChangeEmailScreen(
        initialValue: 'old@example.com',
        service: service,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAccountSettingsService extends AccountSettingsService {
  String? confirmedEmail;
  String? confirmedPassword;
  String? sentTo;
  String? verifiedEmail;
  String? verifiedCode;

  @override
  Future<void> confirmEmailIdentity({
    required String currentEmail,
    required String currentPassword,
  }) async {
    confirmedEmail = currentEmail;
    confirmedPassword = currentPassword;
  }

  @override
  Future<void> sendEmailChangeCode(String newEmail) async {
    sentTo = newEmail;
  }

  @override
  Future<void> confirmEmailChangeCode({
    required String newEmail,
    required String code,
  }) async {
    verifiedEmail = newEmail;
    verifiedCode = code;
  }
}
