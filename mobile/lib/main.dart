import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'providers/auth_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/program_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_session_provider.dart';
import 'screens/exercises/exercises_screen.dart';
import 'screens/food_scanner/food_scanner_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/planning/planning_screen.dart';
import 'screens/workouts/workouts_screen.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiService = ApiService();
  final savedToken = storageService.getToken();
  if (savedToken != null) {
    apiService.setToken(savedToken);
  }

  final themeProvider = ThemeProvider(storageService: storageService);
  await themeProvider.init();

  runApp(FitnessProApp(
    apiService: apiService,
    storageService: storageService,
    themeProvider: themeProvider,
  ));
}

class FitnessProApp extends StatelessWidget {
  final ApiService apiService;
  final StorageService storageService;
  final ThemeProvider themeProvider;

  const FitnessProApp({
    super.key,
    required this.apiService,
    required this.storageService,
    required this.themeProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(apiService: apiService, storageService: storageService),
        ),
        ChangeNotifierProvider(create: (_) => MealProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => ExerciseProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => ProgramProvider(apiService: apiService)),
        ChangeNotifierProvider(create: (_) => WorkoutSessionProvider(apiService: apiService)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'FitnessPro',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              scaffoldBackgroundColor: FPColors.lightBg,
              colorScheme: ColorScheme.fromSeed(
                seedColor: FPColors.accent,
                brightness: Brightness.light,
              ),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: FPColors.bg,
              colorScheme: ColorScheme.fromSeed(
                seedColor: FPColors.accent,
                brightness: Brightness.dark,
              ),
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => const LandingScreen(),
              '/dashboard': (context) => const MainScreen(),
              '/food-scanner': (context) => const FoodScannerScreen(),
              '/exercises': (context) => const ExercisesScreen(),
              '/workouts': (context) => const WorkoutsScreen(),
              '/planning': (context) => const PlanningScreen(),
            },
          );
        },
      ),
    );
  }
}
