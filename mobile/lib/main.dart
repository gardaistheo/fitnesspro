import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/exercise_provider.dart';
import 'providers/meal_provider.dart';
import 'providers/program_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/workout_session_provider.dart';
import 'screens/exercises/exercises_screen.dart';
import 'screens/food_scanner/food_scanner_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/main/main_screen.dart';
import 'screens/onboarding/onboarding_slides_screen.dart';
import 'screens/paywall/paywall_screen.dart';
import 'screens/planning/planning_screen.dart';
import 'screens/quiz/quiz_screen.dart';
import 'screens/signup/signup_screen.dart';
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

  final subscriptionProvider = SubscriptionProvider();
  await subscriptionProvider.configure();

  final authProvider = AuthProvider(apiService: apiService, storageService: storageService);
  final hasSession = await authProvider.restoreSession();
  if (hasSession && authProvider.user != null) {
    await subscriptionProvider.login(authProvider.user!.id.toString());
  }

  runApp(FitnessProApp(
    apiService: apiService,
    storageService: storageService,
    themeProvider: themeProvider,
    subscriptionProvider: subscriptionProvider,
    authProvider: authProvider,
    initialRoute: hasSession ? '/dashboard' : '/',
  ));
}

class FitnessProApp extends StatelessWidget {
  final ApiService apiService;
  final StorageService storageService;
  final ThemeProvider themeProvider;
  final SubscriptionProvider subscriptionProvider;
  final AuthProvider authProvider;
  final String initialRoute;

  const FitnessProApp({
    super.key,
    required this.apiService,
    required this.storageService,
    required this.themeProvider,
    required this.subscriptionProvider,
    required this.authProvider,
    this.initialRoute = '/',
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: subscriptionProvider),
        ChangeNotifierProvider.value(value: authProvider),
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
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            initialRoute: initialRoute,
            routes: {
              '/': (context) => const LandingScreen(),
              '/signup': (context) => const SignupScreen(),
              '/login': (context) => const LoginScreen(),
              '/paywall': (context) => PaywallScreen(
                    onSubscribed: () => Navigator.of(context).pushReplacementNamed('/quiz'),
                    onSkip: () => Navigator.of(context).pushReplacementNamed('/quiz'),
                  ),
              '/quiz': (context) => QuizScreen(
                    onDone: (quizData) {
                      final navigator = Navigator.of(context);
                      navigator.pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => OnboardingSlidesScreen(
                            quizData: quizData,
                            onDone: () => navigator.pushReplacementNamed('/dashboard'),
                          ),
                        ),
                      );
                    },
                  ),
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
