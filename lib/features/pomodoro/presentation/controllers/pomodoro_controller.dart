import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:mytodo/features/tasks/domain/models/task.dart';
import 'package:mytodo/features/tasks/presentation/controllers/task_controller.dart';
import 'package:mytodo/features/pomodoro/data/repositories/local_pomodoro_repository.dart';
import 'package:mytodo/features/pomodoro/domain/models/pomodoro_session.dart';

enum PomodoroMode { focus, shortBreak, longBreak }

class PomodoroController extends ChangeNotifier {
  PomodoroController(this._repository, this._taskController) {
    _loadSessions();
  }

  final LocalPomodoroRepository _repository;
  final TaskController _taskController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<PomodoroSession> _sessions = [];
  List<PomodoroSession> get sessions => _sessions;

  PomodoroMode _currentMode = PomodoroMode.focus;
  PomodoroMode get currentMode => _currentMode;

  static const int focusDuration = 25 * 60;
  static const int shortBreakDuration = 5 * 60;
  static const int longBreakDuration = 15 * 60;

  int _timeRemaining = focusDuration;
  int get timeRemaining => _timeRemaining;

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Timer? _timer;
  Task? _linkedTask;
  Task? get linkedTask => _linkedTask;

  void _loadSessions() {
    _sessions = _repository.getSessions();
    notifyListeners();
  }

  void linkTask(Task task) {
    _linkedTask = task;
    notifyListeners();
  }

  void unlinkTask() {
    _linkedTask = null;
    notifyListeners();
  }

  void setMode(PomodoroMode mode) {
    _currentMode = mode;
    _isRunning = false;
    _timer?.cancel();
    switch (mode) {
      case PomodoroMode.focus:
        _timeRemaining = focusDuration;
        break;
      case PomodoroMode.shortBreak:
        _timeRemaining = shortBreakDuration;
        break;
      case PomodoroMode.longBreak:
        _timeRemaining = longBreakDuration;
        break;
    }
    notifyListeners();
  }

  void toggleTimer() {
    if (_isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  void startTimer() {
    if (_timeRemaining > 0) {
      _isRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeRemaining > 0) {
          _timeRemaining--;
          notifyListeners();
        } else {
          _completeSession();
        }
      });
      notifyListeners();
    }
  }

  void pauseTimer() {
    _isRunning = false;
    _timer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    setMode(_currentMode);
  }

  Future<void> _completeSession() async {
    _isRunning = false;
    _timer?.cancel();

    // Play an alarm sound
    try {
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
    } catch (_) {
      SystemSound.play(SystemSoundType.alert);
    }

    if (_currentMode == PomodoroMode.focus) {
      final session = PomodoroSession(
        id: const Uuid().v4(),
        durationSeconds: focusDuration,
        completedAt: DateTime.now(),
        taskId: _linkedTask?.id,
      );
      await _repository.addSession(session);
      _sessions.add(session);

      if (_linkedTask != null) {
        final updatedTask = _linkedTask!.copyWith(
          timeSpentSeconds: _linkedTask!.timeSpentSeconds + focusDuration,
        );
        await _taskController.updateTask(updatedTask);
      }
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
