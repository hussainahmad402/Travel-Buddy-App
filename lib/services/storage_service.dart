import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // Secure storage instance
  static const _secureStorage = FlutterSecureStorage();

  // Keys for secure storage
  static const _tokenKey = 'auth_token';
  static const _userDataKey = 'user_data';

  // Keys for shared preferences
  static const _isLoggedInKey = 'is_logged_in';
  static const _themeModeKey = 'theme_mode';

  /// ================== SECURE STORAGE ==================

  // Save JWT or API token
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  // Get JWT or API token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  // Save user data (JSON string, you can use jsonEncode(userMap))
  static Future<void> saveUserData(String userDataJson) async {
    await _secureStorage.write(key: _userDataKey, value: userDataJson);
  }

  static Future<String?> getUserData() async {
    return await _secureStorage.read(key: _userDataKey);
  }

  /// ================== SHARED PREFERENCES ==================

  // Set login state
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Save theme mode (e.g., light/dark/system)
  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }

  static Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey);
  }

  /// ================== CLEAR ALL ==================
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
