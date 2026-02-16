import 'package:todo_for_myself_mobile_app/features/tasks/domain/models/task.dart';
import 'package:todo_for_myself_mobile_app/features/tasks/data/repositories/task_repository.dart';

abstract class AudioEngine {
  Future<void> startRecording(String temporaryPath);
  Future<String> stopRecording(String finalPath);
  Future<bool> play(String path);
  Future<void> delete(String path);
}

class MediaAttachmentService {
  MediaAttachmentService({
    required TaskRepository taskRepository,
    required AudioEngine audioEngine,
  })  : _taskRepository = taskRepository,
        _audioEngine = audioEngine;

  final TaskRepository _taskRepository;
  final AudioEngine _audioEngine;

  Future<void> attachImage(String taskId, String imagePath) async {
    final tasks = await _taskRepository.loadAll();
    final task = tasks.firstWhere((element) => element.id == taskId);
    task.imagePath = imagePath;
    await _taskRepository.saveAll(tasks);
  }

  Future<void> startAudioRecording(String temporaryPath) {
    return _audioEngine.startRecording(temporaryPath);
  }

  Future<void> stopAudioRecording(String taskId, String finalPath) async {
    final savedPath = await _audioEngine.stopRecording(finalPath);
    final tasks = await _taskRepository.loadAll();
    final task = tasks.firstWhere((element) => element.id == taskId);
    task.audioPath = savedPath;
    await _taskRepository.saveAll(tasks);
  }

  Future<bool> playAudio(String taskId) async {
    final tasks = await _taskRepository.loadAll();
    final task = tasks.firstWhere((element) => element.id == taskId);
    final path = task.audioPath;
    if (path == null) return false;
    return _audioEngine.play(path);
  }

  Future<void> deleteAudio(String taskId) async {
    final tasks = await _taskRepository.loadAll();
    final task = tasks.firstWhere((element) => element.id == taskId);
    final path = task.audioPath;
    if (path == null) return;
    await _audioEngine.delete(path);
    task.audioPath = null;
    await _taskRepository.saveAll(tasks);
  }
}
