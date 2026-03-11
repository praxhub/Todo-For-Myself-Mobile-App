import 'package:hive/hive.dart';

@HiveType(typeId: 3)
class Habit extends HiveObject {
  Habit({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.colorHex,
    List<DateTime>? completedDates,
  }) : completedDates = completedDates ?? <DateTime>[];

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final String colorHex;

  @HiveField(4)
  final List<DateTime> completedDates;

  Habit copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    String? colorHex,
    List<DateTime>? completedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      colorHex: colorHex ?? this.colorHex,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 3;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return Habit(
      id: fields[0] as String,
      title: fields[1] as String,
      createdAt: fields[2] as DateTime,
      colorHex: fields[3] as String,
      completedDates: (fields[4] as List?)?.cast<DateTime>() ?? <DateTime>[],
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.completedDates);
  }
}
