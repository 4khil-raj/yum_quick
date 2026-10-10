import 'dart:convert';

import 'package:local_auth/local_auth.dart';
import 'package:yum_quick/src/core/storage/secure_storage_service.dart';

import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<String?> getAccessToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAuth();
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometrics();
  Future<void> setBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
  Future<void> saveUsername(String username);
  Future<String?> getSavedUsername();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;
  final LocalAuthentication localAuth;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    LocalAuthentication? customLocalAuth,
  }) : localAuth = customLocalAuth ?? LocalAuthentication();

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return secureStorage.getAccessToken();
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await secureStorage.saveUserData(jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final raw = await secureStorage.getUserData();
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearAuth() async {
    await secureStorage.clearAll();
  }

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      final canAuthWithBiometrics = await localAuth.canCheckBiometrics;
      final isDeviceSupported = await localAuth.isDeviceSupported();
      if (!canAuthWithBiometrics && !isDeviceSupported) return false;
      final availableBiometrics = await localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await localAuth.authenticate(
        localizedReason:
            'Please authenticate with biometrics to access YumQuick',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await secureStorage.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return secureStorage.isBiometricEnabled();
  }

  @override
  Future<void> saveUsername(String username) async {
    await secureStorage.saveUsername(username);
  }

  @override
  Future<String?> getSavedUsername() async {
    return secureStorage.getSavedUsername();
  }
}
