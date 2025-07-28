import 'package:flutter/material.dart';

import 'neo_brutalism_theme.dart';

class AppTheme {
  static ThemeData neoBrutalismTheme = ThemeData(
    primaryColor: NeoBrutalismTheme.primaryBlack,
    scaffoldBackgroundColor: NeoBrutalismTheme.primaryWhite,
    fontFamily: 'SpaceGrotesk',
    appBarTheme: const AppBarTheme(
      backgroundColor: NeoBrutalismTheme.accentYellow,
      foregroundColor: NeoBrutalismTheme.primaryBlack,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: NeoBrutalismTheme.primaryBlack,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NeoBrutalismTheme.accentPink,
        foregroundColor: NeoBrutalismTheme.primaryBlack,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(
            color: NeoBrutalismTheme.primaryBlack,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        elevation: 0,
      ),
    ),
  );
}
