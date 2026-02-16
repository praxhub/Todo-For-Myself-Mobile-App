import 'package:flutter/material.dart';

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({
    super.key,
    required this.isDark,
    required this.onPressed,
  });

  final bool isDark;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.nights_stay_rounded : Icons.wb_sunny_rounded,
          key: ValueKey(isDark),
        ),
      ),
      tooltip: 'Toggle theme',
    );
  }
}
