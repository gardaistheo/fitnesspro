import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _hydration = 1250; // ml consumed
  int _caloriesConsumed = 1800;
  int _caloriesExpended = 500;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FPColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour 👋',
                        style: TextStyle(
                          color: FPColors.muted2,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mon tableau de bord',
                        style: TextStyle(
                          color: FPColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: FPColors.accentTint22,
                      border: Border.all(color: FPColors.accentTint44),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '12 jours',
                          style: TextStyle(
                            color: FPColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Streak Card
              _buildStreakCard(),

              const SizedBox(height: 12),

              // Next Workout Card
              _buildNextWorkoutCard(),

              const SizedBox(height: 12),

              // Hydration Card
              _buildHydrationCard(),

              const SizedBox(height: 12),

              // Calories Card
              _buildCaloriesCard(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FPColors.accent.withOpacity(0.2),
            FPColors.surface,
          ],
        ),
        border: Border.all(color: FPColors.accentTint44),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Streak',
                style: TextStyle(
                  color: FPColors.muted2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '12',
                style: TextStyle(
                  color: FPColors.text,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Text(
            '🔥',
            style: TextStyle(fontSize: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildNextWorkoutCard() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: FPColors.border),
        borderRadius: BorderRadius.circular(16),
        color: FPColors.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lun 7 Juil · 10:00',
            style: TextStyle(
              color: FPColors.muted2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Push Day A',
            style: TextStyle(
              color: FPColors.text,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Poitrine, Épaules, Triceps',
            style: TextStyle(
              color: FPColors.muted2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: FPColors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '45 min',
                  style: TextStyle(
                    color: FPColors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/planning');
                },
                icon: const Text('→'),
                label: const Text('Voir le planning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: FPColors.accent,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationCard() {
    const int maxHydration = 2000; // ml/day target
    final progress = (_hydration / maxHydration).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: FPColors.border),
        borderRadius: BorderRadius.circular(16),
        color: FPColors.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_hydration ml / $maxHydration ml',
                style: TextStyle(
                  color: FPColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '💧',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: FPColors.surface2,
              valueColor: AlwaysStoppedAnimation(FPColors.blue),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _hydration += 250),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FPColors.blue.withOpacity(0.2),
                  foregroundColor: FPColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('+250 ml'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _hydration += 500),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FPColors.blue.withOpacity(0.2),
                  foregroundColor: FPColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('+500 ml'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _hydration = 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FPColors.blue.withOpacity(0.2),
                  foregroundColor: FPColors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('↺'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard() {
    const int calorieTarget = 2500;
    final consumed = _caloriesConsumed;
    final expended = _caloriesExpended;
    final remaining = calorieTarget - consumed + expended;
    final progressConsumed = (consumed / calorieTarget).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: FPColors.border),
        borderRadius: BorderRadius.circular(16),
        color: FPColors.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$consumed kcal / $calorieTarget kcal',
                style: TextStyle(
                  color: FPColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '🔥',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressConsumed,
              minHeight: 8,
              backgroundColor: FPColors.surface2,
              valueColor: AlwaysStoppedAnimation(FPColors.orange),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: FPColors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                _buildCalorieDetail('Apports', '$consumed kcal'),
                const SizedBox(height: 8),
                _buildCalorieDetail('Dépenses', '$expended kcal'),
                const SizedBox(height: 8),
                _buildCalorieDetail('Sport', '${expended ~/ 2} kcal'),
                const SizedBox(height: 8),
                Divider(color: FPColors.border, height: 8),
                const SizedBox(height: 8),
                _buildCalorieDetail('Restant', '$remaining kcal', accent: true),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/food-scanner');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: FPColors.muted2,
                elevation: 0,
              ),
              child: const Text('📷 Scanner un repas'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieDetail(String label, String value, {bool accent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: FPColors.muted2,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: accent ? FPColors.accent : FPColors.text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
