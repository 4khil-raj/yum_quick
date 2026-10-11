import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'hive_storage_service.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  final HiveStorageService? hiveStorage;

  SecureStorageService({
    FlutterSecureStorage? storage,
    this.hiveStorage,
  }) : _storage =
           storage ??
           const FlutterSecureStorage(
             aOptions: AndroidOptions(resetOnError: true),
             iOptions: IOSOptions(
               accessibility: KeychainAccessibility.first_unlock,
             ),
           );

  static const String _keyAccessToken = 'auth_access_token';
  static const String _keyRefreshToken = 'auth_refresh_token';
  static const String _keyUserData = 'auth_user_data';
  static const String _keySavedUsername = 'auth_saved_username';
  static const String _keyOnboardingCompleted = 'app_onboarding_completed';

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _keyRefreshToken, value: refreshToken);
    }
  }

  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _keyAccessToken);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {
      // In case of hardware keystore reset, return null to trigger safe re-authentication
      return null;
    }
    return null;
  }

  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _keyRefreshToken);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveUserData(String userDataJson) async {
    await _storage.write(key: _keyUserData, value: userDataJson);
  }

  Future<String?> getUserData() async {
    try {
      final data = await _storage.read(key: _keyUserData);
      if (data != null && data.isNotEmpty) return data;
    } catch (_) {
      return null;
    }
    return null;
  }

  Future<void> saveUsername(String username) async {
    try {
      await _storage.write(key: _keySavedUsername, value: username);
    } catch (_) {}
    await hiveStorage?.savePreference(_keySavedUsername, username);
  }

  Future<String?> getSavedUsername() async {
    try {
      final username = await _storage.read(key: _keySavedUsername);
      if (username != null && username.isNotEmpty) return username;
    } catch (_) {}

    return hiveStorage?.getPreference(_keySavedUsername);
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final strVal = completed ? 'true' : 'false';
    try {
      await _storage.write(key: _keyOnboardingCompleted, value: strVal);
    } catch (_) {}
    await hiveStorage?.savePreference(_keyOnboardingCompleted, strVal);
  }

  Future<bool> isOnboardingCompleted() async {
    try {
      final val = await _storage.read(key: _keyOnboardingCompleted);
      if (val != null) return val == 'true';
    } catch (_) {}

    final hiveVal = hiveStorage?.getPreference(_keyOnboardingCompleted);
    if (hiveVal != null) return hiveVal == 'true';
    return false;
  }

  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _keyAccessToken);
      await _storage.delete(key: _keyRefreshToken);
      await _storage.delete(key: _keyUserData);
    } catch (_) {}
  }

  Future<void> fullWipe() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
    await hiveStorage?.clearPreferences();
  }
}
