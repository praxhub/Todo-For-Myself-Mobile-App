import 'package:mytodo/core/data/local/hive_database.dart';
import 'package:mytodo/features/daily_notes/domain/models/daily_note.dart';
import 'package:mytodo/features/daily_notes/domain/repositories/daily_note_repository.dart';
import 'package:uuid/uuid.dart';

class LocalDailyNoteRepository implements DailyNoteRepository {
  LocalDailyNoteRepository({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  @override
  Future<DailyNote> createOrUpdate({
    required DateTime date,
    required String content,
  }) async {
    await HiveDatabase.initialize();

    final normalizedDate = _normalizeDate(date);
    final trimmedContent = content.trim();
    final now = DateTime.now();
    final existing = await getByDate(normalizedDate);

    final note = existing?.copyWith(
          content: trimmedContent,
          updatedAt: now,
        ) ??
        DailyNote(
          id: _uuid.v4(),
          date: normalizedDate,
          content: trimmedContent,
          createdAt: now,
          updatedAt: now,
        );

    await HiveDatabase.dailyNotesBox().put(note.id, note);
    return note;
  }

  @override
  Future<void> delete(String id) async {
    await HiveDatabase.initialize();
    await HiveDatabase.dailyNotesBox().delete(id);
  }

  @override
  Future<List<DailyNote>> getAll() async {
    await HiveDatabase.initialize();
    final notes = HiveDatabase.dailyNotesBox().values.toList(growable: false);
    notes.sort((a, b) => b.date.compareTo(a.date));
    return notes;
  }

  @override
  Future<DailyNote?> getByDate(DateTime date) async {
    await HiveDatabase.initialize();
    final normalizedTarget = _normalizeDate(date);

    for (final note in HiveDatabase.dailyNotesBox().values) {
      if (_normalizeDate(note.date) == normalizedTarget) {
        return note;
      }
    }

    return null;
  }

  @override
  Future<DailyNote?> getById(String id) async {
    await HiveDatabase.initialize();
    return HiveDatabase.dailyNotesBox().get(id);
  }

  @override
  Future<void> clearAll() async {
    await HiveDatabase.initialize();
    await HiveDatabase.dailyNotesBox().clear();
  }

  DateTime _normalizeDate(DateTime input) {
    return DateTime(input.year, input.month, input.day);
  }
}
