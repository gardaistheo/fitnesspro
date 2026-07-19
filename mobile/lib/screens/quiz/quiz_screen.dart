import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../models/quiz_data.dart';
import '../../widgets/progress_bar_pill.dart';
import '../../widgets/select_card.dart';
import '../../widgets/tag_chip.dart';

const _days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
const _equipment = [
  'Haltères',
  'Barre + disques',
  'Banc',
  'Barre de traction',
  'Kettlebell',
  'Élastiques',
  'TRX',
  'Vélo/Rameur',
];

const _titles = [
  'Quel est ton niveau ?',
  'Quel est ton objectif ?',
  'Tes disponibilités',
  "Où t'entraînes-tu ?",
  'Ton matériel',
  'Apports caloriques',
  'Dépenses caloriques',
];

const _subtitles = [
  'Sois honnête, cela personnalisera ton programme.',
  'Définis ton poids actuel et ton objectif.',
  "Quand es-tu disponible pour t'entraîner ?",
  "L'endroit influence le type d'exercices proposés.",
  'Sélectionne le matériel disponible chez toi.',
  'Combien de calories ingères-tu en moyenne ?',
  'Estimation hors activité sportive.',
];

class QuizScreen extends StatefulWidget {
  final void Function(QuizData data) onDone;

  const QuizScreen({super.key, required this.onDone});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _step = 0;
  final QuizData _d = QuizData();

  bool get _isHome => _d.location == 'Maison';
  int get _totalSteps => _isHome ? 7 : 6;
  int get _calInStep => _isHome ? 5 : 4;
  int get _calOutStep => _isHome ? 6 : 5;

  /// Maps the current wizard step to its title/subtitle index, since the
  /// equipment step (index 4 in the titles array) only exists when the user
  /// trains at home — mirrors the design's stepTitleIdx().
  int get _titleIdx {
    if (_step < 4) return _step;
    if (_isHome) {
      if (_step == 4) return 4;
      if (_step == 5) return 5;
      return 6;
    }
    if (_step == 4) return 5;
    return 6;
  }

