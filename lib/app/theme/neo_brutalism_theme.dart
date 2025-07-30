import 'package:flutter/material.dart';

class NeoBrutalismTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFFFFFFF);

  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentPink = Color(0xFFFF6BC6);
  static const Color accentBlue = Color(0xFF6BCFFF);
  static const Color accentGreen = Color(0xFF6BFF6B);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFFA06BFF);

  static const double borderWidth = 3.0;
  static const double shadowOffset = 5.0;

  // Helper method to get muted colors for dark theme
  static Color getThemedColor(Color color, bool isDark) {
    if (!isDark) return color;

    // Return slightly muted versions of colors for dark theme
    if (color == accentYellow) {
      return Color(0xFFE6B800); // Slightly darker yellow
    } else if (color == accentPink) {
      return Color(0xFFE667A0); // Slightly darker pink
    } else if (color == accentBlue) {
      return Color(0xFF4D94FF); // Slightly darker blue
    } else if (color == accentGreen) {
      return Color(0xFF00CC66); // Slightly darker green
    } else if (color == accentOrange) {
      return Color(0xFFFF8533); // Slightly darker orange
    } else if (color == accentPurple) {
      return Color(0xFF9966FF); // Slightly darker purple
    }
    return color;
  }

  static BoxDecoration neoBox({
    Color? color,
    Color? borderColor,
    double offset = shadowOffset,
    bool isDark = false,
  }) {
    final defaultColor = isDark ? darkSurface : primaryWhite;
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
    final defaultColor = isDark ? darkSurface : primaryWhite;
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
