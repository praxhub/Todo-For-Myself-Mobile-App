import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:mytodo/features/habits/data/repositories/local_habit_repository.dart';
import 'package:mytodo/features/habits/domain/models/habit.dart';

class HabitController extends ChangeNotifier {
  HabitController(this._repository) {
    loadHabits();
  }

  final LocalHabitRepository _repository;

  List<Habit> _habits = [];
  List<Habit> get habits => _habits;

  void loadHabits() {
    _habits = _repository.getHabits();
    notifyListeners();
  }

  Future<void> addHabit(String title, String colorHex) async {
    final habit = Habit(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      colorHex: colorHex,
    );
    await _repository.addHabit(habit);
    _habits.add(habit);
    notifyListeners();
  }

  Future<void> toggleHabitCompletion(String id, DateTime date) async {
    final index = _habits.indexWhere((h) => h.id == id);
    if (index == -1) return;

    final habit = _habits[index];
    final dateOnly = DateTime(date.year, date.month, date.day);

    final completedDates = List<DateTime>.from(habit.completedDates);

    final existingIndex = completedDates.indexWhere((d) =>
        d.year == dateOnly.year &&
        d.month == dateOnly.month &&
        d.day == dateOnly.day);

    if (existingIndex != -1) {
      completedDates.removeAt(existingIndex);
    } else {
      completedDates.add(dateOnly);
    }

    final updatedHabit = habit.copyWith(completedDates: completedDates);
    await _repository.updateHabit(updatedHabit);

    _habits[index] = updatedHabit;
    notifyListeners();
  }

  Future<void> deleteHabit(String id) async {
    await _repository.deleteHabit(id);
    _habits.removeWhere((h) => h.id == id);
    notifyListeners();
  }

  bool isCompletedOnDate(Habit habit, DateTime date) {
    return habit.completedDates.any((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
  }

  int calculateStreak(Habit habit) {
    if (habit.completedDates.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();
    currentDate =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Check if missed today, but maybe did it yesterday (streak is still alive)
    bool hasToday = isCompletedOnDate(habit, currentDate);
    if (!hasToday) {
      final yesterday = currentDate.subtract(const Duration(days: 1));
      if (!isCompletedOnDate(habit, yesterday)) {
        return 0; // Missed yesterday and today
      }
      currentDate = yesterday;
    }

    for (int i = 0; i < 365; i++) {
      // Max lookback
      final dateToCheck = currentDate.subtract(Duration(days: i));
      if (isCompletedOnDate(habit, dateToCheck)) {
        streak++;
      } else {
        break; // Streak broken
      }
    }
    return streak;
  }
}
