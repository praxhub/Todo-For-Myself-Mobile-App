import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_item.dart';
import '../data/database_helper.dart';

final taskDatabaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final tasksProvider = NotifierProvider<TaskNotifier, List<TaskItem>>(() {
  return TaskNotifier();
});

class TaskNotifier extends Notifier<List<TaskItem>> {
  @override
  List<TaskItem> build() {
    loadTasks();
    return [];
  }

  Future<void> loadTasks() async {
    final dbHelper = ref.read(taskDatabaseProvider);
    final tasks = await dbHelper.readAllTasks();
    state = tasks;
  }

  Future<void> addTask(TaskItem task) async {
    final dbHelper = ref.read(taskDatabaseProvider);
    await dbHelper.insertTask(task);
    await loadTasks();
  }

  Future<void> toggleTaskCompletion(TaskItem task) async {
    final dbHelper = ref.read(taskDatabaseProvider);
    final updatedTask = TaskItem(
      id: task.id,
      task: task.task,
      dueDate: task.dueDate,
      linkedTransactionId: task.linkedTransactionId,
      isCompleted: !task.isCompleted,
    );
    await dbHelper.updateTask(updatedTask);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    final dbHelper = ref.read(taskDatabaseProvider);
    await dbHelper.deleteTask(id);
    await loadTasks();
  }
}
