import 'package:flutter/material.dart';

class NeoBrutalismTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // Light theme backgrounds
  static const Color lightBackground = Color(
    0xFFFAF8F6,
  ); // Off-white with warm tint
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white for cards
  static const Color lightSecondaryBg = Color(
    0xFFF5F3F0,
  ); // Slightly darker for sections

  // Dark theme backgrounds
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkSecondaryBg = Color(
    0xFF242424,
  ); // Slightly lighter than background
  static const Color darkText = Color(0xFFFFFFFF);

  // Updated with more muted, pastel-like colors based on the reference
  static const Color accentYellow = Color(
    0xFFE8CCFF,
  ); // Softer yellow (was FFD93D) //0xFFE8CCFF
  static const Color accentPink = Color(0xFFFDB5D6); // Pastel pink (was FF6BC6)
  static const Color accentBlue = Color(
    0xFF9DB4FF,
  ); // Soft periwinkle blue (was 6BCFFF)
  static const Color accentGreen = Color(0xFFB8E994); // Mint green (was 6BFF6B)
  static const Color accentOrange = Color(
    0xFFFFB49A,
  ); // Peach/coral (was FF6B35)
  static const Color accentPurple = Color(0xFFFDD663); // Lavender (was A06BFF)

  // Additional muted colors from the reference
  static const Color accentSage = Color(0xFFD4E4D1); // Sage green
  static const Color accentBeige = Color(0xFFF5E6D3); // Warm beige
  static const Color accentSkyBlue = Color(0xFFBFE3F0); // Light sky blue
  static const Color accentLilac = Color(0xFFDCC9E8); // Soft lilac

  // Background colors for cards/sections
  static const Color backgroundPeach = Color(0xFFFFE5D9);
  static const Color backgroundMint = Color(0xFFE0F5E8);
  static const Color backgroundLavender = Color(0xFFF0E6FF);

  static const double borderWidth = 3.0;
  static const double shadowOffset = 5.0;

  // Helper method to get muted colors for dark theme
  static Color getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly darker versions for dark theme
    if (color == accentYellow) {
      return const Color(0xFFD4B94F); // Darker muted yellow
    } else if (color == accentPink) {
      return const Color(0xFFE09BB8); // Darker muted pink
    } else if (color == accentBlue) {
      return const Color(0xFF7A91E0); // Darker muted blue
    } else if (color == accentGreen) {
      return const Color(0xFF8FC976); // Darker muted green
    } else if (color == accentOrange) {
      return const Color(0xFFE09B82); // Darker muted orange
    } else if (color == accentPurple) {
      return const Color(0xFFBFA3E0); // Darker muted purple
    } else if (color == accentSage) {
      return const Color(0xFFB3C4B0); // Darker sage
    } else if (color == accentBeige) {
      return const Color(0xFFD4C5B2); // Darker beige
    } else if (color == accentSkyBlue) {
      return const Color(0xFF9EC2CF); // Darker sky blue
    } else if (color == accentLilac) {
      return const Color(0xFFBBA8C7); // Darker lilac
    }
    return color;
  }

  static BoxDecoration neoBox({
    Color? color,
    Color? borderColor,
    double offset = shadowOffset,
    bool isDark = false,
  }) {
    final defaultColor = isDark ? darkSurface : lightSurface;
    final defaultBorderColor = primaryBlack;

    return BoxDecoration(
      color: color ?? defaultColor,
      border: Border.all(
        color: borderColor ?? defaultBorderColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor ?? defaultBorderColor,
          offset: Offset(offset, offset),
        ),
      ],
    );
  }

  static BoxDecoration neoBoxRounded({
    Color? color,
    Color? borderColor,
    double offset = shadowOffset,
    double radius = 12,
    bool isDark = false,
  }) {
    final defaultColor = isDark ? darkSurface : lightSurface;
    final defaultBorderColor = primaryBlack;

    return BoxDecoration(
      color: color ?? defaultColor,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? defaultBorderColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor ?? defaultBorderColor,
          offset: Offset(offset, offset),
        ),
      ],
    );
  }
}
