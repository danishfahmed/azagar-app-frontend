import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  SessionManager._();

  static const _keyUserId = 'user_id';
  static const _keyEmail = 'user_email';
  static const _keyToken = 'auth_token';
  static const _keyDarkMode = 'dark_mode';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Auth ─────────────────────────────────────────────

  static Future<void> saveSession({
    required int userId,
    required String email,
    required String token,
  }) async {
    await _prefs.setInt(_keyUserId, userId);
    await _prefs.setString(_keyEmail, email);
    await _prefs.setString(_keyToken, token);
  }

  static Future<void> clearSession() async {
    await _prefs.remove(_keyUserId);
    await _prefs.remove(_keyEmail);
    await _prefs.remove(_keyToken);
  }

  static bool get isLoggedIn => _prefs.containsKey(_keyToken);

  static int? get userId => _prefs.getInt(_keyUserId);
  static String? get email => _prefs.getString(_keyEmail);
  static String? get token => _prefs.getString(_keyToken);

  // ── Dark mode ────────────────────────────────────────

  static bool get isDarkMode => _prefs.getBool(_keyDarkMode) ?? false;

  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }
}
