import 'dart:convert';

class JournalEntry {
  JournalEntry({
    required this.dateKey,
    required this.content,
    this.imagePath,
  });

  final String dateKey;
  String content;
  String? imagePath;

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'content': content,
        'imagePath': imagePath,
      };

  factory JournalEntry.fromMap(Map<String, dynamic> map) => JournalEntry(
        dateKey: map['dateKey'] as String,
        content: map['content'] as String? ?? '',
        imagePath: map['imagePath'] as String?,
      );

  static String encode(Map<String, JournalEntry> journals) => jsonEncode(
        journals.map((key, value) => MapEntry(key, value.toMap())),
      );

  static Map<String, JournalEntry> decode(String raw) {
    final parsed = jsonDecode(raw) as Map<String, dynamic>;
    return parsed.map(
      (key, value) => MapEntry(
        key,
        JournalEntry.fromMap(Map<String, dynamic>.from(value as Map)),
      ),
    );
  }
}
