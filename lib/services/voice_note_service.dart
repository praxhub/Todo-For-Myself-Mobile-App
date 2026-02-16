import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class VoiceNoteService {
  VoiceNoteService(this._record);

  static const maxDuration = Duration(minutes: 5);

  final AudioRecorder _record;
  Timer? _limitTimer;

  Future<String> startRecording() async {
    final hasPermission = await _record.hasPermission();
    if (!hasPermission) {
      throw Exception('Microphone permission denied');
    }

    final appDir = await getApplicationDocumentsDirectory();
    final voiceDir = Directory(p.join(appDir.path, 'voice'));
    if (!voiceDir.existsSync()) {
      voiceDir.createSync(recursive: true);
    }

    final path = p.join(
      voiceDir.path,
      'voice_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );

    await _record.start(
      const RecordConfig(encoder: AudioEncoder.aacLc),
      path: path,
    );

    _limitTimer?.cancel();
    _limitTimer = Timer(maxDuration, () async {
      if (await _record.isRecording()) {
        await _record.stop();
      }
    });

    return path;
  }

  Future<String?> stopRecording() async {
    _limitTimer?.cancel();
    return _record.stop();
  }

  Future<void> dispose() async {
    _limitTimer?.cancel();
    await _record.dispose();
  }
}
