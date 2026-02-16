import 'dart:convert';

import 'package:todo_for_myself_mobile_app/features/daily_notes/domain/models/daily_note.dart';
import 'package:todo_for_myself_mobile_app/core/persistence/local_store.dart';

class DailyNoteRepository {
  DailyNoteRepository(this._store);

  static const _storageKey = 'daily_notes';
  final LocalStore _store;

  Future<List<DailyNote>> loadAll() async {
    final raw = await _store.getString(_storageKey);
    if (raw == null || raw.isEmpty) return <DailyNote>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((dynamic item) => DailyNote.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveAll(List<DailyNote> notes) async {
    final encoded = jsonEncode(notes.map((note) => note.toJson()).toList());
    await _store.setString(_storageKey, encoded);
  }
}
