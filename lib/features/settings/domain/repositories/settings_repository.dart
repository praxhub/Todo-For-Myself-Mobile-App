abstract interface class SettingsRepository {
  Future<bool> loadDarkModeEnabled();
  Future<void> setDarkModeEnabled(bool enabled);
  Future<bool> loadNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
}
