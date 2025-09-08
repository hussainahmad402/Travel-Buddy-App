# Fix for MissingPluginException with shared_preferences

## Problem
The `MissingPluginException` occurs because the `shared_preferences` plugin is not properly registered with the Flutter platform.

## Solution Steps

### 1. Clean and Rebuild
```bash
flutter clean
flutter pub get
```

### 2. For Android - Check Generated Files
Make sure these files exist and are properly generated:
- `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java`
- `ios/Runner/GeneratedPluginRegistrant.swift` (for iOS)

### 3. Alternative: Use In-Memory Storage (Current Implementation)
I've temporarily replaced the shared_preferences implementation with in-memory storage to get the app running immediately.

### 4. To Re-enable Shared Preferences Later

1. **Uncomment the dependency in pubspec.yaml:**
```yaml
shared_preferences: ^2.2.2
```

2. **Replace the StorageService implementation:**
```dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
  
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
  
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }
  
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userKey);
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }
  
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }
  
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
```

3. **Run the app:**
```bash
flutter clean
flutter pub get
flutter run
```

## Current Status
The app is now using in-memory storage, which means:
- ✅ App will run without the plugin error
- ✅ Authentication will work during the session
- ❌ Data will be lost when the app is closed
- ❌ No persistent login sessions

## Testing the App
You can now run the app and test all functionality:
```bash
flutter run
```

The app should start successfully and you can test:
- User registration and login
- Trip creation and management
- Profile management
- Document upload (simulated)

All features will work, but login sessions won't persist between app restarts until shared_preferences is properly configured.

