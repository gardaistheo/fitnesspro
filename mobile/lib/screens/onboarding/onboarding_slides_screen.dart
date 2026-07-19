import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/quiz_data.dart';

class _Slide {
  final String emoji;
  final String title;
  final String body;

  const _Slide({required this.emoji, required this.title, required this.body});
}

class OnboardingSlidesScreen extends StatefulWidget {
  final QuizData? quizData;
  final VoidCallback onDone;

  const OnboardingSlidesScreen({
    super.key,
    this.quizData,
    required this.onDone,
  });

  @override
  State<OnboardingSlidesScreen> createState() => _OnboardingSlidesScreenState();
}

class _OnboardingSlidesScreenState extends State<OnboardingSlidesScreen> {
  int _step = 0;

  List<_Slide> get _slides {
    final level = widget.quizData?.level ?? 'Intermédiaire';
    final goal = widget.quizData?.goal ?? 'prendre de la masse';

    return [
      _Slide(
        emoji: '🎉',
        title: 'Ton programme est prêt !',
        body:
            'Basé sur ton profil $level, nous avons créé un programme sur mesure pour ton objectif : $goal.',
      ),
      const _Slide(
        emoji: '📊',
        title: 'Ton dashboard personnel',
        body:
            "Retrouve toutes tes métriques en un coup d'œil : prochain entraînement, calories, hydratation et ton streak.",
      ),
      const _Slide(
        emoji: '🧠',
        title: 'Ton Coach IA',
        body:
            'Pose toutes tes questions à ton coach personnel disponible 24h/24. Nutrition, technique, motivation.',
      ),
      const _Slide(
        emoji: '📷',
        title: 'Scanner ton alimentation',
        body:
            "Prends en photo ton repas et l'IA calcule automatiquement les calories. Saisie manuelle disponible si besoin.",
      ),
    ];
  }

  bool get _isLast => _step == _slides.length - 1;

  void _next() {
    if (_isLast) {
      widget.onDone();
    } else {
      setState(() => _step++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);
    final slides = _slides;
    final slide = slides[_step];

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(slide.emoji, style: const TextStyle(fontSize: 68)),
              const SizedBox(height: 22),
              Text(
                slide.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 280),
                child: Text(
                  slide.body,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.muted2,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < slides.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _step ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _step ? colors.accent : colors.surface2,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _isLast ? 'Accéder à mon espace →' : 'Suivant →',
                      style: TextStyle(
                        color: colors.bg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              if (!_isLast)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: TextButton(
                    onPressed: widget.onDone,
                    child: Text(
                      'Passer',
                      style: TextStyle(color: colors.muted, fontSize: 13),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
