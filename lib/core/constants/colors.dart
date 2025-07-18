import 'dart:ui';

class AppColors {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF0a7977);
  static const Color secondaryLight = Color.fromARGB(255, 214, 155, 45);
  static const Color backgroundLight = Color(0xFFf0f8f8); // Light grey-blue
  static const Color surfaceLight = Color(0xFFFFFFFF); // White
  static const Color textPrimaryLight = Color.fromARGB(
    255,
    23,
    40,
    88,
  ); // Dark blue from logo
  static const Color textSecondaryLight = Color(0xFF64748B); // Muted blue-grey
  static const Color accentLight = Color(0xFFF4A261); // Coral/orange from logo

  // Dark Theme Colors
  static const Color primaryDark = Color(
    0xFF0a7977,
  ); // Teal/turquoise from logo
  static const Color secondaryDark = Color(0xFFFFBF46); // Yellow/gold from logo
  static const Color backgroundDark = Color(0xFF1A1F2C); // Deep blue-grey
  static const Color surfaceDark = Color(0xFF2D3748); // Lighter blue-grey
  static const Color textPrimaryDark = Color(0xFFF7FAFC); // Off-white
  static const Color textSecondaryDark = Color(0xFFA0AEC0); // Muted grey
  static const Color accentDark = Color(0xFFF4A261); // Coral/orange from logo

  // Universal Colors
  static const Color success = Color.fromARGB(
    255,
    70,
    211,
    115,
  ); // Teal from logo
  static const Color warning = Color(0xFFFFBF46); // Yellow/gold from logo
  static const Color error = Color.fromARGB(
    255,
    227,
    86,
    62,
  ); // Coral/orange from logo
  static const Color info = Color.fromARGB(
    255,
    150,
    158,
    179,
  ); // Dark blue from logo
}
