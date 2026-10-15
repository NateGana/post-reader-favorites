import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// AppBar button that switches between light and dark mode.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = AppColors.isDark(context);
    return IconButton(
      tooltip: dark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () {
        themeModeNotifier.value = dark ? ThemeMode.light : ThemeMode.dark;
      },
    );
  }
}
