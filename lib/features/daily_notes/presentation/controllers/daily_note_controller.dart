import 'package:flutter/foundation.dart';
import 'package:mytodo/features/daily_notes/domain/models/daily_note.dart';
import 'package:mytodo/features/daily_notes/domain/repositories/daily_note_repository.dart';

class DailyNoteController extends ChangeNotifier {
  DailyNoteController(this._repository);

  final DailyNoteRepository _repository;

  final List<DailyNote> _notes = [];
  List<DailyNote> get notes => List.unmodifiable(_notes);

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadNotes() async {
    await _runGuarded(() async {
      final loaded = await _repository.getAll();
      _notes
        ..clear()
        ..addAll(loaded);
    });
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    notifyListeners();
  }

  DailyNote? noteForSelectedDate() {
    for (final note in _notes) {
      final d = DateTime(note.date.year, note.date.month, note.date.day);
      if (d == _selectedDate) {
        return note;
      }
    }
    return null;
  }

  Future<void> saveNoteForSelectedDate(String content) async {
    await _runGuarded(() async {
      final saved = await _repository.createOrUpdate(
        date: _selectedDate,
        content: content,
      );

      final index = _notes.indexWhere((note) => note.id == saved.id);
      if (index == -1) {
        _notes.insert(0, saved);
      } else {
        _notes[index] = saved;
      }
      _notes.sort((a, b) => b.date.compareTo(a.date));
    }, showLoader: false);
  }

  Future<void> deleteNoteForSelectedDate() async {
    final note = noteForSelectedDate();
    if (note == null) {
      return;
    }

    await _runGuarded(() async {
      await _repository.delete(note.id);
      _notes.removeWhere((item) => item.id == note.id);
    }, showLoader: false);
  }

  Future<void> _runGuarded(
    Future<void> Function() operation, {
    bool showLoader = true,
  }) async {
    try {
      if (showLoader) {
        _isLoading = true;
      }
      _errorMessage = null;
      notifyListeners();
      await operation();
    } catch (error, stackTrace) {
      _errorMessage = 'Unable to process daily note operation.';
      debugPrint('Daily notes operation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (showLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }
}
