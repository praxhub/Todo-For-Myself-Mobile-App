import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mytodo/features/tasks/domain/models/task.dart';
import 'package:mytodo/features/tasks/domain/repositories/task_repository.dart';

import 'package:mytodo/services/notification_service.dart';

class TaskController extends ChangeNotifier {
  TaskController(this._repository) {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      tickActiveTimers();
    });
  }

  final TaskRepository _repository;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final List<Task> _tasks = [];

  List<Task> get tasks => List.unmodifiable(_tasks);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadTasks() async {
    await _runGuarded(() async {
      final loadedTasks = await _repository.getAll();
      _tasks
        ..clear()
        ..addAll(loadedTasks);
      _sortTasks();
    });
  }

  Future<void> addTask(
    String title, {
    DateTime? dueDate,
    bool isOptional = false,
    DateTime? startTime,
    DateTime? endTime,
    String? category,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      _errorMessage = 'Task title cannot be empty.';
      notifyListeners();
      return;
    }

    await _runGuarded(() async {
      final task = Task(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: trimmedTitle,
        isCompleted: false,
        createdAt: DateTime.now(),
        dueDate: dueDate,
        isOptional: isOptional,
        timeSpentSeconds: 0,
        startTime: startTime,
        endTime: endTime,
        timerMilliseconds: 0,
        isRunning: false,
        category: category,
      );

      // Schedule Notifications
      _scheduleTaskNotifications(task);

      // Data flow: UI -> controller -> repository -> Hive.
      await _repository.create(task);
      _tasks.insert(0, task);
      _sortTasks();
    });
  }

  void _scheduleTaskNotifications(Task task) {
    try {
      final baseId =
          int.tryParse(task.id) ?? task.createdAt.millisecondsSinceEpoch;

      if (task.startTime != null && task.startTime!.isAfter(DateTime.now())) {
        NotificationService().scheduleTaskNotification(
          id: (baseId % 100000) * 2,
          title: 'Time to start!',
          body: 'Task: ${task.title}',
          scheduledTime: task.startTime!,
        );
      }

      if (task.endTime != null && task.endTime!.isAfter(DateTime.now())) {
        NotificationService().scheduleTaskNotification(
          id: ((baseId % 100000) * 2) + 1,
          title: 'Task Due Now!',
          body: 'Time is up for: ${task.title}',
          scheduledTime: task.endTime!,
        );
      }
    } catch (e) {
      debugPrint('Failed to schedule notifications: $e');
    }
  }

  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    await _runGuarded(() async {
      final existing = _tasks[index];
      // If completing the task, make sure to stop the timer
      final isNowCompleted = !existing.isCompleted;
      final updated = existing.copyWith(
        isCompleted: isNowCompleted,
        isRunning: isNowCompleted ? false : existing.isRunning,
      );
      await _repository.update(updated);
      _tasks[index] = updated;
      _sortTasks();
    }, showLoader: false);
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index == -1) return;

    await _runGuarded(() async {
      await _repository.update(updatedTask);
      _tasks[index] = updatedTask;
      _sortTasks();
    }, showLoader: false);
  }

  Future<void> toggleTimer(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) return;

    final existing = _tasks[index];
    if (existing.isCompleted) return; // Cannot time a completed task

    // Stop all other timers
    for (var i = 0; i < _tasks.length; i++) {
      if (i != index && _tasks[i].isRunning) {
        final pausedTask = _tasks[i];
        final msDelta = pausedTask.lastStartedAt != null
            ? DateTime.now()
                .difference(pausedTask.lastStartedAt!)
                .inMilliseconds
            : 0;

        _tasks[i] = pausedTask.copyWith(
          isRunning: false,
          lastStartedAt: null,
          timerMilliseconds: pausedTask.timerMilliseconds + msDelta,
        );
        _repository.update(_tasks[i]);
      }
    }

    // Toggle the selected timer
    final willRun = !existing.isRunning;
    int updatedMs = existing.timerMilliseconds;
    if (!willRun && existing.lastStartedAt != null) {
      updatedMs +=
          DateTime.now().difference(existing.lastStartedAt!).inMilliseconds;
    }

    final updated = existing.copyWith(
      isRunning: willRun,
      lastStartedAt: willRun ? DateTime.now() : null,
      timerMilliseconds: updatedMs,
    );

    await _repository.update(updated);
    _tasks[index] = updated;
    notifyListeners();
  }

  Future<void> tickActiveTimers() async {
    bool hasChanges = false;
    for (var i = 0; i < _tasks.length; i++) {
      if (_tasks[i].isRunning &&
          !_tasks[i].isCompleted &&
          _tasks[i].lastStartedAt != null) {
        // Only update memory/UI. Do NOT hammer the database 20 times a second.
        final msDelta =
            DateTime.now().difference(_tasks[i].lastStartedAt!).inMilliseconds;
        final prevTotalMs = _tasks[i].timerMilliseconds;

        _tasks[i] = _tasks[i].copyWith(
          timerMilliseconds: prevTotalMs + msDelta,
          lastStartedAt: DateTime.now(), // Reset tick anchor
        );
        hasChanges = true;

        // Periodically sync to Hive just in case of crash (every ~5 seconds)
        if ((_tasks[i].timerMilliseconds ~/ 1000) % 5 == 0 && msDelta > 0) {
          _repository.update(_tasks[i]);
        }
      }
    }
    if (hasChanges) {
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      return;
    }

    await _runGuarded(() async {
      await _repository.delete(id);
      _tasks.removeAt(index);
    }, showLoader: false);
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _runGuarded(
    Future<void> Function() operation, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        _isLoading = true;
      }
      _errorMessage = null;
      notifyListeners();

      await operation();
    } catch (error, stackTrace) {
      _errorMessage = 'Something went wrong. Please try again.';
      debugPrint('Task operation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (showLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      final createdCompare = b.createdAt.compareTo(a.createdAt);
      if (createdCompare != 0) {
        return createdCompare;
      }
      return a.id.compareTo(b.id);
    });
  }
}
