import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hero section with glow effect
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          colors.accent.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // Hero content
                  Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        '🎯',
                        style: TextStyle(fontSize: 68),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Transforme\nton corps\navec IA',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: colors.text,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Découvre un programme de musculation personnalisé\net atteins tes objectifs en 90 jours',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colors.muted2,
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Pricing card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border, width: 1),
                  borderRadius: BorderRadius.circular(20),
                  color: colors.surface,
                ),
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Label
                    Text(
                      'ACCÈS ILLIMITÉ',
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '9,99',
                          style: TextStyle(
                            color: colors.text,
                            fontSize: 46,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '€/mois',
                          style: TextStyle(
                            color: colors.muted2,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // Features
                    _buildFeature(colors, 'Coach IA personnalisé'),
                    const SizedBox(height: 12),
                    _buildFeature(colors, 'Plus de 500 exercices'),
                    const SizedBox(height: 12),
                    _buildFeature(colors, 'Suivi nutritionnel'),
                    const SizedBox(height: 12),
                    _buildFeature(colors, 'Plans d\'entraînement adaptés'),
                  ],
                ),
              ),
            ),

            // CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Commencer mon essai gratuit →',
                    style: TextStyle(
                      color: colors.bg,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Text(
              '7 jours gratuits',
              style: TextStyle(
                color: colors.muted2,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: colors.muted2, fontSize: 13),
                  children: [
                    const TextSpan(text: 'Déjà un compte ? '),
                    TextSpan(
                      text: 'Se connecter',
                      style: TextStyle(color: colors.accent, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(FPColorScheme colors, String text) {
    return Row(
      children: [
        Text(
          '✓',
          style: TextStyle(
            color: colors.accent,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: colors.muted2,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
