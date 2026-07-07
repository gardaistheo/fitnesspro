import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class SelectCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String description;
  final bool active;
  final VoidCallback onTap;

  const SelectCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.description,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: active ? colors.accent.withValues(alpha: 0.1) : colors.surface2,
          border: Border.all(color: active ? colors.accent : colors.border, width: 2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: active ? colors.accent : colors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(color: colors.muted2, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
