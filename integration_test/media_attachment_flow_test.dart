import 'package:flutter_test/flutter_test.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/core/persistence/local_store.dart';
import 'package:todo_for_myself_mobile_app/services/media_attachment_service.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/data/repositories/task_repository.dart';

class FakeAudioEngine implements AudioEngine {
  final List<String> recordedTemporaryPaths = <String>[];
  final Set<String> persistedAudioPaths = <String>{};

  @override
  Future<void> delete(String path) async {
    persistedAudioPaths.remove(path);
  }

  @override
  Future<bool> play(String path) async {
    return persistedAudioPaths.contains(path);
  }

  @override
  Future<void> startRecording(String temporaryPath) async {
    recordedTemporaryPaths.add(temporaryPath);
  }

  @override
  Future<String> stopRecording(String finalPath) async {
    persistedAudioPaths.add(finalPath);
    return finalPath;
  }
}

void main() {
  group('Media attachment integration flows', () {
    test('image path save/load survives repository reload', () async {
      final store = MemoryLocalStore();
      final taskRepository = TaskRepository(store);
      await taskRepository.saveAll([
        Task(id: 'task-1', title: 'Task', dueDate: DateTime(2026, 1, 1)),
      ]);

      final service = MediaAttachmentService(
        taskRepository: taskRepository,
        audioEngine: FakeAudioEngine(),
      );

      await service.attachImage('task-1', '/images/task-1.png');

      final restartedRepository = TaskRepository(MemoryLocalStore(store.snapshot()));
      final tasks = await restartedRepository.loadAll();
      expect(tasks.first.imagePath, '/images/task-1.png');
    });

    test('audio record-play-delete lifecycle updates persistence and engine state',
        () async {
      final store = MemoryLocalStore();
      final taskRepository = TaskRepository(store);
      await taskRepository.saveAll([
        Task(id: 'task-1', title: 'Task', dueDate: DateTime(2026, 1, 1)),
      ]);
      final audioEngine = FakeAudioEngine();
      final service = MediaAttachmentService(
        taskRepository: taskRepository,
        audioEngine: audioEngine,
      );

      await service.startAudioRecording('/audio/temp-task-1.raw');
      await service.stopAudioRecording('task-1', '/audio/task-1.m4a');

      expect(audioEngine.recordedTemporaryPaths, contains('/audio/temp-task-1.raw'));
      expect(await service.playAudio('task-1'), isTrue);

      await service.deleteAudio('task-1');
      expect(await service.playAudio('task-1'), isFalse);

      final restartedRepository = TaskRepository(MemoryLocalStore(store.snapshot()));
      final restartedTask = (await restartedRepository.loadAll()).first;
      expect(restartedTask.audioPath, isNull);
    });
  });
}
