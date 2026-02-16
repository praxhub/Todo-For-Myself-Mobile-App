class Task {
  Task({
    required this.id,
    required this.title,
    required this.dueDate,
    this.isDone = false,
    this.imagePath,
    this.audioPath,
  });

  final String id;
  String title;
  DateTime dueDate;
  bool isDone;
  String? imagePath;
  String? audioPath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dueDate': dueDate.toIso8601String(),
        'isDone': isDone,
        'imagePath': imagePath,
        'audioPath': audioPath,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as String,
        title: json['title'] as String,
        dueDate: DateTime.parse(json['dueDate'] as String),
        isDone: json['isDone'] as bool? ?? false,
        imagePath: json['imagePath'] as String?,
        audioPath: json['audioPath'] as String?,
      );
}
