class DailyNote {
  DailyNote({required this.date, required this.content});

  final DateTime date;
  String content;

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'content': content,
      };

  factory DailyNote.fromJson(Map<String, dynamic> json) => DailyNote(
        date: DateTime.parse(json['date'] as String),
        content: json['content'] as String,
      );
}
