import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/screens/coach/coach_screen.dart';

void main() {
  testWidgets('shows a themed coming-soon placeholder with no chat UI', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CoachScreen()));

    expect(find.text('Coach IA'), findsOneWidget);
    expect(find.text('Bientôt disponible'), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);

    // No chat input or message list should exist yet — this is a placeholder only.
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(ListView), findsNothing);
  });
}
