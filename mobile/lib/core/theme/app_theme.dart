import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FPColors.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FPColors.accent,
        brightness: Brightness.dark,
        surface: FPColors.surface,
      ),
      extensions: const [FPColorScheme.dark],
    );
  }

  static ThemeData get light {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: FPColors.lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: FPColors.accent,
        brightness: Brightness.light,
        surface: FPColors.lightSurface,
      ),
      extensions: const [FPColorScheme.light],
    );
  }
}
