import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kurdistan_paradise_travel_guide/theme/app_theme.dart';
import 'package:kurdistan_paradise_travel_guide/widgets/glass_list_row.dart';

void main() {
  testWidgets('draws its copy and invokes the whole-row action', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: GlassListRow(
            icon: Icons.help_outline,
            title: 'Payments & Refunds',
            subtitle: 'My payment failed but I ...',
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Payments & Refunds'), findsOneWidget);
    expect(find.text('My payment failed but I ...'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byType(GlassListRow));
    expect(tapped, isTrue);
  });

  testWidgets('uses a downward chevron for an expandable row', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: GlassListRow(
            icon: Icons.help_outline,
            title: 'Account',
            subtitle: 'Question preview',
            trailing: GlassListRowTrailing.expand,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
    expect(
      tester.getSize(find.byType(GlassListRow)).height,
      greaterThanOrEqualTo(GlassListRow.minHeight),
    );
  });

  testWidgets('reveals its body below a header whose top stays fixed', (
    tester,
  ) async {
    Future<void> pump({required bool expanded}) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: GlassListRow(
                icon: Icons.help_outline,
                title: 'Account',
                subtitle: 'Question preview',
                trailing: GlassListRowTrailing.expand,
                expanded: expanded,
                expandedChild: const Text('Expanded answer'),
                onTap: () {},
              ),
            ),
          ),
        ),
      );
    }

    await pump(expanded: false);
    final topBefore = tester.getTopLeft(find.byType(GlassListRow)).dy;
    final heightBefore = tester.getSize(find.byType(GlassListRow)).height;
    expect(find.text('Expanded answer'), findsNothing);

    await pump(expanded: true);
    await tester.pumpAndSettle();
    expect(find.text('Expanded answer'), findsOneWidget);
    expect(
      tester.getTopLeft(find.byType(GlassListRow)).dy,
      closeTo(topBefore, 0.1),
    );
    expect(
      tester.getSize(find.byType(GlassListRow)).height,
      greaterThan(heightBefore),
    );
  });
}
