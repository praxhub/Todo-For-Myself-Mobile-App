import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mytodo/features/daily_notes/domain/models/daily_note.dart';
import 'package:mytodo/features/tasks/domain/models/task.dart';
import 'package:mytodo/features/pomodoro/domain/models/pomodoro_session.dart';
import 'package:mytodo/features/habits/domain/models/habit.dart';

class HiveBoxes {
  static const String tasks = 'tasks';
  static const String dailyNotes = 'daily_notes';
  static const String metadata = 'metadata';
  static const String pomodoroSessions = 'pomodoro_sessions';
  static const String habits = 'habits';
}

class AppSchema {
  static const int currentVersion = 2;
  static const String schemaVersionKey = 'schema_version';
}

typedef MigrationStep = Future<void> Function();

class HiveMigrationManager {
  HiveMigrationManager(this._metadataBox);

  final Box<dynamic> _metadataBox;

  Future<void> migrateToLatest({
    required int latestVersion,
    required Map<int, MigrationStep> migrations,
  }) async {
    final int currentVersion =
        (_metadataBox.get(AppSchema.schemaVersionKey) as int?) ?? 0;

    if (currentVersion >= latestVersion) {
      return;
    }

    for (int nextVersion = currentVersion + 1;
        nextVersion <= latestVersion;
        nextVersion++) {
      final MigrationStep? step = migrations[nextVersion];
      if (step != null) {
        await step();
      }
      await _metadataBox.put(AppSchema.schemaVersionKey, nextVersion);
    }
  }
}

class HiveDatabase {
  HiveDatabase._();

  static Future<void>? _initializationFuture;

  static Future<void> initialize() {
    _initializationFuture ??= _initializeInternal();
    return _initializationFuture!;
  }

  static Future<void> _initializeInternal() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    _registerAdapters();

    final metadataBox = await Hive.openBox<dynamic>(HiveBoxes.metadata);

    final migrationManager = HiveMigrationManager(metadataBox);
    await migrationManager.migrateToLatest(
      latestVersion: AppSchema.currentVersion,
      migrations: <int, MigrationStep>{
        1: () async {
          if (!Hive.isBoxOpen(HiveBoxes.tasks)) {
            await Hive.openBox<Task>(HiveBoxes.tasks);
          }
          if (!Hive.isBoxOpen(HiveBoxes.dailyNotes)) {
            await Hive.openBox<DailyNote>(HiveBoxes.dailyNotes);
          }
        },
        2: () async {
          if (!Hive.isBoxOpen(HiveBoxes.pomodoroSessions)) {
            await Hive.openBox<PomodoroSession>(HiveBoxes.pomodoroSessions);
          }
          if (!Hive.isBoxOpen(HiveBoxes.habits)) {
            await Hive.openBox<Habit>(HiveBoxes.habits);
          }
        },
      },
    );

    if (!Hive.isBoxOpen(HiveBoxes.tasks)) {
      await Hive.openBox<Task>(HiveBoxes.tasks);
    }
    if (!Hive.isBoxOpen(HiveBoxes.dailyNotes)) {
      await Hive.openBox<DailyNote>(HiveBoxes.dailyNotes);
    }
    if (!Hive.isBoxOpen(HiveBoxes.pomodoroSessions)) {
      await Hive.openBox<PomodoroSession>(HiveBoxes.pomodoroSessions);
    }
    if (!Hive.isBoxOpen(HiveBoxes.habits)) {
      await Hive.openBox<Habit>(HiveBoxes.habits);
    }
  }

  static Box<Task> tasksBox() {
    if (!Hive.isBoxOpen(HiveBoxes.tasks)) {
      throw StateError(
          'Tasks box is not open. Call HiveDatabase.initialize() first.');
    }
    return Hive.box<Task>(HiveBoxes.tasks);
  }

  static Box<DailyNote> dailyNotesBox() {
    if (!Hive.isBoxOpen(HiveBoxes.dailyNotes)) {
      throw StateError(
          'Daily notes box is not open. Call HiveDatabase.initialize() first.');
    }
    return Hive.box<DailyNote>(HiveBoxes.dailyNotes);
  }

  static Box<PomodoroSession> pomodoroSessionsBox() {
    if (!Hive.isBoxOpen(HiveBoxes.pomodoroSessions)) {
      throw StateError(
          'Pomodoro sessions box is not open. Call HiveDatabase.initialize() first.');
    }
    return Hive.box<PomodoroSession>(HiveBoxes.pomodoroSessions);
  }

  static Box<Habit> habitsBox() {
    if (!Hive.isBoxOpen(HiveBoxes.habits)) {
      throw StateError(
          'Habits box is not open. Call HiveDatabase.initialize() first.');
    }
    return Hive.box<Habit>(HiveBoxes.habits);
  }

  static void _registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(DailyNoteAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(HabitAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(PomodoroSessionAdapter());
    }
  }
}
