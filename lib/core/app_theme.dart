import 'package:flutter/material.dart';

abstract final class Palette {
  static const coral = Color(0xFFFF5355);
  static const pink = Color(0xFFE9BBD5);
  static const ink = Color(0xFF262345);
  static const purple = Color(0xFF3B3577);
  static const muted = Color(0xFFB9B5D0);
  static const cream = Color(0xFFFFEFF8);
  static ThemeData theme(bool dark) {
    final scheme = ColorScheme.fromSeed(
      seedColor: coral,
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: coral,
      secondary: pink,
      surface: dark ? purple : cream,
    );
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? ink : Colors.white,
      fontFamily: '.SF Pro Text',
      useMaterial3: true,
      textTheme: Typography.material2021().englishLike.apply(
        bodyColor: dark ? Colors.white : ink,
        displayColor: dark ? Colors.white : ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(44, 44)),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: coral,
        inactiveTrackColor: dark ? Colors.white24 : Colors.black12,
        thumbColor: Colors.white,
        overlayColor: coral.withValues(alpha: .15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        trackHeight: 2,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: dark ? Colors.white : ink,
        contentTextStyle: TextStyle(color: dark ? ink : Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

extension ThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get panel => isDark ? Palette.purple : Palette.cream;
  Color get muted => isDark ? Palette.muted : const Color(0xFF8A8299);
}
