import 'package:hive/hive.dart';
import 'package:mytodo/features/pomodoro/domain/models/pomodoro_session.dart';

class LocalPomodoroRepository {
  LocalPomodoroRepository(this._box);

  final Box<PomodoroSession> _box;

  List<PomodoroSession> getSessions() {
    return _box.values.toList().cast<PomodoroSession>();
  }

  Future<void> addSession(PomodoroSession session) async {
    await _box.put(session.id, session);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
