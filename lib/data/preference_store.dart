import 'package:shared_preferences/shared_preferences.dart';

/// Replaceable persistence boundary; the memory implementation keeps tests isolated.
class PreferenceStore {
  PreferenceStore() : _platform = SharedPreferencesAsync();
  PreferenceStore.memory() : _platform = null;
  final SharedPreferencesAsync? _platform;
  final Map<String, Object> _memory = {};
  Future<bool?> getBool(String key) async =>
      _platform != null ? _platform.getBool(key) : _memory[key] as bool?;
  Future<String?> getString(String key) async =>
      _platform != null ? _platform.getString(key) : _memory[key] as String?;
  Future<List<String>?> getStringList(String key) async => _platform != null
      ? _platform.getStringList(key)
      : (_memory[key] as List<String>?)?.toList();
  Future<void> setBool(String key, bool value) async {
    if (_platform != null) {
      await _platform.setBool(key, value);
    } else {
      _memory[key] = value;
    }
  }

  Future<void> setString(String key, String value) async {
    if (_platform != null) {
      await _platform.setString(key, value);
    } else {
      _memory[key] = value;
    }
  }

  Future<void> setStringList(String key, List<String> value) async {
    if (_platform != null) {
      await _platform.setStringList(key, value);
    } else {
      _memory[key] = value.toList();
    }
  }
}
