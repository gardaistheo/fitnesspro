import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mobile/models/exercise_model.dart';
import 'package:mobile/screens/exercises/exercise_detail_screen.dart';

Exercise buildExercise({String? youtubeUrl}) {
  return Exercise(
    id: 1,
    name: 'Squat',
    category: 'Jambes',
    muscles: ['Quadriceps', 'Fessiers'],
    difficulty: 'Intermédiaire',
    description: 'Un exercice de base.',
    instructions: const ['Étape 1', 'Étape 2'],
    youtubeUrl: youtubeUrl,
  );
}

void main() {
  // YoutubePlayer renders a real flutter_inappwebview WebView, which has no
  // platform implementation registered in the plain flutter_test
  // environment — so only the no-video/invalid-URL fallback path can be
  // exercised as a full widget test. The URL -> video ID parsing that
  // decides which path is taken is covered separately below, without
  // mounting the real player widget.
  testWidgets('shows the static placeholder when youtubeUrl is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: ExerciseDetailScreen(exercise: buildExercise())),
    );

    expect(find.byType(YoutubePlayer), findsNothing);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
  });

  testWidgets(
    'shows the static placeholder when youtubeUrl does not match a known format',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ExerciseDetailScreen(
            exercise: buildExercise(youtubeUrl: 'not a url'),
          ),
        ),
      );

      expect(find.byType(YoutubePlayer), findsNothing);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    },
  );

  testWidgets(
    'still renders description, muscles, and instructions without a video',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ExerciseDetailScreen(exercise: buildExercise())),
      );

      expect(find.text('Un exercice de base.'), findsOneWidget);
      expect(find.text('MUSCLES TRAVAILLÉS'), findsOneWidget);
      expect(find.text('Quadriceps'), findsOneWidget);
      expect(find.text('Étape 1'), findsOneWidget);
    },
  );

  group(
    'YouTube URL parsing (drives which path ExerciseDetailScreen takes)',
    () {
      test('parses a standard watch URL', () {
        expect(
          YoutubePlayer.convertUrlToId(
            'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
          ),
          'dQw4w9WgXcQ',
        );
      });

      test('parses a youtu.be short URL', () {
        expect(
          YoutubePlayer.convertUrlToId('https://youtu.be/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ',
        );
      });

      test('returns null for a non-YouTube URL', () {
        expect(
          YoutubePlayer.convertUrlToId('https://example.com/video'),
          isNull,
        );
      });

      test('returns null for arbitrary non-URL text', () {
        expect(YoutubePlayer.convertUrlToId('not a url'), isNull);
      });
    },
  );
}
