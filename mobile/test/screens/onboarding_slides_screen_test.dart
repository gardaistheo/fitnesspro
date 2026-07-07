import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/quiz_data.dart';
import 'package:mobile/screens/onboarding/onboarding_slides_screen.dart';

void main() {
  testWidgets('shows the first slide with defaults when no quiz data is provided', (tester) async {
    var doneCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingSlidesScreen(onDone: () => doneCalled = true),
    ));

    expect(find.text('Ton programme est prêt !'), findsOneWidget);
    expect(
      find.textContaining('Basé sur ton profil Intermédiaire'),
      findsOneWidget,
    );
    expect(find.textContaining('prendre de la masse'), findsOneWidget);
    expect(doneCalled, isFalse);
  });

  testWidgets('interpolates the level and goal from quiz data into the first slide', (tester) async {
    final quizData = QuizData(level: 'Avancé', goal: 'Perdre du poids');

    await tester.pumpWidget(MaterialApp(
      home: OnboardingSlidesScreen(quizData: quizData, onDone: () {}),
    ));

    expect(find.textContaining('Basé sur ton profil Avancé'), findsOneWidget);
    expect(find.textContaining('Perdre du poids'), findsOneWidget);
  });

  testWidgets('Suivant advances through all 4 slides in order', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OnboardingSlidesScreen(onDone: () {})));

    expect(find.text('Ton programme est prêt !'), findsOneWidget);

    await tester.tap(find.text('Suivant →'));
    await tester.pump();
    expect(find.text('Ton dashboard personnel'), findsOneWidget);

    await tester.tap(find.text('Suivant →'));
    await tester.pump();
    expect(find.text('Ton Coach IA'), findsOneWidget);

    await tester.tap(find.text('Suivant →'));
    await tester.pump();
    expect(find.text('Scanner ton alimentation'), findsOneWidget);

    // Final slide has no "Suivant" or "Passer" — only the finishing CTA.
    expect(find.text('Suivant →'), findsNothing);
    expect(find.text('Passer'), findsNothing);
    expect(find.text('Accéder à mon espace →'), findsOneWidget);
  });

  testWidgets('Passer skips directly to onDone from any non-final slide', (tester) async {
    var doneCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingSlidesScreen(onDone: () => doneCalled = true),
    ));

    await tester.tap(find.text('Passer'));
    await tester.pump();

    expect(doneCalled, isTrue);
  });

  testWidgets('the final CTA calls onDone', (tester) async {
    var doneCalled = false;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingSlidesScreen(onDone: () => doneCalled = true),
    ));

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Suivant →'));
      await tester.pump();
    }

    await tester.tap(find.text('Accéder à mon espace →'));
    await tester.pump();

    expect(doneCalled, isTrue);
  });
}
