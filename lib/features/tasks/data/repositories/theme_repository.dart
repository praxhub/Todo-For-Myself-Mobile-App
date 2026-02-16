import 'package:todo_for_myself_mobile_app/core/persistence/local_store.dart';

class ThemeRepository {
  ThemeRepository(this._store);

  static const _storageKey = 'is_dark_mode';
  final LocalStore _store;

  Future<bool> loadThemeMode() async {
    final raw = await _store.getString(_storageKey);
    return raw == 'true';
  }

  Future<void> saveThemeMode(bool isDarkMode) async {
    await _store.setString(_storageKey, isDarkMode.toString());
  }
}
