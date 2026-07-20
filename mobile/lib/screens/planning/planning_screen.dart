import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../models/program_model.dart';
import '../../models/workout_session_model.dart';
import '../../providers/program_provider.dart';
import '../../providers/workout_session_provider.dart';

class PlanningScreen extends StatefulWidget {
  const PlanningScreen({super.key});

  @override
  State<PlanningScreen> createState() => _PlanningScreenState();
}

class _PlanningScreenState extends State<PlanningScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutSessionProvider>(
        context,
        listen: false,
      ).loadSessions();
    });
  }

  Color _chipColor(FPColorScheme colors, String label) {
    if (label == "Aujourd'hui") return colors.accent;
    if (label == 'Passé') return colors.muted;
    return colors.blue;
  }

  Future<void> _deleteSession(WorkoutSession session) async {
    final provider = Provider.of<WorkoutSessionProvider>(
      context,
      listen: false,
    );
    await provider.deleteSession(session.id);
  }

  Future<void> _showAddModal() async {
    final programProvider = Provider.of<ProgramProvider>(
      context,
      listen: false,
    );
    if (programProvider.programs.isEmpty) {
      await programProvider.loadPrograms();
    }
    if (!mounted) return;
    final colors = FPColorScheme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: programProvider.programs.length,
            itemBuilder: (context, index) {
              final Program program = programProvider.programs[index];
              return ListTile(
                title: Text(program.name, style: TextStyle(color: colors.text)),
                subtitle: Text(
                  program.muscles.join(', '),
                  style: TextStyle(color: colors.muted2),
                ),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _pickDateAndSchedule(programProvider, program);
                },
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickDateAndSchedule(
    ProgramProvider programProvider,
    Program program,
  ) async {
    final colors = FPColorScheme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: today,
      lastDate: DateTime(now.year + 2),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: colors.accent,
              onPrimary: colors.bg,
              surface: colors.surface,
              onSurface: colors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: colors.accent,
              onPrimary: colors.bg,
              surface: colors.surface,
              onSurface: colors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;

    final scheduledDate =
        '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}';
    final scheduledTime = pickedTime != null
        ? '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}'
        : null;

    final success = await programProvider.addToPlanning(
      programId: program.id,
      scheduledDate: scheduledDate,
      scheduledTime: scheduledTime,
    );
    if (!mounted) return;

    if (success) {
      Provider.of<WorkoutSessionProvider>(
        context,
        listen: false,
      ).loadSessions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            programProvider.error ??
                "Impossible d'ajouter la séance au planning.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<WorkoutSessionProvider>(context);
    final colors = FPColorScheme.of(context);
    final grouped = sessionProvider.sessionsByDate;
    final sortedDates = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: colors.text),
                        tooltip: 'Retour',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Text(
                        'Planning',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _showAddModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      '+ Ajouter',
                      style: TextStyle(
                        color: colors.bg,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessionProvider.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: colors.accent),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        final date = sortedDates[dateIndex];
                        final sessionsForDate = grouped[date]!;
                        final label = sessionProvider.dateLabel(date);
                        final chipColor = _chipColor(colors, label);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    '${date.day}/${date.month}/${date.year}'
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: colors.muted2,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Divider(color: colors.border),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: chipColor.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(
                                        color: chipColor,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...sessionsForDate.map((session) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(color: colors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: colors.accent.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      alignment: Alignment.center,
                                      child: Semantics(
                                        excludeSemantics: true,
                                        child: const Text(
                                          '💪',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.program?.name ?? 'Séance',
                                            style: TextStyle(
                                              color: colors.text,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            [
                                              if (session.scheduledTime != null)
                                                session.scheduledTime,
                                              if (session.program != null)
                                                session.program!.muscles.join(
                                                  ', ',
                                                ),
                                              if (session.program?.duration !=
                                                  null)
                                                '${session.program!.duration} min',
                                            ].whereType<String>().join(' · '),
                                            style: TextStyle(
                                              color: colors.muted2,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_outline,
                                        color: colors.red,
                                      ),
                                      tooltip: 'Supprimer la séance',
                                      onPressed: () => _deleteSession(session),
                                      style: IconButton.styleFrom(
                                        backgroundColor: colors.red.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
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
