import 'package:flutter/foundation.dart';
import 'package:mytodo/features/settings/domain/repositories/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  SettingsController(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkModeEnabled = false;
  bool get isDarkModeEnabled => _isDarkModeEnabled;

  bool _isNotificationsEnabled = true;
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadSettings() async {
    await _runGuarded(() async {
      _isDarkModeEnabled = await _settingsRepository.loadDarkModeEnabled();
      _isNotificationsEnabled =
          await _settingsRepository.loadNotificationsEnabled();
    });
  }

  Future<void> setDarkModeEnabled(bool enabled) async {
    await _runGuarded(() async {
      await _settingsRepository.setDarkModeEnabled(enabled);
      _isDarkModeEnabled = enabled;
    }, showLoader: false);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _runGuarded(() async {
      await _settingsRepository.setNotificationsEnabled(enabled);
      _isNotificationsEnabled = enabled;
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
      _errorMessage = 'Unable to update settings right now.';
      debugPrint('Settings operation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (showLoader) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }
}
