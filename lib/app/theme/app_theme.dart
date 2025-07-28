import 'package:flutter/material.dart';

import 'neo_brutalism_theme.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    primaryColor: NeoBrutalismTheme.primaryBlack,
    scaffoldBackgroundColor: NeoBrutalismTheme.primaryWhite,
    fontFamily: 'SpaceGrotesk',
    brightness: Brightness.light,
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
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return NeoBrutalismTheme.primaryBlack;
        }
        return Colors.grey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return NeoBrutalismTheme.accentGreen;
        }
        return Colors.grey[300];
      }),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    primaryColor: NeoBrutalismTheme.primaryWhite,
    scaffoldBackgroundColor: NeoBrutalismTheme.darkBackground,
    fontFamily: 'SpaceGrotesk',
    brightness: Brightness.dark,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: NeoBrutalismTheme.darkText),
      bodyMedium: TextStyle(color: NeoBrutalismTheme.darkText),
      titleLarge: TextStyle(color: NeoBrutalismTheme.darkText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: NeoBrutalismTheme.accentPurple,
      foregroundColor: NeoBrutalismTheme.primaryWhite,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: NeoBrutalismTheme.primaryWhite,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: NeoBrutalismTheme.accentOrange,
        foregroundColor: NeoBrutalismTheme.primaryWhite,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: const BorderSide(
            color: NeoBrutalismTheme.primaryWhite,
            width: NeoBrutalismTheme.borderWidth,
          ),
        ),
        elevation: 0,
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return NeoBrutalismTheme.primaryWhite;
        }
        return Colors.grey[600];
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return NeoBrutalismTheme.accentGreen;
        }
        return Colors.grey[700];
      }),
    ),
  );
}
