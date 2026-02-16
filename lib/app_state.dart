import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/journal_entry.dart';
import 'models/task.dart';

class AppState extends ChangeNotifier {
  static const _tasksKey = 'tasks';
  static const _journalsKey = 'journals';
  static const _themeKey = 'theme_mode';
  static const _todayWidgetCountKey = 'today_task_count';

  final List<Task> _tasks = [];
  final Map<String, JournalEntry> _journals = {};
  ThemeMode _themeMode = ThemeMode.system;

  List<Task> get tasks => List.unmodifiable(_tasks)..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  Map<String, JournalEntry> get journals => Map.unmodifiable(_journals);

  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final rawTasks = prefs.getString(_tasksKey);
    if (rawTasks != null && rawTasks.isNotEmpty) {
      _tasks
        ..clear()
        ..addAll(Task.decode(rawTasks));
    }

    final rawJournals = prefs.getString(_journalsKey);
    if (rawJournals != null && rawJournals.isNotEmpty) {
      _journals
        ..clear()
        ..addAll(JournalEntry.decode(rawJournals));
    }

    final theme = prefs.getString(_themeKey);
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (theme == 'light') {
      _themeMode = ThemeMode.light;
    }

    notifyListeners();
    _syncTodayWidgetCount();
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _persistTasks();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((item) => item.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
      await _persistTasks();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _persistTasks();
  }

  Task? getTask(String taskId) {
    try {
      return _tasks.firstWhere((task) => task.id == taskId);
    } catch (_) {
      return null;
    }
  }

  List<Task> tasksForDate(DateTime date) {
    final key = DateFormat('yyyy-MM-dd').format(date);
    return _tasks.where((task) => DateFormat('yyyy-MM-dd').format(task.dueDate) == key).toList();
  }

  bool hasTasksOn(DateTime date) => tasksForDate(date).isNotEmpty;

  String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  JournalEntry? journalForDate(DateTime date) => _journals[dateKey(date)];

  Future<void> saveJournal({required DateTime date, required String content, String? imagePath}) async {
    final key = dateKey(date);
    _journals[key] = JournalEntry(dateKey: key, content: content, imagePath: imagePath);
    await _persistJournals();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, _themeMode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> _persistTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tasksKey, Task.encode(_tasks));
    notifyListeners();
    await _syncTodayWidgetCount();
  }

  Future<void> _persistJournals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_journalsKey, JournalEntry.encode(_journals));
    notifyListeners();
  }

  Future<void> _syncTodayWidgetCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = tasksForDate(DateTime.now()).length;
    await prefs.setInt(_todayWidgetCountKey, count);
  }
}
