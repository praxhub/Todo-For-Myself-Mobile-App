import 'package:flutter/material.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/data/repositories/theme_repository.dart';

class TaskApp extends StatefulWidget {
  const TaskApp({
    super.key,
    required this.initialTasks,
    required this.themeRepository,
    DateTime? initialSelectedDate,
  }) : initialSelectedDate = initialSelectedDate ?? DateTime.now();

  final List<Task> initialTasks;
  final ThemeRepository themeRepository;
  final DateTime initialSelectedDate;

  @override
  State<TaskApp> createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  final _controller = TextEditingController();
  late List<Task> _tasks;
  late DateTime _selectedDate;
  bool _onlyToday = false;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _tasks = List<Task>.from(widget.initialTasks);
    _selectedDate = DateTime(
      widget.initialSelectedDate.year,
      widget.initialSelectedDate.month,
      widget.initialSelectedDate.day,
    );
    widget.themeRepository.loadThemeMode().then((value) {
      if (mounted) {
        setState(() => _isDarkMode = value);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Task> get _visibleTasks {
    var filtered = _tasks.where((task) {
      final due = DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day);
      return due == _selectedDate;
    }).toList();

    if (_onlyToday) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      filtered = filtered
          .where((task) =>
              DateTime(task.dueDate.year, task.dueDate.month, task.dueDate.day) ==
              today)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Tasks'),
          actions: [
            Switch(
              key: const Key('theme_toggle'),
              value: _isDarkMode,
              onChanged: (value) async {
                setState(() => _isDarkMode = value);
                await widget.themeRepository.saveThemeMode(value);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('task_input'),
                    controller: _controller,
                  ),
                ),
                ElevatedButton(
                  key: const Key('add_task_button'),
                  onPressed: () {
                    final title = _controller.text.trim();
                    if (title.isEmpty) return;
                    setState(() {
                      _tasks.add(Task(
                        id: '${_tasks.length + 1}',
                        title: title,
                        dueDate: _selectedDate,
                      ));
                    });
                    _controller.clear();
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
            Row(
              children: [
                ElevatedButton(
                  key: const Key('prev_date_button'),
                  onPressed: () {
                    setState(() =>
                        _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                  },
                  child: const Text('Prev'),
                ),
                Text(
                  '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
                  key: const Key('selected_date_label'),
                ),
                ElevatedButton(
                  key: const Key('next_date_button'),
                  onPressed: () {
                    setState(() =>
                        _selectedDate = _selectedDate.add(const Duration(days: 1)));
                  },
                  child: const Text('Next'),
                ),
                Checkbox(
                  key: const Key('today_filter_checkbox'),
                  value: _onlyToday,
                  onChanged: (value) => setState(() => _onlyToday = value ?? false),
                ),
                const Text('Today only'),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _visibleTasks.length,
                itemBuilder: (context, index) {
                  final task = _visibleTasks[index];
                  return ListTile(
                    title: Text(task.title),
                    onTap: () {
                      setState(() {
                        task.title = '${task.title} (edited)';
                      });
                    },
                    trailing: IconButton(
                      key: Key('delete_${task.id}'),
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _tasks.removeWhere((item) => item.id == task.id);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
