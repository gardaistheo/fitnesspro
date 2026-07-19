import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/program_provider.dart';
import '../../widgets/diff_chip.dart';
import 'workout_detail_screen.dart';

const List<String> kWorkoutDifficulties = [
  'Tous',
  'Débutant',
  'Intermédiaire',
  'Avancé',
];

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _selectedDifficulty = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProgramProvider>(context, listen: false).loadPrograms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final programProvider = Provider.of<ProgramProvider>(context);
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: kWorkoutDifficulties.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final difficulty = kWorkoutDifficulties[index];
                  final isSelected = difficulty == _selectedDifficulty;
                  return ChoiceChip(
                    label: Text(difficulty),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedDifficulty = difficulty);
                      programProvider.loadPrograms(difficulty: difficulty);
                    },
                    backgroundColor: colors.surface2,
                    selectedColor: colors.accent.withValues(alpha: 0.13),
                    labelStyle: TextStyle(
                      color: isSelected ? colors.accent : colors.muted2,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: programProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: colors.accent),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: programProvider.programs.length,
                      itemBuilder: (context, index) {
                        final program = programProvider.programs[index];
                        final firstThree = program.exercises
                            .take(3)
                            .map((e) => e.exerciseName)
                            .join(' · ');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            border: Border.all(color: colors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      WorkoutDetailScreen(program: program),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              program.name,
                                              style: TextStyle(
                                                color: colors.text,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              program.muscles.join(', '),
                                              style: TextStyle(
                                                color: colors.muted2,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DiffChip(difficulty: program.difficulty),
                                    ],
                                  ),
                                  if (firstThree.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.only(top: 12),
                                      decoration: BoxDecoration(
                                        border: Border(
                                          top: BorderSide(color: colors.border),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              firstThree,
                                              style: TextStyle(
                                                color: colors.muted2,
                                                fontSize: 12,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: colors.muted2,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
