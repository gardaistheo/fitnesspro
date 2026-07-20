import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/quiz_data.dart';
import 'package:mobile/screens/quiz/quiz_screen.dart';

void main() {
  Widget buildTestable(void Function(QuizData) onDone) {
    return MaterialApp(home: QuizScreen(onDone: onDone));
  }

  Future<void> selectLevel(WidgetTester tester, String level) async {
    await tester.tap(find.text(level));
    await tester.pump();
  }

  Future<void> tapContinue(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(ElevatedButton, 'Continuer →'));
    await tester.pumpAndSettle();
  }

  testWidgets('continue is disabled until a level is selected on step 1', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable((_) {}));

    expect(find.text('Étape 1 sur 6'), findsOneWidget);
    final button = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuer →'),
    );
    expect(button.onPressed, isNull);

    await selectLevel(tester, 'Débutant');

    final buttonAfter = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Continuer →'),
    );
    expect(buttonAfter.onPressed, isNotNull);
  });

  testWidgets(
    'total steps is 6 when location is not Maison, skipping the equipment step',
    (tester) async {
      QuizData? result;
      await tester.pumpWidget(buildTestable((d) => result = d));

      await selectLevel(tester, 'Débutant');
      await tapContinue(tester);

      await tester.tap(find.text('Prendre de la masse'));
      await tester.pump();
      await tapContinue(tester);

      await tester.tap(find.text('Lun'));
      await tester.pump();
      await tapContinue(tester);

      expect(find.text("Où t'entraînes-tu ?"), findsOneWidget);
      await tester.tap(find.text('Salle'));
      await tester.pump();

      expect(find.text('Étape 4 sur 6'), findsOneWidget);
      await tapContinue(tester);

      // Equipment step must be skipped entirely — next screen is calories in.
      expect(find.text('Apports caloriques'), findsOneWidget);
      expect(find.text('Ton matériel'), findsNothing);

      await tapContinue(tester);
      expect(find.text('Dépenses caloriques'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Créer mon programme →'),
      );
      await tester.pump();

      expect(result, isNotNull);
      expect(result!.location, 'Salle');
      expect(result!.equipment, isEmpty);
    },
  );

  testWidgets(
    'total steps is 7 when location is Maison, including the equipment step',
    (tester) async {
      await tester.pumpWidget(buildTestable((_) {}));

      await selectLevel(tester, 'Débutant');
      await tapContinue(tester);

      await tester.tap(find.text('Maintenir'));
      await tester.pump();
      await tapContinue(tester);

      await tester.tap(find.text('Lun'));
      await tester.pump();
      await tapContinue(tester);

      await tester.tap(find.text('Maison'));
      await tester.pump();

      expect(find.text('Étape 4 sur 7'), findsOneWidget);
      await tapContinue(tester);

      expect(find.text('Ton matériel'), findsOneWidget);
      expect(find.text('Étape 5 sur 7'), findsOneWidget);
    },
  );

  testWidgets(
    'back button returns to the previous step and preserves selections',
    (tester) async {
      await tester.pumpWidget(buildTestable((_) {}));

      await selectLevel(tester, 'Avancé');
      await tapContinue(tester);
      expect(find.text('Quel est ton objectif ?'), findsOneWidget);

      await tester.tap(find.text('← Retour'));
      await tester.pump();

      expect(find.text('Quel est ton niveau ?'), findsOneWidget);

      // The "Avancé" selection made before navigating forward must survive
      // the round trip back to this step — check its card renders as active
      // (accent-colored title) rather than just present.
      final titleStyle = tester.widget<Text>(find.text('Avancé')).style;
      expect(titleStyle?.color, const Color(0xFFC1FF4D));
    },
  );

  testWidgets('equipment step "Aucun matériel" link clears all selections', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable((_) {}));

    await selectLevel(tester, 'Débutant');
    await tapContinue(tester);
    await tester.tap(find.text('Maintenir'));
    await tester.pump();
    await tapContinue(tester);
    await tester.tap(find.text('Lun'));
    await tester.pump();
    await tapContinue(tester);
    await tester.tap(find.text('Maison'));
    await tester.pump();
    await tapContinue(tester);

    expect(find.text('Ton matériel'), findsOneWidget);
    await tester.tap(find.text('Haltères'));
    await tester.pump();
    await tester.tap(find.text('Kettlebell'));
    await tester.pump();

    await tester.ensureVisible(
      find.text('Aucun matériel (poids du corps uniquement)'),
    );
    await tester.tap(find.text('Aucun matériel (poids du corps uniquement)'));
    await tester.pump();

    final container = tester.widget<Container>(
      find
          .ancestor(of: find.text('Haltères'), matching: find.byType(Container))
          .first,
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNot(equals(Colors.transparent)));
    // "cleared" means the chip is no longer in its active (accent-tinted) state.
    expect(
      (decoration.border as Border).top.color,
      isNot(equals(const Color(0xFFC1FF4D))),
    );
  });

  testWidgets('calorie presets update the displayed value', (tester) async {
    QuizData? result;
    await tester.pumpWidget(buildTestable((d) => result = d));

    await selectLevel(tester, 'Débutant');
    await tapContinue(tester);
    await tester.tap(find.text('Maintenir'));
    await tester.pump();
    await tapContinue(tester);
    await tester.tap(find.text('Lun'));
    await tester.pump();
    await tapContinue(tester);
    await tester.tap(find.text('Salle'));
    await tester.pump();
    await tapContinue(tester);

    expect(find.text('Apports caloriques'), findsOneWidget);
    await tester.tap(find.text('Élevé'));
    await tester.pump();
    // The big display and the "Élevé" preset row both read "2500 kcal" once
    // selected — two matches confirms the display tracks the preset tap.
    expect(find.text('2500 kcal', findRichText: true), findsNWidgets(2));

    await tapContinue(tester);
    expect(find.text('Dépenses caloriques'), findsOneWidget);
    await tester.tap(find.text('Actif'));
    await tester.pump();
    expect(find.text('600 kcal', findRichText: true), findsNWidgets(2));

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Créer mon programme →'),
    );
    await tester.pump();

    expect(result!.caloriesIn, 2500);
    expect(result!.caloriesOut, 600);
  });
}
