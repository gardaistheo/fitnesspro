import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:mobile/providers/meal_provider.dart';
import 'package:mobile/services/api_service.dart';
import 'package:mobile/screens/food_scanner/food_scanner_screen.dart';

class MockApiService extends Mock implements ApiService {}

void main() {
  late MockApiService mockApiService;
  late MealProvider mealProvider;

  setUp(() {
    mockApiService = MockApiService();
    mealProvider = MealProvider(apiService: mockApiService);
  });

  Widget buildTestable() {
    return ChangeNotifierProvider<MealProvider>.value(
      value: mealProvider,
      child: const MaterialApp(home: FoodScannerScreen()),
    );
  }

  testWidgets('starts on the camera phase with a shutter button', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable());

    expect(find.byIcon(Icons.camera_alt), findsOneWidget);
    expect(find.text('Powered by Passio AI'), findsOneWidget);
  });

  testWidgets('tapping the shutter transitions to scanning then result phase', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable());

    await tester.tap(find.byIcon(Icons.camera_alt));
    await tester.pump();

    expect(find.text('Analyse en cours...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1700));

    expect(find.text('✓ REPAS IDENTIFIÉ'), findsOneWidget);
    expect(find.text('Poulet et riz'), findsOneWidget);
  });

  testWidgets(
    'confirming the result posts the meal and shows the logged confirmation',
    (tester) async {
      when(() => mockApiService.post('/meals', any())).thenAnswer(
        (_) async => {
          'data': {
            'id': 1,
            'name': 'Poulet et riz',
            'calories': 650,
            'proteins': 45,
            'carbs': 70,
            'fats': 15,
            'logged_at': DateTime.now().toIso8601String(),
          },
        },
      );

      await tester.pumpWidget(buildTestable());
      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1700));

      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      verify(() => mockApiService.post('/meals', any())).called(1);
      expect(find.text('Repas enregistré !'), findsOneWidget);

      // Drain the screen's auto-dismiss timer so it doesn't leak into other tests.
      await tester.pump(const Duration(milliseconds: 2400));
    },
  );

  testWidgets('manual entry numpad builds up the calorie value', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable());

    await tester.tap(find.text('Saisie manuelle'));
    await tester.pump();

    for (final digit in ['4', '5', '0']) {
      final key = find.widgetWithText(ElevatedButton, digit);
      await tester.ensureVisible(key);
      await tester.tap(key);
      await tester.pump();
    }

    expect(find.text('450'), findsOneWidget);
  });

  testWidgets('manual entry preset buttons set the calorie value directly', (
    tester,
  ) async {
    await tester.pumpWidget(buildTestable());

    await tester.tap(find.text('Saisie manuelle'));
    await tester.pump();

    final presetButton = find.widgetWithText(OutlinedButton, '400');
    await tester.ensureVisible(presetButton);
    await tester.tap(presetButton);
    await tester.pump();

    final bigDisplay = tester
        .widgetList<Text>(find.text('400'))
        .firstWhere((widget) => widget.style?.fontSize == 52);
    expect(bigDisplay.data, '400');
  });

  testWidgets(
    'manual entry Ajouter button is disabled until a valid calorie value is entered',
    (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.text('Saisie manuelle'));
      await tester.pump();

      final addButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Ajouter'),
      );
      expect(addButton.onPressed, isNull);

      final presetButton = find.widgetWithText(OutlinedButton, '400');
      await tester.ensureVisible(presetButton);
      await tester.tap(presetButton);
      await tester.pump();

      final addButtonAfter = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Ajouter'),
      );
      expect(addButtonAfter.onPressed, isNotNull);
    },
  );

  testWidgets(
    'backspace removes the last digit and re-disables Ajouter once empty',
    (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.text('Saisie manuelle'));
      await tester.pump();

      final digitFour = find.widgetWithText(ElevatedButton, '4');
      await tester.ensureVisible(digitFour);
      await tester.tap(digitFour);
      await tester.pump();
      expect(find.text('4'), findsWidgets);

      final backspace = find.widgetWithText(ElevatedButton, '⌫');
      await tester.ensureVisible(backspace);
      await tester.tap(backspace);
      await tester.pump();

      final bigDisplay = tester
          .widgetList<Text>(find.text('0'))
          .firstWhere((widget) => widget.style?.fontSize == 52);
      expect(bigDisplay.data, '0');
      final addButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Ajouter'),
      );
      expect(addButton.onPressed, isNull);
    },
  );

  testWidgets(
    'Rescanner returns to the camera phase and clears the previous result',
    (tester) async {
      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1700));
      expect(find.text('✓ REPAS IDENTIFIÉ'), findsOneWidget);

      await tester.tap(find.text('Rescanner'));
      await tester.pump();

      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.text('✓ REPAS IDENTIFIÉ'), findsNothing);
    },
  );

  testWidgets('a failed manual entry submission stays on the manual phase', (
    tester,
  ) async {
    when(
      () => mockApiService.post('/meals', any()),
    ).thenThrow(Exception('network error'));

    await tester.pumpWidget(buildTestable());
    await tester.tap(find.text('Saisie manuelle'));
    await tester.pump();

    final presetButton = find.widgetWithText(OutlinedButton, '400');
    await tester.ensureVisible(presetButton);
    await tester.tap(presetButton);
    await tester.pump();

    final addButton = find.widgetWithText(ElevatedButton, 'Ajouter');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pump();

    verify(() => mockApiService.post('/meals', any())).called(1);
    expect(find.text('Repas enregistré !'), findsNothing);
    expect(find.text('calories'), findsOneWidget);
  });
}
