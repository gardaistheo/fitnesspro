import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/program_model.dart';
import '../../providers/program_provider.dart';
import '../../widgets/diff_chip.dart';
import '../../widgets/fp_chip.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final Program program;

  const WorkoutDetailScreen({super.key, required this.program});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  bool _isAdding = false;

  Future<void> _addToPlanning() async {
    setState(() => _isAdding = true);

    final programProvider = Provider.of<ProgramProvider>(context, listen: false);
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledDate =
        '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

    final success = await programProvider.addToPlanning(
      programId: widget.program.id,
      scheduledDate: scheduledDate,
    );

    if (!mounted) return;
    setState(() => _isAdding = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ ${widget.program.name} ajouté au planning'),
          backgroundColor: FPColors.greenTint22,
          duration: const Duration(milliseconds: 2200),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = widget.program;

    return Scaffold(
      backgroundColor: FPColors.bg,
      appBar: AppBar(
        backgroundColor: FPColors.bg,
        title: Text(program.name, style: TextStyle(color: FPColors.text)),
        iconTheme: IconThemeData(color: FPColors.text),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    children: [
                      DiffChip(difficulty: program.difficulty),
                      if (program.duration != null)
                        FPChip(label: '${program.duration} min', color: FPColors.blue),
                      ...program.muscles.map((m) => FPChip(label: m, color: FPColors.purple)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...program.exercises.map((exercise) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: FPColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: FPColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.exerciseName,
                            style: TextStyle(color: FPColors.text, fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(exercise.sets, (i) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: FPColors.surface2,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Série ${i + 1}',
                                      style: TextStyle(color: FPColors.muted2, fontSize: 11),
                                    ),
                                    Text(
                                      '${exercise.reps}',
                                      style: TextStyle(
                                        color: FPColors.accent,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isAdding ? null : _addToPlanning,
                style: ElevatedButton.styleFrom(backgroundColor: FPColors.accent),
                child: _isAdding
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: FPColors.bg),
                      )
                    : Text('📅 Ajouter à mon planning', style: TextStyle(color: FPColors.bg)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
