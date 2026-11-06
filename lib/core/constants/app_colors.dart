import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color forestGreen = Color(0xFF245C43);
  static const Color freshLeafGreen = Color(0xFF68A357);
  static const Color mintGreen = Color(0xFFC8E6C9);
  static const Color warmCream = Color(0xFFFFF8E9);
  static const Color earthBrown = Color(0xFF8D6748);
  static const Color sunriseOrange = Color(0xFFF29D49);
  static const Color skyBlue = Color(0xFF76B9D3);
  static const Color lavender = Color(0xFFA99AD6);
  static const Color coral = Color(0xFFF28B82);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF6F8F2);

  // Neutral Colors
  static const Color textPrimary = Color(0xFF1E2922);
  static const Color textSecondary = Color(0xFF5A6B5C);
  static const Color textMuted = Color(0xFF8C9B8E);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color dividerColor = Color(0xFFE4E9E2);
  static const Color inputFill = Color(0xFFF0F4EC);
  static const Color inputBorder = Color(0xFFD2DDCF);

  // Status Colors
  static const Color statusPending = Color(0xFFF29D49);    // Sunrise Orange
  static const Color statusInProgress = Color(0xFF2980B9); // Rich Sky Blue
  static const Color statusResolved = Color(0xFF43A047);   // Leaf/Success Green
  static const Color statusRejected = Color(0xFFE53935);   // Coral/Red Alert

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [forestGreen, freshLeafGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF1A4532), Color(0xFF2E6F52)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    colors: [Color(0xFFF29D49), Color(0xFFF2B072)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF52A3C4), Color(0xFF76B9D3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [Color(0xFF8F7EC7), Color(0xFFA99AD6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    colors: [Color(0xFFEAF5EE), Color(0xFFF6F8F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
