import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class TagChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const TagChip({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
            decoration: BoxDecoration(
              color: active
                  ? colors.accent.withValues(alpha: 0.1)
                  : colors.surface2,
              border: Border.all(
                color: active ? colors.accent : colors.border,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: active ? colors.accent : colors.muted2,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
