import 'package:mytodo/features/settings/domain/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSettingsRepository implements SettingsRepository {
  static const String _darkModeKey = 'settings_dark_mode_enabled';

  @override
  Future<bool> loadDarkModeEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_darkModeKey) ?? false;
  }

  @override
  Future<void> setDarkModeEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, enabled);
  }

  static const String _notificationsKey = 'settings_notifications_enabled';

  @override
  Future<bool> loadNotificationsEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_notificationsKey) ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_notificationsKey, enabled);
  }
}
