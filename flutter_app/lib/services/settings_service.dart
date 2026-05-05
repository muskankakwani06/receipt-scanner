import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _keyApiKey = 'sb_apiKey';
  static const String _keyBudget = 'sb_budget';
  static const String _keyCurrency = 'sb_currency';
  static const String _keyUserName = 'sb_userName';
  static const String _keyUserEmail = 'sb_userEmail';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  String get apiKey => _prefs.getString(_keyApiKey) ?? 'AIzaSyD-bz6BmUpAANelLH24EIRANy9SmFHnYJE';
  set apiKey(String value) => _prefs.setString(_keyApiKey, value);

  double get budget => _prefs.getDouble(_keyBudget) ?? 10000.0;
  set budget(double value) => _prefs.setDouble(_keyBudget, value);

  String get currency => _prefs.getString(_keyCurrency) ?? '₹';
  set currency(String value) => _prefs.setString(_keyCurrency, value);

  String get userName => _prefs.getString(_keyUserName) ?? 'Alex Johnson';
  set userName(String value) => _prefs.setString(_keyUserName, value);

  String get userEmail => _prefs.getString(_keyUserEmail) ?? 'alex.j@example.com';
  set userEmail(String value) => _prefs.setString(_keyUserEmail, value);
}