  bool get _canNext {
    switch (_step) {
      case 0:
        return _d.level != null;
      case 1:
        return _d.goal != null &&
            _d.currentWeight.isNotEmpty &&
            _d.targetWeight.isNotEmpty;
      case 2:
        return _d.availableDays.isNotEmpty;
      case 3:
        return _d.location != null;
      default:
        return true;
    }
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      widget.onDone(_d);
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Étape ${_step + 1} sur $_totalSteps',
                        style: TextStyle(
                          color: colors.muted2,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_step > 0)
                        TextButton(
                          onPressed: _back,
                          child: Text(
                            '← Retour',
                            style: TextStyle(
                              color: colors.muted2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ProgressBarPill(value: _step + 1, max: _totalSteps),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titles[_titleIdx],
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _subtitles[_titleIdx],
                      style: TextStyle(
                        color: colors.muted2,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildBody(colors),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canNext ? _next : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    _step == _totalSteps - 1
                        ? 'Créer mon programme →'
                        : 'Continuer →',
                    style: TextStyle(
                      color: colors.bg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FPColorScheme colors) {
    if (_step == 0) return _buildLevelStep(colors);
    if (_step == 1) return _buildGoalStep(colors);
    if (_step == 2) return _buildAvailabilityStep(colors);
    if (_step == 3) return _buildLocationStep(colors);
    if (_isHome && _step == 4) return _buildEquipmentStep(colors);
    if (_step == _calInStep) return _buildCaloriesInStep(colors);
    if (_step == _calOutStep) return _buildCaloriesOutStep(colors);
    return const SizedBox();
  }

  Widget _buildLevelStep(FPColorScheme colors) {
    const levels = [
      ('🌱', 'Débutant', 'Moins de 6 mois de pratique'),
      ('💪', 'Intermédiaire', '6 mois à 2 ans de pratique'),
      ('🔥', 'Avancé', 'Plus de 2 ans, maîtrise des bases'),
    ];

    return Column(
      children: [
        for (final (emoji, label, desc) in levels) ...[
          SelectCard(
            emoji: emoji,
            title: label,
            description: desc,
            active: _d.level == label,
            onTap: () => setState(() => _d.level = label),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildGoalStep(FPColorScheme colors) {
    const goals = ['Perdre du poids', 'Maintenir', 'Prendre de la masse'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final g in goals)
              TagChip(
                label: g,
                active: _d.goal == g,
                onTap: () => setState(() => _d.goal = g),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Poids actuel (kg)',
                    style: TextStyle(
                      color: colors.muted2,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildNumberField(
                    colors,
                    initialValue: _d.currentWeight,
                    onChanged: (v) => setState(() => _d.currentWeight = v),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Poids cible (kg)',
                    style: TextStyle(
                      color: colors.muted2,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildNumberField(
                    colors,
                    initialValue: _d.targetWeight,
                    onChanged: (v) => setState(() => _d.targetWeight = v),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField(
    FPColorScheme colors, {
    required String initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: TextStyle(color: colors.text),
      decoration: InputDecoration(
        filled: true,
        fillColor: colors.surface2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colors.accent),
        ),
      ),
    );
  }

  Widget _buildAvailabilityStep(FPColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in _days)
              TagChip(
                label: day,
                active: _d.availableDays.contains(day),
                onTap: () => setState(() {
                  if (_d.availableDays.contains(day)) {
                    _d.availableDays.remove(day);
                  } else {
                    _d.availableDays.add(day);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Text.rich(
          TextSpan(
            style: TextStyle(
              color: colors.muted2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            children: [
              const TextSpan(text: 'Durée par séance : '),
              TextSpan(
                text: '${_d.hoursPerDay}h',
                style: TextStyle(color: colors.accent),
              ),
            ],
          ),
        ),
        Slider(
          value: _d.hoursPerDay,
          min: 0.5,
          max: 3,
          divisions: 5,
          activeColor: colors.accent,
          onChanged: (v) => setState(() => _d.hoursPerDay = v),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('30 min', style: TextStyle(color: colors.muted, fontSize: 11)),
            Text('3h', style: TextStyle(color: colors.muted, fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationStep(FPColorScheme colors) {
    const locations = [
      ('🏠', 'Maison', "Je m'entraîne depuis chez moi"),
      ('🏋️', 'Salle', "J'ai accès à une salle équipée"),
      ('🌳', 'Extérieur', 'Parcs, stades, espaces publics'),
    ];

    return Column(
      children: [
        for (final (emoji, label, desc) in locations) ...[
          SelectCard(
            emoji: emoji,
            title: label,
            description: desc,
            active: _d.location == label,
            onTap: () => setState(() {
              _d.location = label;
              // Changing location can toggle whether the equipment step
              // exists at all, so drop any equipment picked previously.
              if (label != 'Maison') _d.equipment.clear();
            }),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildEquipmentStep(FPColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sélectionne tout le matériel dont tu disposes.',
          style: TextStyle(color: colors.muted2, fontSize: 13),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final eq in _equipment)
              TagChip(
                label: eq,
                active: _d.equipment.contains(eq),
                onTap: () => setState(() {
                  if (_d.equipment.contains(eq)) {
                    _d.equipment.remove(eq);
                  } else {
                    _d.equipment.add(eq);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 14),
        TextButton(
          onPressed: () => setState(() => _d.equipment.clear()),
          child: Text(
            'Aucun matériel (poids du corps uniquement)',
            style: TextStyle(color: colors.muted, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCaloriesInStep(FPColorScheme colors) {
    const presets = [
      (1500, 'Léger', 'Repas simples, peu de snacks'),
      (2000, 'Modéré', '3 repas équilibrés'),
      (2500, 'Élevé', '3 repas + collations'),
      (3000, 'Très élevé', 'Prises de masse actives'),
    ];

    return Column(
      children: [
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_d.caloriesIn}',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' kcal',
                  style: TextStyle(color: colors.muted2, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        Slider(
          value: _d.caloriesIn.toDouble(),
          min: 1200,
          max: 4000,
          divisions: 56,
          activeColor: colors.accent,
          onChanged: (v) => setState(() => _d.caloriesIn = v.round()),
        ),
        const SizedBox(height: 4),
        for (final (cal, label, desc) in presets)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildPresetRow(
              colors,
              cal,
              label,
              desc,
              _d.caloriesIn,
              colors.accent,
              (v) => setState(() => _d.caloriesIn = v),
            ),
          ),
      ],
    );
  }

  Widget _buildCaloriesOutStep(FPColorScheme colors) {
    const presets = [
      (200, 'Sédentaire', 'Bureau, peu de déplacements'),
      (400, 'Modérément actif', 'Marche quotidienne'),
      (600, 'Actif', 'Travail physique ou sport quotidien'),
      (900, 'Très actif', 'Sport intense, travail manuel'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(color: colors.muted2, fontSize: 13, height: 1.5),
            children: [
              const TextSpan(text: 'Dépenses '),
              TextSpan(
                text: 'hors activité sportive',
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: '. Moyenne : 300–600 kcal/jour.'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${_d.caloriesOut}',
                  style: TextStyle(
                    color: colors.orange,
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: ' kcal',
                  style: TextStyle(color: colors.muted2, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        Slider(
          value: _d.caloriesOut.toDouble(),
          min: 100,
          max: 1200,
          divisions: 22,
          activeColor: colors.orange,
          onChanged: (v) => setState(() => _d.caloriesOut = v.round()),
        ),
        const SizedBox(height: 4),
        for (final (cal, label, desc) in presets)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildPresetRow(
              colors,
              cal,
              label,
              desc,
              _d.caloriesOut,
              colors.orange,
              (v) => setState(() => _d.caloriesOut = v),
            ),
          ),
      ],
    );
  }

  Widget _buildPresetRow(
    FPColorScheme colors,
    int cal,
    String label,
    String desc,
    int currentValue,
    Color activeColor,
    ValueChanged<int> onSelect,
  ) {
    final isActive = currentValue == cal;

    return InkWell(
      onTap: () => onSelect(cal),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: isActive ? activeColor : colors.border),
          borderRadius: BorderRadius.circular(10),
          color: isActive
              ? activeColor.withValues(alpha: 0.07)
              : Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? activeColor : colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(desc, style: TextStyle(color: colors.muted, fontSize: 12)),
              ],
            ),
            Text(
              '$cal kcal',
              style: TextStyle(
                color: colors.muted2,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
