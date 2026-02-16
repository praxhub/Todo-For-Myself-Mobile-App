import 'package:flutter_test/flutter_test.dart';
import 'package:todo_for_myself_mobile_app/features/daily_notes/domain/models/daily_note.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/core/persistence/local_store.dart';
import 'package:todo_for_myself_mobile_app/features/daily_notes/data/repositories/daily_note_repository.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/data/repositories/task_repository.dart';

void main() {
  group('TaskRepository local persistence', () {
    test('saves and loads tasks with restart-equivalent reload', () async {
      final store = MemoryLocalStore();
      final writer = TaskRepository(store);

      final task = Task(
        id: '1',
        title: 'Write tests',
        dueDate: DateTime(2026, 1, 1),
        imagePath: '/tmp/image.jpg',
        audioPath: '/tmp/audio.m4a',
      );

      await writer.saveAll([task]);

      final restartedStore = MemoryLocalStore(store.snapshot());
      final reader = TaskRepository(restartedStore);
      final loaded = await reader.loadAll();

      expect(loaded, hasLength(1));
      expect(loaded.first.title, 'Write tests');
      expect(loaded.first.imagePath, '/tmp/image.jpg');
      expect(loaded.first.audioPath, '/tmp/audio.m4a');
    });
  });

  group('DailyNoteRepository local persistence', () {
    test('saves and loads notes with restart-equivalent reload', () async {
      final store = MemoryLocalStore();
      final writer = DailyNoteRepository(store);

      final note = DailyNote(
        date: DateTime(2026, 1, 1),
        content: 'Focus on top priority.',
      );
      await writer.saveAll([note]);

      final restartedStore = MemoryLocalStore(store.snapshot());
      final reader = DailyNoteRepository(restartedStore);
      final loaded = await reader.loadAll();

      expect(loaded, hasLength(1));
      expect(loaded.first.content, 'Focus on top priority.');
      expect(loaded.first.date, DateTime(2026, 1, 1));
    });
  });
}
