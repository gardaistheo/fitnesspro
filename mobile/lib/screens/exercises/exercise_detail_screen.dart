import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/exercise_model.dart';
import '../../widgets/diff_chip.dart';
import '../../widgets/fp_chip.dart';

class ExerciseDetailScreen extends StatelessWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

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
            // Video placeholder
            Container(
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
            ),
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
}
