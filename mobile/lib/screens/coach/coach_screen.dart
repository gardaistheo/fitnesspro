import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

/// Placeholder for the Coach IA chat screen.
///
/// Scope for this screen (real chat backed by an AI service) is not yet
/// confirmed for this project — see Plan-implementation-FitnessPro.md,
/// "Points à trancher". This is a themed empty state only, no chat logic
/// and no backend calls, so the tab has a real destination in the nav
/// shell without committing to an unconfirmed feature.
class CoachScreen extends StatelessWidget {
  const CoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.purple.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: colors.purple,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Coach IA',
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bientôt disponible',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.muted2,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
