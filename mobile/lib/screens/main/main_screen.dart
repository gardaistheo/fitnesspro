import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../exercises/exercises_screen.dart';
import '../food_scanner/food_scanner_screen.dart';
import '../workouts/workouts_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    DashboardScreen(),
    FoodScannerScreen(),
    ExercisesScreen(),
    WorkoutsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.surface,
        selectedItemColor: colors.accent,
        unselectedItemColor: colors.muted2,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Scanner'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Exercices'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Séances'),
        ],
      ),
    );
  }
}
