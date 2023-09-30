import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _preferences;
  static const defaultString = '';
  static const defaultInt = -1;
  static const defaultDouble = -1.0;
  static const defaultBool = false;
  static const defaultList = <String>[];

  static Future<SharedPreferences> get _instance async => _preferences ??= await SharedPreferences.getInstance();

  static Future<SharedPreferences> init() async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  static Future<bool> clear() async {
    return (await _instance).clear();
  }

  static String getString(String key, [String def = defaultString]) {
    if (null == _preferences) return def;
    return _preferences!.getString(key) ?? def;
  }

  static int getInt(String key, [int def = defaultInt]) {
    if (null == _preferences) return def;
    return _preferences!.getInt(key) ?? def;
  }

  static double getDouble(String key, [double def = defaultDouble]) {
    if (null == _preferences) return def;
    return _preferences!.getDouble(key) ?? def;
  }

  static bool getBool(String key, [bool def = defaultBool]) {
    if (null == _preferences) return def;
    return _preferences!.getBool(key) ?? def;
  }

  static List<String> getList(String key, [List<String> def = defaultList]) {
    if (null == _preferences) return def;
    return _preferences!.getStringList(key) ?? def;
  }

  static Set<String>? getKeys(String key) => _preferences?.getKeys();

  static Future<bool> setString(String key, String? value, [String valueIfNull = defaultString]) async {
    return (await _instance).setString(key, value ?? valueIfNull);
  }

  static Future<bool> setInt(String key, int? value, [int valueIfNull = defaultInt]) async {
    return (await _instance).setInt(key, value ?? valueIfNull);
  }

  static Future<bool> setDouble(String key, double? value, [double valueIfNull = defaultDouble]) async {
    return (await _instance).setDouble(key, value ?? valueIfNull);
  }

  static Future<bool> setBool(String key, bool? value, [bool valueIfNull = defaultBool]) async {
    return (await _instance).setBool(key, value ?? valueIfNull);
  }

  static Future<bool> setList(String key, List<String>? value, [List<String> valueIfNull = defaultList]) async {
    return (await _instance).setStringList(key, value ?? valueIfNull);
  }
}
