import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class ProgressBarPill extends StatelessWidget {
  final int value;
  final int max;
  final Color? color;
  final double height;

  const ProgressBarPill({
    super.key,
    required this.value,
    required this.max,
    this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);
    final pct = (value / max).clamp(0.0, 1.0);

    return Semantics(
      label: 'Progression',
      value: '${(pct * 100).round()}%',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: pct,
          minHeight: height,
          backgroundColor: colors.surface2,
          valueColor: AlwaysStoppedAnimation(color ?? colors.accent),
        ),
      ),
    );
  }
}
