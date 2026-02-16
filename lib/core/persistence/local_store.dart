abstract class LocalStore {
  Future<void> setString(String key, String value);
  Future<String?> getString(String key);
}

class MemoryLocalStore implements LocalStore {
  MemoryLocalStore([Map<String, String>? seed]) : _values = seed ?? <String, String>{};

  final Map<String, String> _values;

  @override
  Future<String?> getString(String key) async => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    _values[key] = value;
  }

  Map<String, String> snapshot() => Map<String, String>.from(_values);
}
