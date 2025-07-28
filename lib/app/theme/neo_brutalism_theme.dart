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

  static BoxDecoration neoBox({
    Color? color,
    Color? borderColor,
    double offset = shadowOffset,
    bool isDark = false,
  }) {
    final defaultColor = isDark ? darkSurface : primaryWhite;
    final defaultBorderColor = isDark ? primaryWhite : primaryBlack;

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
    final defaultBorderColor = isDark ? primaryWhite : primaryBlack;

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
