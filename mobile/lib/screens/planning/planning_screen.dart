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
      Provider.of<WorkoutSessionProvider>(context, listen: false).loadSessions();
    });
  }

  Color _chipColor(String label) {
    if (label == "Aujourd'hui") return FPColors.accent;
    if (label == 'Passé') return FPColors.muted;
    return FPColors.blue;
  }

  Future<void> _deleteSession(WorkoutSession session) async {
    final provider = Provider.of<WorkoutSessionProvider>(context, listen: false);
    await provider.deleteSession(session.id);
  }

  Future<void> _showAddModal() async {
    final programProvider = Provider.of<ProgramProvider>(context, listen: false);
    if (programProvider.programs.isEmpty) {
      await programProvider.loadPrograms();
    }
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: FPColors.surface,
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
                title: Text(program.name, style: TextStyle(color: FPColors.text)),
                subtitle: Text(program.muscles.join(', '), style: TextStyle(color: FPColors.muted2)),
                onTap: () async {
                  Navigator.of(context).pop();
                  final tomorrow = DateTime.now().add(const Duration(days: 1));
                  final scheduledDate =
                      '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
                  final success =
                      await programProvider.addToPlanning(programId: program.id, scheduledDate: scheduledDate);
                  if (success && mounted) {
                    Provider.of<WorkoutSessionProvider>(this.context, listen: false).loadSessions();
                  }
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<WorkoutSessionProvider>(context);
    final grouped = sessionProvider.sessionsByDate;
    final sortedDates = grouped.keys.toList()..sort();

    return Scaffold(
      backgroundColor: FPColors.bg,
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
                        icon: Icon(Icons.chevron_left, color: FPColors.text),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Text(
                        'Planning',
                        style: TextStyle(color: FPColors.text, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _showAddModal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FPColors.accent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text('+ Ajouter', style: TextStyle(color: FPColors.bg, fontSize: 13, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: sessionProvider.isLoading
                  ? Center(child: CircularProgressIndicator(color: FPColors.accent))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        final date = sortedDates[dateIndex];
                        final sessionsForDate = grouped[date]!;
                        final label = sessionProvider.dateLabel(date);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Text(
                                    '${date.day}/${date.month}/${date.year}'.toUpperCase(),
                                    style: TextStyle(
                                      color: FPColors.muted2,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Divider(color: FPColors.border)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _chipColor(label).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      label,
                                      style: TextStyle(color: _chipColor(label), fontSize: 11, fontWeight: FontWeight.w700),
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
                                  color: FPColors.surface,
                                  borderRadius: BorderRadius.circular(11),
                                  border: Border.all(color: FPColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: FPColors.accentTint18,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text('💪', style: TextStyle(fontSize: 20)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.program?.name ?? 'Séance',
                                            style: TextStyle(color: FPColors.text, fontWeight: FontWeight.w800),
                                          ),
                                          Text(
                                            [
                                              if (session.scheduledTime != null) session.scheduledTime,
                                              if (session.program != null) session.program!.muscles.join(', '),
                                              if (session.program?.duration != null) '${session.program!.duration} min',
                                            ].whereType<String>().join(' · '),
                                            style: TextStyle(color: FPColors.muted2, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: FPColors.red),
                                      onPressed: () => _deleteSession(session),
                                      style: IconButton.styleFrom(
                                        backgroundColor: FPColors.redTint18,
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
