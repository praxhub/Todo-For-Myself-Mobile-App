import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task_item.dart';

class TaskScreen extends ConsumerWidget {
  const TaskScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        centerTitle: true,
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('All caught up! No pending tasks.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskTile(context, ref, task);
              },
            ),
    );
  }

  Widget _buildTaskTile(BuildContext context, WidgetRef ref, TaskItem task) {
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return ListTile(
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (bool? value) {
          ref.read(tasksProvider.notifier).toggleTaskCompletion(task);
        },
      ),
      title: Text(
        task.task,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : Colors.black87,
        ),
      ),
      subtitle: Text(
        'Due: ${DateFormat('dd MMM yyyy').format(task.dueDate)}',
        style: TextStyle(
          color: isOverdue ? Colors.red : Colors.grey,
          fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.grey),
        onPressed: () {
          ref.read(tasksProvider.notifier).deleteTask(task.id);
        },
      ),
    );
  }
}
