import 'package:flutter/material.dart';

/// Current theme mode. Changing it rebuilds the whole app (see main.dart).
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.dark);

/// The colors used across all screens.
class AppColors {
  static const Color accentDeep = Color(0xFF00796B); // buttons in light mode
  static const Color accentSoft = Color(0xFF5EEAD4); // buttons in dark mode

  static const Color navy = Color(0xFF0A1A1C);
  static const Color navyCard = Color(0xFF11292C);
  static const Color navyBorder = Color(0xFF1E464A);

  static const Color paper = Color(0xFFF1F8F7);
  static const Color paperBorder = Color(0xFFD3E5E3);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color card(BuildContext context) =>
      isDark(context) ? navyCard : Colors.white;

  static Color border(BuildContext context) =>
      isDark(context) ? navyBorder : paperBorder;

  /// Softer text color for secondary information.
  static Color muted(BuildContext context) =>
      isDark(context) ? const Color(0xFF9BBEBE) : const Color(0xFF4A6767);
}

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accentDeep,
      brightness: brightness,
    ).copyWith(
      primary: dark ? AppColors.accentSoft : AppColors.accentDeep,
      onPrimary: dark ? AppColors.navy : Colors.white,
      surface: dark ? AppColors.navy : AppColors.paper,
      onSurface: dark ? const Color(0xFFE6F4F2) : const Color(0xFF12302F),
    );

    final baseText = ThemeData(brightness: brightness, useMaterial3: true)
        .textTheme
        .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    final textTheme = baseText.copyWith(
      headlineSmall: baseText.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        height: 1.25,
      ),
      titleLarge: baseText.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      titleMedium: baseText.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge: baseText.bodyLarge?.copyWith(height: 1.65),
      bodyMedium: baseText.bodyMedium?.copyWith(height: 1.45),
    );

    final border = dark ? AppColors.navyBorder : AppColors.paperBorder;
    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 22),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? AppColors.navyCard : Colors.white,
        border: inputBorder(border),
        enabledBorder: inputBorder(border),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            dark ? const Color(0xFF1E464A) : const Color(0xFF12302F),
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: AppColors.accentSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerColor: border,
    );
  }
}
