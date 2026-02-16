import 'dart:convert';

class Task {
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.imagePath,
    this.voiceNotePath,
  });

  final String id;
  String title;
  String description;
  DateTime dueDate;
  String? imagePath;
  String? voiceNotePath;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'imagePath': imagePath,
        'voiceNotePath': voiceNotePath,
      };

  factory Task.fromMap(Map<String, dynamic> map) => Task(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String? ?? '',
        dueDate: DateTime.parse(map['dueDate'] as String),
        imagePath: map['imagePath'] as String?,
        voiceNotePath: map['voiceNotePath'] as String?,
      );

  static String encode(List<Task> tasks) => jsonEncode(tasks.map((task) => task.toMap()).toList());

  static List<Task> decode(String raw) {
    final parsed = jsonDecode(raw) as List<dynamic>;
    return parsed
        .map((item) => Task.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
