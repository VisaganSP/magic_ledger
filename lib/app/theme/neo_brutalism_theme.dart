import 'package:flutter/material.dart';

class NeoBrutalismTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color accentYellow = Color(0xFFFFD93D);
  static const Color accentPink = Color(0xFFFF6BC6);
  static const Color accentBlue = Color(0xFF6BCFFF);
  static const Color accentGreen = Color(0xFF6BFF6B);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPurple = Color(0xFFA06BFF);

  static const double borderWidth = 3.0;
  static const double shadowOffset = 5.0;

  static BoxDecoration neoBox({
    Color color = primaryWhite,
    Color borderColor = primaryBlack,
    double offset = shadowOffset,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(color: borderColor, offset: Offset(offset, offset)),
      ],
    );
  }

  static BoxDecoration neoBoxRounded({
    Color color = primaryWhite,
    Color borderColor = primaryBlack,
    double offset = shadowOffset,
    double radius = 12,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(color: borderColor, offset: Offset(offset, offset)),
      ],
    );
  }
}
