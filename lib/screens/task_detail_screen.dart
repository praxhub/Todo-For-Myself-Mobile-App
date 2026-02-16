import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final task = state.getTask(taskId);

    if (task == null) {
      return const Scaffold(body: Center(child: Text('Task not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Detail'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/task-form', arguments: task.id),
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              await state.deleteTask(task.id);
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(task.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(task.description),
          const SizedBox(height: 8),
          Text('Due: ${DateFormat.yMMMd().add_jm().format(task.dueDate)}'),
          const SizedBox(height: 16),
          if (task.imagePath != null)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => FullscreenImageScreen(path: task.imagePath!),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(File(task.imagePath!), height: 220, fit: BoxFit.cover),
              ),
            ),
          if (task.voiceNotePath != null)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Icon(Icons.audio_file),
                  SizedBox(width: 8),
                  Expanded(child: Text('Voice note attached (play from edit screen).')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FullscreenImageScreen extends StatelessWidget {
  const FullscreenImageScreen({super.key, required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white),
      body: Center(child: InteractiveViewer(child: Image.file(File(path)))),
    );
  }
}
