import 'package:flutter/material.dart';

/// FitnessPro Design Tokens - Colors
/// Dark theme as primary (design provided dark mode)
class FPColors {
  // Primary palette
  static const Color bg = Color(0xFF0C0C14); // Dark background
  static const Color surface = Color(0xFF141420); // Card surface
  static const Color surface2 = Color(0xFF1C1C2A); // Secondary surface (inputs, elements)
  static const Color border = Color(0xFF252538); // Borders, separators

  // Accent & Actions
  static const Color accent = Color(0xFFC1FF4D); // Lime green (primary action)
  static const Color orange = Color(0xFFFF6B35); // Orange (calories, alerts)
  static const Color text = Color(0xFFF0F0F8); // Primary text
  static const Color muted = Color(0xFF5A5A78); // Muted text (disabled)
  static const Color muted2 = Color(0xFF8A8AAA); // Secondary muted

  // Status colors
  static const Color red = Color(0xFFFF4F4F); // Error, danger
  static const Color green = Color(0xFF4ADE80); // Success, validation
  static const Color blue = Color(0xFF60A5FA); // Hydration, info
  static const Color purple = Color(0xFFA78BFA); // IA, special elements

  // Semantic opacity colors
  static const Color accentTint18 = Color(0x18C1FF4D); // accent @ 10% opacity
  static const Color accentTint44 = Color(0x44C1FF4D); // accent @ 27% opacity
  static const Color accentTint22 = Color(0x22C1FF4D); // accent @ 13% opacity

  static const Color surface22 = Color(0x22141420); // surface @ 13% opacity
  static const Color redTint18 = Color(0x18FF4F4F); // red @ 10% opacity
  static const Color redTint33 = Color(0x33FF4F4F); // red @ 20% opacity
  static const Color greenTint22 = Color(0x224ADE80); // green @ 13% opacity

  // Light theme (complementary, derived)
  static const Color lightBg = Color(0xFFFAFAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF0C0C14);
}
