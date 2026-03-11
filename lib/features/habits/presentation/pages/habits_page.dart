import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/habit_controller.dart';
import 'widgets/add_habit_bottom_sheet.dart';

class HabitsPage extends StatelessWidget {
  const HabitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Habits',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
      ),
      body: Consumer<HabitController>(
        builder: (context, controller, child) {
          final habits = controller.habits;

          if (habits.isEmpty) {
            return Center(
              child: Text(
                "Build better routines!\nTap + to add a habit.",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(duration: 500.ms),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: habits.length,
            itemBuilder: (context, index) {
              final habit = habits[index];
              final isCompletedToday =
                  controller.isCompletedOnDate(habit, DateTime.now());
              final currentStreak = controller.calculateStreak(habit);

              // Simple hex to color parser
              Color parseHex(String hex) {
                var hexColor = hex.toUpperCase().replaceAll('#', '');
                if (hexColor.length == 6) hexColor = 'FF$hexColor';
                return Color(int.parse(hexColor, radix: 16));
              }

              final habitColor = parseHex(habit.colorHex);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isCompletedToday
                      ? habitColor.withValues(alpha: 0.1)
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCompletedToday
                        ? habitColor
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: IconButton(
                    icon: Icon(
                      isCompletedToday
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked,
                      color: habitColor,
                      size: 32,
                    ),
                    onPressed: () {
                      controller.toggleHabitCompletion(
                          habit.id, DateTime.now());
                    },
                  ),
                  title: Text(
                    habit.title,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      decoration:
                          isCompletedToday ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded,
                          color:
                              currentStreak > 0 ? Colors.orange : Colors.grey,
                          size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$currentStreak',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  onLongPress: () {
                    // Show delete confirmation
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title:
                            Text('Delete Habit', style: GoogleFonts.outfit()),
                        content: Text(
                            'Are you sure you want to delete ${habit.title}?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              controller.deleteHabit(habit.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const AddHabitBottomSheet(),
          );
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }
}
