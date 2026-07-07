import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/exercise_provider.dart';
import '../../widgets/diff_chip.dart';
import 'exercise_detail_screen.dart';

const List<String> kExerciseCategories = [
  'Tous',
  'Jambes',
  'Poitrine',
  'Dos',
  'Épaules',
  'Bras',
  'Triceps',
  'Abdominaux',
];

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen> {
  String _selectedCategory = 'Tous';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExerciseProvider>(context, listen: false).loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    final exerciseProvider = Provider.of<ExerciseProvider>(context);

    return Scaffold(
      backgroundColor: FPColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                onChanged: exerciseProvider.setSearchQuery,
                style: TextStyle(color: FPColors.text),
                decoration: InputDecoration(
                  hintText: 'Rechercher un exercice',
                  hintStyle: TextStyle(color: FPColors.muted2),
                  filled: true,
                  fillColor: FPColors.surface2,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: kExerciseCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = kExerciseCategories[index];
                  final isSelected = category == _selectedCategory;
                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                      exerciseProvider.loadExercises(category: category);
                    },
                    backgroundColor: FPColors.surface2,
                    selectedColor: FPColors.accentTint22,
                    labelStyle: TextStyle(
                      color: isSelected ? FPColors.accent : FPColors.muted2,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: exerciseProvider.isLoading
                  ? Center(child: CircularProgressIndicator(color: FPColors.accent))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: exerciseProvider.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = exerciseProvider.exercises[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: FPColors.accentTint18,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.fitness_center, color: FPColors.accent),
                          ),
                          title: Text(
                            exercise.name,
                            style: TextStyle(color: FPColors.text, fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            exercise.muscles.join(', '),
                            style: TextStyle(color: FPColors.muted2, fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DiffChip(difficulty: exercise.difficulty),
                              Icon(Icons.chevron_right, color: FPColors.muted2),
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ExerciseDetailScreen(exercise: exercise),
                              ),
                            );
                          },
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
