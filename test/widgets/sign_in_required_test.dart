import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/l10n/app_localizations.dart';
import 'package:kurdistan_paradise_travel_guide/screens/login_screen.dart';
import 'package:kurdistan_paradise_travel_guide/theme/app_theme.dart';
import 'package:kurdistan_paradise_travel_guide/widgets/sign_in_required.dart';

void main() {
  group('SignInRequired — the shared guest gate', () {
    testWidgets('draws the icon, the caller wording and one Log In button', (
      tester,
    ) async {
      await _pump(
        tester,
        const SignInRequired(title: 'Sign in to X', body: 'Because Y.'),
      );

      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(find.text('Sign in to X'), findsOneWidget);
      expect(find.text('Because Y.'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('Log In pushes the login screen', (tester) async {
      await _pump(
        tester,
        const SignInRequired(title: 'Sign in to X', body: 'Because Y.'),
      );

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('localizes its button in Kurdish and Arabic', (tester) async {
      for (final locale in const [Locale('ku'), Locale('ar')]) {
        await _pump(
          tester,
          const SignInRequired(title: 'x', body: 'y'),
          locale: locale,
        );
        expect(find.text(AppLocalizations(locale).logIn), findsOneWidget);
      }
    });

    testWidgets('fits a narrow phone at 2x text without overflowing', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _pump(
        tester,
        const SignInRequired(
          title: 'Sign in to manage payment',
          body:
              'Your saved cards are tied to your account, so we need you '
              'signed in to show them.',
        ),
        textScale: 2,
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('SignInRequiredSheet — the gate for controls with no screen', () {
    testWidgets('shows the caller wording and a custom icon', (tester) async {
      await _pumpSheet(tester);

      expect(find.text('Sign in to add a photo'), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    });

    testWidgets('Log In closes the sheet before pushing login', (tester) async {
      await _pumpSheet(tester);

      await tester.tap(find.text('Log In'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
      // The sheet must not be left underneath the pushed route.
      expect(find.byType(SignInRequiredSheet), findsNothing);
    });
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightForLocale(locale),
      builder: (context, inner) => MediaQuery.withClampedTextScaling(
        minScaleFactor: textScale,
        maxScaleFactor: textScale,
        child: inner!,
      ),
      home: Scaffold(body: child),
    ),
  );
  await tester.pumpAndSettle();
}

/// Opens the sheet the way the drawer does, so the pop-then-push path is the
/// one under test rather than a bare widget render.
Future<void> _pumpSheet(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightForLocale(const Locale('en')),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (_) => const SignInRequiredSheet(
                title: 'Sign in to add a photo',
                body: 'Your profile picture is saved to your account.',
                icon: Icons.account_circle_outlined,
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}
