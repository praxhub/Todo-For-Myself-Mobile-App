import 'package:hive/hive.dart';
import 'package:mytodo/features/habits/domain/models/habit.dart';

class LocalHabitRepository {
  LocalHabitRepository(this._box);

  final Box<Habit> _box;

  List<Habit> getHabits() {
    return _box.values.toList().cast<Habit>();
  }

  Future<void> addHabit(Habit habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> updateHabit(Habit habit) async {
    await _box.put(habit.id, habit);
  }

  Future<void> deleteHabit(String id) async {
    await _box.delete(id);
  }
}
