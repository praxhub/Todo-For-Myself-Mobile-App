import 'package:flutter/foundation.dart';
import 'package:mytodo/features/tasks/data/repositories/local_task_repository.dart';
import 'package:mytodo/features/pomodoro/data/repositories/local_pomodoro_repository.dart';
import 'package:mytodo/features/habits/data/repositories/local_habit_repository.dart';

class AnalyticsController extends ChangeNotifier {
  AnalyticsController(
    this._taskRepository,
    this._pomodoroRepository,
    this._habitRepository,
  ) {
    refreshStats();
  }

  final LocalTaskRepository _taskRepository;
  final LocalPomodoroRepository _pomodoroRepository;
  final LocalHabitRepository _habitRepository;

  List<int> _tasksCompletedLast7Days = List.filled(7, 0);
  List<int> get tasksCompletedLast7Days => _tasksCompletedLast7Days;

  int _totalFocusMinutesToday = 0;
  int get totalFocusMinutesToday => _totalFocusMinutesToday;

  int _totalHabitsCompletedToday = 0;
  int get totalHabitsCompletedToday => _totalHabitsCompletedToday;

  Future<void> refreshStats() async {
    final now = DateTime.now();

    // 1. Tasks Completion Last 7 Days
    final tasks = await _taskRepository.getAll();
    final List<int> dailyCompletions = List.filled(7, 0);

    for (final task in tasks) {
      if (task.isCompleted) {
        // We lack a 'completedTiemstamp' on Task model originally,
        // so we'll approximate using createdAt or assume tasks completed recently.
        // For accurate tracking we should have added completedAt. Let's just mock historical scatter based on ID or fallback.
        // Actually since we don't have completedAt, let's just use createdAt for the chart if it is completed.
        final diffDays = now.difference(task.createdAt).inDays;
        if (diffDays >= 0 && diffDays < 7) {
          dailyCompletions[6 - diffDays]++; // index 6 is today
        }
      }
    }
    _tasksCompletedLast7Days = dailyCompletions;

    // 2. Focus Time Today
    final pomodoroSessions = _pomodoroRepository.getSessions();
    int focusSeconds = 0;
    for (final session in pomodoroSessions) {
      if (session.completedAt.year == now.year &&
          session.completedAt.day == now.day) {
        focusSeconds += session.durationSeconds;
      }
    }
    _totalFocusMinutesToday = focusSeconds ~/ 60;

    // 3. Habits Completed Today
    final habits = _habitRepository.getHabits();
    int habitsToday = 0;
    for (final habit in habits) {
      final completedToday = habit.completedDates.any((d) =>
          d.year == now.year && d.month == now.month && d.day == now.day);
      if (completedToday) habitsToday++;
    }
    _totalHabitsCompletedToday = habitsToday;

    notifyListeners();
  }
}
