import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/l10n/app_localizations.dart';
import 'package:kurdistan_paradise_travel_guide/screens/home_screen.dart';
import 'package:kurdistan_paradise_travel_guide/screens/login_screen.dart';
import 'package:kurdistan_paradise_travel_guide/screens/my_bookings_screen.dart';
import 'package:kurdistan_paradise_travel_guide/services/auth_service.dart';
import 'package:kurdistan_paradise_travel_guide/theme/app_theme.dart';

/// The preview account exists **only** so the app can be walked for design
/// review before a Firebase project exists. These tests pin the two properties
/// that make it safe: it is debug-only, and it accepts nothing but the exact
/// credentials.
void main() {
  group('Preview sign-in — the safety guarantees', () {
    test('is active only in preview mode', () {
      // `kDebugMode && !FirebaseBootstrap.isReady`. Under `flutter test` the
      // first is true and Firebase is unconfigured, so this must hold here —
      // and must stop holding the moment Firebase is wired up.
      expect(AuthService.isPreviewMode, isTrue);
    });

    test('accepts the documented credentials, and nothing else', () {
      final auth = AuthService();

      expect(auth.checkPreviewCredentials('kurdistan', r'Asd!@3'), isTrue);
      // Username is case-insensitive and trimmed; the password never is.
      expect(auth.checkPreviewCredentials('  Kurdistan ', r'Asd!@3'), isTrue);
      expect(auth.checkPreviewCredentials('KURDISTAN', r'Asd!@3'), isTrue);

      expect(auth.checkPreviewCredentials('kurdistan', r'asd!@3'), isFalse);
      expect(auth.checkPreviewCredentials('kurdistan', r'Asd!@3 '), isFalse);
      expect(auth.checkPreviewCredentials('kurdistan', ''), isFalse);
      expect(auth.checkPreviewCredentials('admin', r'Asd!@3'), isFalse);
      expect(auth.checkPreviewCredentials('', ''), isFalse);
    });

    test('the constants are what the login hint tells the user', () {
      expect(AuthService.previewUsername, 'kurdistan');
      expect(AuthService.previewPassword, r'Asd!@3');
    });
  });

  group('Login screen — preview sign-in', () {
    testWidgets('shows the debug banner so it cannot pass for real auth', (
      tester,
    ) async {
      await _pump(tester);

      expect(
        find.textContaining('PREVIEW MODE — not real sign-in'),
        findsOneWidget,
      );
    });

    testWidgets('the correct credentials open the dashboard, signed in', (
      tester,
    ) async {
      await _pump(tester);

      await _fillAndSubmit(tester, 'kurdistan', r'Asd!@3');

      final home = tester.widget<HomeScreen>(find.byType(HomeScreen));
      expect(home.isGuest, isFalse);
      expect(home.displayName, 'Kurdistan');
      // Login is replaced, not stacked — the auth flow is finished.
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets('a wrong password does not sign in', (tester) async {
      await _pump(tester);

      await _fillAndSubmit(tester, 'kurdistan', 'wrong');

      expect(find.byType(HomeScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.textContaining('wrong preview credentials'), findsOneWidget);
    });

    testWidgets('the username is accepted even though it is not an email', (
      tester,
    ) async {
      // The field validates as an email; preview mode has to let the one
      // account through or the button can never be reached.
      await _pump(tester);

      await _fillAndSubmit(tester, 'kurdistan', r'Asd!@3');

      expect(find.text('Enter a valid email address'), findsNothing);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('a non-email that is not the preview user is still rejected', (
      tester,
    ) async {
      await _pump(tester);

      await _fillAndSubmit(tester, 'notauser', r'Asd!@3');

      expect(find.byType(HomeScreen), findsNothing);
    });

    testWidgets('an empty form does not sign in', (tester) async {
      await _pump(tester);

      await tester.tap(find.widgetWithText(GestureDetector, 'Log In').last);
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsNothing);
    });
  });

  group('Signed in, the preview user reaches My Bookings', () {
    testWidgets('the drawer row opens the ticket list, not the sign-in '
        'prompt', (tester) async {
      await _pump(tester);
      await _fillAndSubmit(tester, 'kurdistan', r'Asd!@3');

      await tester.tap(find.byIcon(Icons.menu_rounded));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('My Bookings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('My Bookings'));
      await tester.pumpAndSettle();

      expect(find.byType(MyBookingsScreen), findsOneWidget);
      // Signed in, so the guest gate must not appear.
      expect(find.text('Sign in to see your bookings'), findsNothing);
    });
  });
}

// --- Helpers -----------------------------------------------------------------

Future<void> _fillAndSubmit(
  WidgetTester tester,
  String username,
  String password,
) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), username);
  await tester.enterText(fields.at(1), password);
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(GestureDetector, 'Log In').last);
  await tester.pumpAndSettle();
}

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(900, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightForLocale(const Locale('en')),
      darkTheme: AppTheme.darkForLocale(const Locale('en')),
      home: const LoginScreen(),
    ),
  );
  await tester.pumpAndSettle();
}
