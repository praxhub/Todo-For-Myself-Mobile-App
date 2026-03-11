import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class PomodoroSession extends HiveObject {
  PomodoroSession({
    required this.id,
    required this.durationSeconds,
    required this.completedAt,
    this.taskId,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final int durationSeconds;

  @HiveField(2)
  final DateTime completedAt;

  @HiveField(3)
  final String? taskId;
}

class PomodoroSessionAdapter extends TypeAdapter<PomodoroSession> {
  @override
  final int typeId = 4;

  @override
  PomodoroSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return PomodoroSession(
      id: fields[0] as String,
      durationSeconds: fields[1] as int,
      completedAt: fields[2] as DateTime,
      taskId: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PomodoroSession obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.durationSeconds)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.taskId);
  }
}
