import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class DiffChip extends StatelessWidget {
  final String difficulty;

  const DiffChip({super.key, required this.difficulty});

  Color get _color {
    switch (difficulty) {
      case 'Débutant':
        return FPColors.green;
      case 'Intermédiaire':
        return FPColors.orange;
      case 'Avancé':
        return FPColors.red;
      default:
        return FPColors.muted2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        difficulty,
        style: TextStyle(color: _color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
