import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class DiffChip extends StatelessWidget {
  final String difficulty;

  const DiffChip({super.key, required this.difficulty});

  Color _color(FPColorScheme colors) {
    switch (difficulty) {
      case 'Débutant':
        return colors.green;
      case 'Intermédiaire':
        return colors.orange;
      case 'Avancé':
        return colors.red;
      default:
        return colors.muted2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);
    final color = _color(colors);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        difficulty,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
