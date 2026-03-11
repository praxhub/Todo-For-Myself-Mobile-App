import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/pomodoro_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PomodoroPage extends StatelessWidget {
  const PomodoroPage({super.key});

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Focus Mode',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<PomodoroController>(
        builder: (context, controller, child) {
          final isRunning = controller.isRunning;
          final mode = controller.currentMode;
          final timeRemaining = controller.timeRemaining;

          int maxDuration = PomodoroController.focusDuration;
          if (mode == PomodoroMode.shortBreak) {
            maxDuration = PomodoroController.shortBreakDuration;
          }
          if (mode == PomodoroMode.longBreak) {
            maxDuration = PomodoroController.longBreakDuration;
          }

          final progress = 1.0 - (timeRemaining / maxDuration);

          return Column(
            children: [
              const SizedBox(height: 20),
              // Mode Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ModeButton(
                    title: 'Work',
                    isSelected: mode == PomodoroMode.focus,
                    onTap: () => controller.setMode(PomodoroMode.focus),
                  ),
                  _ModeButton(
                    title: 'Short Break',
                    isSelected: mode == PomodoroMode.shortBreak,
                    onTap: () => controller.setMode(PomodoroMode.shortBreak),
                  ),
                  _ModeButton(
                    title: 'Long Break',
                    isSelected: mode == PomodoroMode.longBreak,
                    onTap: () => controller.setMode(PomodoroMode.longBreak),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Timer display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  Text(
                    _formatTime(timeRemaining),
                    style: GoogleFonts.outfit(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ).animate(target: isRunning ? 1 : 0).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.05, 1.05),
                  duration: 2.seconds),
              const SizedBox(height: 40),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 64,
                    icon: Icon(isRunning
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill),
                    color: theme.colorScheme.primary,
                    onPressed: () {
                      controller.toggleTimer();
                    },
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.refresh),
                    color: theme.colorScheme.secondary,
                    onPressed: () {
                      controller.resetTimer();
                    },
                  ),
                ],
              ),
              const Spacer(),
              // Focus History
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Focus',
                      style: GoogleFonts.outfit(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${controller.sessions.length} sessions completed (${_formatTime(controller.sessions.fold(0, (sum, item) => sum + item.durationSeconds))})',
                      style: GoogleFonts.inter(
                          color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
