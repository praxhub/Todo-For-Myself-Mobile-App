import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  Task({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    this.dueDate,
    this.isOptional = false,
    this.timeSpentSeconds = 0,
    this.startTime,
    this.endTime,
    this.timerMilliseconds = 0,
    this.isRunning = false,
    this.lastStartedAt,
    this.category,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final bool isCompleted;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime? dueDate;

  @HiveField(5)
  final bool isOptional;

  @HiveField(6)
  final int timeSpentSeconds;

  @HiveField(7)
  final DateTime? startTime;

  @HiveField(8)
  final DateTime? endTime;

  @HiveField(9)
  final int timerMilliseconds;

  // Runtime properties, don't store in DB so timers reset if app closes
  bool isRunning;
  @HiveField(11)
  final DateTime? lastStartedAt;

  @HiveField(12)
  final String? category;

  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    bool? isOptional,
    int? timeSpentSeconds,
    DateTime? startTime,
    DateTime? endTime,
    int? timerMilliseconds,
    bool? isRunning,
    DateTime? lastStartedAt,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      isOptional: isOptional ?? this.isOptional,
      timeSpentSeconds: timeSpentSeconds ?? this.timeSpentSeconds,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timerMilliseconds: timerMilliseconds ?? this.timerMilliseconds,
      isRunning: isRunning ?? this.isRunning,
      lastStartedAt: lastStartedAt ??
          this.lastStartedAt, // deliberately nullable override possible
      category: category ?? this.category,
    );
  }
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      createdAt: fields[3] as DateTime,
      dueDate: fields[4] as DateTime?,
      isOptional: fields[5] as bool? ?? false,
      timeSpentSeconds: fields[6] as int? ?? 0,
      startTime: fields[7] as DateTime?,
      endTime: fields[8] as DateTime?,
      timerMilliseconds: fields[9] as int? ?? 0,
      category: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(11) // Fields 0-9 and 12
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.dueDate)
      ..writeByte(5)
      ..write(obj.isOptional)
      ..writeByte(6)
      ..write(obj.timeSpentSeconds)
      ..writeByte(7)
      ..write(obj.startTime)
      ..writeByte(8)
      ..write(obj.endTime)
      ..writeByte(9)
      ..write(obj.timerMilliseconds)
      ..writeByte(12)
      ..write(obj.category);
  }
}
