import 'dart:convert';

import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/core/persistence/local_store.dart';

class TaskRepository {
  TaskRepository(this._store);

  static const _storageKey = 'tasks';
  final LocalStore _store;

  Future<List<Task>> loadAll() async {
    final raw = await _store.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <Task>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => Task.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<Task> tasks) async {
    final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());
    await _store.setString(_storageKey, encoded);
  }
}
