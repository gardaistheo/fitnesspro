import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../providers/meal_provider.dart';

enum FoodScannerPhase { camera, scanning, result, manual, logged }

class ScannedMealResult {
  final String name;
  final int calories;
  final int proteins;
  final int carbs;
  final int fats;

  const ScannedMealResult({
    required this.name,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });
}

class FoodScannerScreen extends StatefulWidget {
  const FoodScannerScreen({super.key});

  @override
  State<FoodScannerScreen> createState() => _FoodScannerScreenState();
}

class _FoodScannerScreenState extends State<FoodScannerScreen> {
  FoodScannerPhase _phase = FoodScannerPhase.camera;
  ScannedMealResult? _result;
  String _manualCalories = '';

  void _startScan() {
    setState(() => _phase = FoodScannerPhase.scanning);

    // Placeholder for Passio.ai SDK integration (Phase 3.2).
    // Simulates recognition latency, then shows a mock result.
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _result = const ScannedMealResult(
          name: 'Poulet et riz',
          calories: 650,
          proteins: 45,
          carbs: 70,
          fats: 15,
        );
        _phase = FoodScannerPhase.result;
      });
    });
  }

  Future<void> _confirmResult() async {
    if (_result == null) return;

    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final success = await mealProvider.logMeal(
      name: _result!.name,
      calories: _result!.calories,
      proteins: _result!.proteins,
      carbs: _result!.carbs,
      fats: _result!.fats,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _phase = FoodScannerPhase.logged);
      Future.delayed(const Duration(milliseconds: 2300), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  bool get _canConfirmManualEntry {
    final calories = int.tryParse(_manualCalories);
    return calories != null && calories > 0;
  }

  Future<void> _confirmManualEntry() async {
    final calories = int.tryParse(_manualCalories);
    if (calories == null || calories <= 0) return;

    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final success = await mealProvider.logMeal(
      name: 'Repas (saisie manuelle)',
      calories: calories,
    );

    if (!mounted) return;

    if (success) {
      setState(() => _phase = FoodScannerPhase.logged);
      Future.delayed(const Duration(milliseconds: 2300), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  void _rescan() {
    setState(() {
      _result = null;
      _phase = FoodScannerPhase.camera;
    });
  }

  void _numpadTap(String digit) {
    setState(() {
      if (digit == '⌫') {
        if (_manualCalories.isNotEmpty) {
          _manualCalories = _manualCalories.substring(
            0,
            _manualCalories.length - 1,
          );
        }
      } else if (_manualCalories.length < 5) {
        _manualCalories += digit;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: switch (_phase) {
          FoodScannerPhase.camera => _buildCameraPhase(colors),
          FoodScannerPhase.scanning => _buildScanningPhase(colors),
          FoodScannerPhase.result => _buildResultPhase(colors),
          FoodScannerPhase.manual => _buildManualPhase(colors),
          FoodScannerPhase.logged => _buildLoggedPhase(colors),
        },
      ),
    );
  }

  Widget _buildCameraPhase(FPColorScheme colors) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(color: Colors.black),
        Center(
          child: Container(
            width: 210,
            height: 170,
            decoration: BoxDecoration(
              border: Border.all(color: colors.accent, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        Positioned(
          bottom: 60,
          child: Column(
            children: [
              Semantics(
                button: true,
                label: 'Prendre une photo du repas',
                child: GestureDetector(
                  onTap: _startScan,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: colors.bg, size: 28),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Powered by Passio AI',
                style: TextStyle(color: colors.muted2, fontSize: 11),
              ),
            ],
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: IconButton(
            icon: Icon(Icons.close, color: colors.text),
            tooltip: 'Fermer',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: TextButton(
            onPressed: () => setState(() => _phase = FoodScannerPhase.manual),
            child: Text(
              'Saisie manuelle',
              style: TextStyle(color: colors.muted2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanningPhase(FPColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation(colors.accent),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyse en cours...',
            style: TextStyle(color: colors.text, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPhase(FPColorScheme colors) {
    final result = _result!;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              border: Border.all(color: colors.accent.withValues(alpha: 0.27)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✓ REPAS IDENTIFIÉ',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  result.name,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.calories}',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMacro(
                        colors,
                        'Protéines',
                        result.proteins,
                        colors.blue,
                      ),
                    ),
                    Expanded(
                      child: _buildMacro(
                        colors,
                        'Glucides',
                        result.carbs,
                        colors.orange,
                      ),
                    ),
                    Expanded(
                      child: _buildMacro(
                        colors,
                        'Lipides',
                        result.fats,
                        colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _confirmResult,
            style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
            child: Text('Ajouter', style: TextStyle(color: colors.bg)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _rescan, child: const Text('Rescanner')),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => setState(() => _phase = FoodScannerPhase.manual),
            child: Text(
              'Saisie manuelle',
              style: TextStyle(color: colors.muted2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacro(
    FPColorScheme colors,
    String label,
    int grams,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '${grams}g',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: colors.muted2, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildManualPhase(FPColorScheme colors) {
    const presets = [200, 400, 600];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              _manualCalories.isEmpty ? '0' : _manualCalories,
              style: TextStyle(
                color: colors.text,
                fontSize: 52,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'calories',
              style: TextStyle(color: colors.muted2, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: presets.map((preset) {
                return OutlinedButton(
                  onPressed: () =>
                      setState(() => _manualCalories = preset.toString()),
                  child: Text('$preset'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.6,
              children: [
                for (final digit in [
                  '1',
                  '2',
                  '3',
                  '4',
                  '5',
                  '6',
                  '7',
                  '8',
                  '9',
                  '',
                  '0',
                  '⌫',
                ])
                  digit.isEmpty
                      ? const SizedBox()
                      : _buildNumpadKey(colors, digit),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canConfirmManualEntry ? _confirmManualEntry : null,
                style: ElevatedButton.styleFrom(backgroundColor: colors.accent),
                child: Text('Ajouter', style: TextStyle(color: colors.bg)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumpadKey(FPColorScheme colors, String digit) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
        child: ElevatedButton(
          onPressed: () => _numpadTap(digit),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.surface2,
            foregroundColor: colors.text,
          ),
          child: Text(
            digit,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedPhase(FPColorScheme colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.green.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: colors.green, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'Repas enregistré !',
            style: TextStyle(
              color: colors.text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
