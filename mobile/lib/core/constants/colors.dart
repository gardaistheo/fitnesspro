import 'package:flutter/material.dart';

/// FitnessPro Design Tokens - Colors
/// Dark theme as primary (design provided dark mode). These constants remain
/// available directly for call sites not yet migrated to [FPColorScheme];
/// new/updated screens should prefer `FPColorScheme.of(context)` so they
/// follow the active ThemeMode.
class FPColors {
  // Primary palette (dark)
  static const Color bg = Color(0xFF0C0C14);
  static const Color surface = Color(0xFF141420);
  static const Color surface2 = Color(0xFF1C1C2A);
  static const Color border = Color(0xFF252538);

  // Accent & Actions
  static const Color accent = Color(0xFFC1FF4D);
  static const Color orange = Color(0xFFFF6B35);
  static const Color text = Color(0xFFF0F0F8);
  static const Color muted = Color(0xFF5A5A78);
  static const Color muted2 = Color(0xFF8A8AAA);

  // Status colors
  static const Color red = Color(0xFFFF4F4F);
  static const Color green = Color(0xFF4ADE80);
  static const Color blue = Color(0xFF60A5FA);
  static const Color purple = Color(0xFFA78BFA);

  // Semantic opacity colors
  static const Color accentTint18 = Color(0x18C1FF4D);
  static const Color accentTint44 = Color(0x44C1FF4D);
  static const Color accentTint22 = Color(0x22C1FF4D);

  static const Color surface22 = Color(0x22141420);
  static const Color redTint18 = Color(0x18FF4F4F);
  static const Color redTint33 = Color(0x33FF4F4F);
  static const Color greenTint22 = Color(0x224ADE80);

  // Light theme (complementary, derived)
  static const Color lightBg = Color(0xFFFAFAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFF0F0F5);
  static const Color lightBorder = Color(0xFFE2E2EA);
  static const Color lightText = Color(0xFF0C0C14);
  static const Color lightMuted = Color(0xFFA0A0B8);
  static const Color lightMuted2 = Color(0xFF6A6A82);
}

/// Theme-aware color set. Register both light and dark variants as a
/// [ThemeExtension] so widgets can do `FPColorScheme.of(context).bg` and get
/// the correct palette for the active ThemeMode automatically.
@immutable
class FPColorScheme extends ThemeExtension<FPColorScheme> {
  final Color bg;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color accent;
  final Color orange;
  final Color text;
  final Color muted;
  final Color muted2;
  final Color red;
  final Color green;
  final Color blue;
  final Color purple;

  const FPColorScheme({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.accent,
    required this.orange,
    required this.text,
    required this.muted,
    required this.muted2,
    required this.red,
    required this.green,
    required this.blue,
    required this.purple,
  });

  static const dark = FPColorScheme(
    bg: FPColors.bg,
    surface: FPColors.surface,
    surface2: FPColors.surface2,
    border: FPColors.border,
    accent: FPColors.accent,
    orange: FPColors.orange,
    text: FPColors.text,
    muted: FPColors.muted,
    muted2: FPColors.muted2,
    red: FPColors.red,
    green: FPColors.green,
    blue: FPColors.blue,
    purple: FPColors.purple,
  );

  static const light = FPColorScheme(
    bg: FPColors.lightBg,
    surface: FPColors.lightSurface,
    surface2: FPColors.lightSurface2,
    border: FPColors.lightBorder,
    accent: FPColors.accent,
    orange: FPColors.orange,
    text: FPColors.lightText,
    muted: FPColors.lightMuted,
    muted2: FPColors.lightMuted2,
    red: FPColors.red,
    green: FPColors.green,
    blue: FPColors.blue,
    purple: FPColors.purple,
  );

  static FPColorScheme of(BuildContext context) {
    return Theme.of(context).extension<FPColorScheme>() ?? dark;
  }

  @override
  FPColorScheme copyWith({
    Color? bg,
    Color? surface,
    Color? surface2,
    Color? border,
    Color? accent,
    Color? orange,
    Color? text,
    Color? muted,
    Color? muted2,
    Color? red,
    Color? green,
    Color? blue,
    Color? purple,
  }) {
    return FPColorScheme(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      orange: orange ?? this.orange,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      muted2: muted2 ?? this.muted2,
      red: red ?? this.red,
      green: green ?? this.green,
      blue: blue ?? this.blue,
      purple: purple ?? this.purple,
    );
  }

  @override
  FPColorScheme lerp(ThemeExtension<FPColorScheme>? other, double t) {
    if (other is! FPColorScheme) return this;
    return FPColorScheme(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      border: Color.lerp(border, other.border, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      orange: Color.lerp(orange, other.orange, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      muted2: Color.lerp(muted2, other.muted2, t)!,
      red: Color.lerp(red, other.red, t)!,
      green: Color.lerp(green, other.green, t)!,
      blue: Color.lerp(blue, other.blue, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
    );
  }
}
