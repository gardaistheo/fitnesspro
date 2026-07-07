import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/screens/landing/landing_screen.dart';

void main() {
  testWidgets('Landing screen background actually changes between light and dark theme', (tester) async {
    Future<Color> scaffoldColorFor(ThemeData theme) async {
      await tester.pumpWidget(MaterialApp(theme: theme, home: const LandingScreen()));
      await tester.pumpAndSettle();
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      return scaffold.backgroundColor!;
    }

    final darkColor = await scaffoldColorFor(AppTheme.dark);
    final lightColor = await scaffoldColorFor(AppTheme.light);

    expect(darkColor, isNot(equals(lightColor)));
  });
}
