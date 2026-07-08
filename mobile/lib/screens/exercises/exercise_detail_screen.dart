import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../core/constants/colors.dart';
import '../../models/exercise_model.dart';
import '../../widgets/diff_chip.dart';
import '../../widgets/fp_chip.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    final url = widget.exercise.youtubeUrl;
    final videoId = url != null ? YoutubePlayer.convertUrlToId(url) : null;
    if (videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);
    final exercise = widget.exercise;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        backgroundColor: colors.bg,
        title: Text(exercise.name, style: TextStyle(color: colors.text)),
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideo(colors),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              children: [
                FPChip(label: exercise.category, color: colors.blue),
                DiffChip(difficulty: exercise.difficulty),
              ],
            ),
            const SizedBox(height: 16),

            if (exercise.description != null) ...[
              Text(
                exercise.description!,
                style: TextStyle(color: colors.muted2, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 24),
            ],

            Text(
              'MUSCLES TRAVAILLÉS',
              style: TextStyle(
                color: colors.muted2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: exercise.muscles
                  .map((muscle) => FPChip(label: muscle, color: colors.purple))
                  .toList(),
            ),
            const SizedBox(height: 24),

            Text(
              'INSTRUCTIONS',
              style: TextStyle(
                color: colors.muted2,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            ...exercise.instructions.asMap().entries.map((entry) {
              final index = entry.key;
              final instruction = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colors.accent.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: colors.accent, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        instruction,
                        style: TextStyle(color: colors.muted2, fontSize: 13, height: 1.5),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildVideo(FPColorScheme colors) {
    final controller = _controller;

    if (controller == null) {
      // No video URL, or it didn't match a recognizable YouTube format —
      // fall back to a static placeholder rather than a broken player.
      return Container(
        height: 190,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.play_arrow, color: colors.accent, size: 32),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: colors.accent,
        progressColors: ProgressBarColors(
          playedColor: colors.accent,
          handleColor: colors.accent,
        ),
      ),
    );
  }
}
