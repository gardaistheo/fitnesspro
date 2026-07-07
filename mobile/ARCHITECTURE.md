# Architecture Mobile — FitnessPro Flutter

## Pattern : MVVM + Provider

L'architecture suit le pattern **MVVM (Model-View-ViewModel)** avec **Provider** pour la gestion d'état.

### Structure des répertoires

```
lib/
├── core/
│   ├── constants/
│   │   └── colors.dart          # Design tokens (couleurs FP)
│   └── theme/
│       └── app_theme.dart       # ThemeData light + dark
│
├── models/                      # Entités métier
│   ├── user_model.dart
│   ├── exercise_model.dart
│   ├── program_model.dart
│   ├── meal_model.dart
│   └── workout_session_model.dart
│
├── services/                    # Logique métier centralisée
│   ├── api_service.dart         # Client HTTP Sanctum
│   ├── storage_service.dart     # SharedPreferences wrapper
│   └── (autres services métier)
│
├── providers/                   # ViewModels avec ChangeNotifier
│   ├── auth_provider.dart
│   ├── exercise_provider.dart
│   ├── program_provider.dart
│   ├── meal_provider.dart
│   ├── workout_session_provider.dart
│   └── theme_provider.dart
│
├── screens/                     # Écrans UI (View)
│   ├── landing/
│   │   └── landing_screen.dart
│   ├── signup/
│   │   └── signup_screen.dart
│   ├── quiz/
│   │   └── quiz_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   └── (autres écrans...)
│
├── widgets/                     # Composants réutilisables
│   ├── fp_button.dart
│   ├── fp_card.dart
│   ├── progress_bar.dart
│   └── (autres widgets...)
│
└── main.dart                    # Entry point
```

## Flux de données

```
User Action (tap, input)
  ↓
UI (Screen) appelle Provider method
  ↓
Provider (ChangeNotifier) appelle Service (ApiService, StorageService)
  ↓
Service communique avec API / Storage
  ↓
Service retourne result
  ↓
Provider met à jour son état (notifyListeners())
  ↓
UI se rebui automatiquement
```

## Exemple : Flow Authentification

1. **Screen** (LoginScreen) → tap CTA → appelle `authProvider.login(email, password)`
2. **Provider** (AuthProvider) :
   - Valide entrées localement
   - Appelle `ApiService.post('/auth/login', {email, password})`
   - Reçoit token + user data
   - Sauvegarde token avec `StorageService.saveToken()`
   - Met à jour `_user = User.fromJson(data)`
   - Appelle `notifyListeners()` → Screen se rebui
3. **Service** (ApiService) : HTTP request avec headers corrects
4. **Persistence** (StorageService) : Sauvegarde token dans SharedPreferences

## Conventions de nommage

- **Models** : PascalCase singulier (User, Exercise, Program)
- **Providers** : PascalCase + "Provider" (AuthProvider, ExerciseProvider)
- **Services** : PascalCase + "Service" (ApiService, StorageService)
- **Screens** : PascalCase + "Screen" (LoginScreen, DashboardScreen)
- **Widgets** : PascalCase + "Widget" ou "Button" (FPCard, FPButton)
- **Variables** : camelCase (currentUser, isLoading, exerciseList)
- **Constants** : camelCase ou PascalCase selon usage (apiTimeout, FPColors)

## State Management

### Étapes pour ajouter une feature

1. **Créer Model** : définir structure de données
   ```dart
   class Exercise {
     final int id;
     final String name;
     // ...
   }
   ```

2. **Créer Service** : logique API / persistence
   ```dart
   class ExerciseService {
     Future<List<Exercise>> fetchExercises() async { ... }
   }
   ```

3. **Créer Provider** : state + logique business
   ```dart
   class ExerciseProvider extends ChangeNotifier {
     List<Exercise> _exercises = [];
     
     Future<void> loadExercises() async {
       _exercises = await exerciseService.fetchExercises();
       notifyListeners(); // ← IMPORTANT
     }
   }
   ```

4. **Utiliser dans Screen** :
   ```dart
   final exerciseProvider = Provider.of<ExerciseProvider>(context);
   
   onPressed: () => exerciseProvider.loadExercises()
   ```

## Testing

### Structure des tests

```
test/
├── models/
│   └── user_model_test.dart     # Test parsing JSON
├── providers/
│   └── auth_provider_test.dart  # Test login/register logic
└── widgets/
    └── fp_button_test.dart      # Test widget rendering
```

### Exemple test Provider

```dart
test('AuthProvider.login updates user on success', () async {
  final mockApiService = MockApiService();
  when(mockApiService.post(...)).thenAnswer((_) async => {
    'data': {'token': 'abc123', 'user': {...}}
  });
  
  final provider = AuthProvider(
    apiService: mockApiService,
    storageService: MockStorageService(),
  );
  
  await provider.login('test@test.com', 'password');
  
  expect(provider.user?.email, 'test@test.com');
  expect(provider.isAuthenticated, true);
});
```

## Best Practices

1. **Providers** : toujours appeler `notifyListeners()` après mutation d'état
2. **ApiService** : centraliser TOUS les appels HTTP
3. **Error handling** : afficher erreurs dans l'UI via `provider.error` et `provider.isLoading`
4. **Persistence** : sauvegarder token/user data dans StorageService
5. **Performance** : utiliser `Consumer` ou `Selector` pour limiter rebuilds
6. **Cleanup** : implémenter `dispose()` si besoin (timers, listeners)

## Ressources

- [Provider package docs](https://pub.dev/packages/provider)
- [Flutter Architecture](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
- [FitnessPro Design Reference](../project/design_handoff_fitnesspro/README.md)
