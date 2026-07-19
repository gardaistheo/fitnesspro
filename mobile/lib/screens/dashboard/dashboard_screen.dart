import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../core/constants/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/workout_session_provider.dart';

enum _AccountAction { customerCenter, logout }

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _hydration = 1250; // ml consumed
  final int _caloriesConsumed = 1800;
  final int _caloriesExpended = 500;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutSessionProvider>(
        context,
        listen: false,
      ).loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = FPColorScheme.of(context);

    return Scaffold(
      backgroundColor: colors.bg,
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
                          color: colors.muted2,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mon tableau de bord',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildAccountMenu(context, colors),
                      const SizedBox(width: 4),
                      _buildThemeToggle(context, colors),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.13),
                          border: Border.all(
                            color: colors.accent.withValues(alpha: 0.27),
                          ),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '12 jours',
                              style: TextStyle(
                                color: colors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildStreakCard(colors),
              const SizedBox(height: 12),
              _buildNextWorkoutCard(context, colors),
              const SizedBox(height: 12),
              _buildHydrationCard(colors),
              const SizedBox(height: 12),
              _buildCaloriesCard(context, colors),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, FPColorScheme colors) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    IconData iconFor(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return Icons.light_mode;
        case ThemeMode.dark:
          return Icons.dark_mode;
        case ThemeMode.system:
          return Icons.brightness_auto;
      }
    }

    ThemeMode next(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return ThemeMode.light;
        case ThemeMode.light:
          return ThemeMode.dark;
        case ThemeMode.dark:
          return ThemeMode.system;
      }
    }

    return IconButton(
      icon: Icon(
        iconFor(themeProvider.themeMode),
        color: colors.muted2,
        size: 20,
      ),
      tooltip: 'Changer de thème',
      onPressed: () =>
          themeProvider.setThemeMode(next(themeProvider.themeMode)),
    );
  }

  Widget _buildAccountMenu(BuildContext context, FPColorScheme colors) {
    return PopupMenuButton<_AccountAction>(
      icon: Icon(
        Icons.manage_accounts_outlined,
        color: colors.muted2,
        size: 20,
      ),
      tooltip: 'Mon compte',
      color: colors.surface,
      onSelected: (action) async {
        switch (action) {
          case _AccountAction.customerCenter:
            await RevenueCatUI.presentCustomerCenter();
          case _AccountAction.logout:
            await _logout(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _AccountAction.customerCenter,
          child: Text(
            'Gérer mon abonnement',
            style: TextStyle(color: colors.text),
          ),
        ),
        PopupMenuItem(
          value: _AccountAction.logout,
          child: Text('Se déconnecter', style: TextStyle(color: colors.red)),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final subscriptionProvider = Provider.of<SubscriptionProvider>(
      context,
      listen: false,
    );

    await authProvider.logout();
    await subscriptionProvider.logout();

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _buildStreakCard(FPColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.accent.withValues(alpha: 0.2), colors.surface],
        ),
        border: Border.all(color: colors.accent.withValues(alpha: 0.27)),
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
                  color: colors.muted2,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '12',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const Text('🔥', style: TextStyle(fontSize: 48)),
        ],
      ),
    );
  }

  String _formatSessionDate(DateTime date) {
    const weekdays = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const months = [
      'Jan',
      'Fév',
      'Mar',
      'Avr',
      'Mai',
      'Juin',
      'Juil',
      'Août',
      'Sep',
      'Oct',
      'Nov',
      'Déc',
    ];
    return '${weekdays[date.weekday - 1]} ${date.day} ${months[date.month - 1]}';
  }

  Widget _buildNextWorkoutCard(BuildContext context, FPColorScheme colors) {
    final session = Provider.of<WorkoutSessionProvider>(context).nextSession;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (session == null) ...[
            Text(
              'Aucune séance planifiée',
              style: TextStyle(
                color: colors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ajoute une séance à ton planning pour la voir ici.',
              style: TextStyle(color: colors.muted2, fontSize: 13),
            ),
          ] else ...[
            Text(
              [
                _formatSessionDate(session.scheduledDate),
                if (session.scheduledTime != null) session.scheduledTime,
              ].whereType<String>().join(' · '),
              style: TextStyle(color: colors.muted2, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Text(
              session.program?.name ?? 'Séance',
              style: TextStyle(
                color: colors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (session.program != null) ...[
              const SizedBox(height: 6),
              Text(
                session.program!.muscles.join(', '),
                style: TextStyle(color: colors.muted2, fontSize: 13),
              ),
            ],
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (session?.program?.duration != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${session!.program!.duration} min',
                    style: TextStyle(
                      color: colors.blue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed('/planning');
                },
                icon: const Text('→'),
                label: const Text('Voir le planning'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: colors.accent,
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

  Widget _buildHydrationCard(FPColorScheme colors) {
    const int maxHydration = 2000; // ml/day target
    final progress = (_hydration / maxHydration).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
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
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text('💧', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.surface2,
              valueColor: AlwaysStoppedAnimation(colors.blue),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _hydration += 250),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.blue.withValues(alpha: 0.2),
                  foregroundColor: colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('+250 ml'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _hydration += 500),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.blue.withValues(alpha: 0.2),
                  foregroundColor: colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('+500 ml'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => _hydration = 0),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.blue.withValues(alpha: 0.2),
                  foregroundColor: colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('↺'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesCard(BuildContext context, FPColorScheme colors) {
    const int calorieTarget = 2500;
    final consumed = _caloriesConsumed;
    final expended = _caloriesExpended;
    final remaining = calorieTarget - consumed + expended;
    final progressConsumed = (consumed / calorieTarget).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
        color: colors.surface,
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
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text('🔥', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressConsumed,
              minHeight: 8,
              backgroundColor: colors.surface2,
              valueColor: AlwaysStoppedAnimation(colors.orange),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: colors.surface2,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              children: [
                _buildCalorieDetail(colors, 'Apports', '$consumed kcal'),
                const SizedBox(height: 8),
                _buildCalorieDetail(colors, 'Dépenses', '$expended kcal'),
                const SizedBox(height: 8),
                _buildCalorieDetail(colors, 'Sport', '${expended ~/ 2} kcal'),
                const SizedBox(height: 8),
                Divider(color: colors.border, height: 8),
                const SizedBox(height: 8),
                _buildCalorieDetail(
                  colors,
                  'Restant',
                  '$remaining kcal',
                  accent: true,
                ),
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
                foregroundColor: colors.muted2,
                elevation: 0,
              ),
              child: const Text('📷 Scanner un repas'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieDetail(
    FPColorScheme colors,
    String label,
    String value, {
    bool accent = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: colors.muted2, fontSize: 12)),
        Text(
          value,
          style: TextStyle(
            color: accent ? colors.accent : colors.text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
