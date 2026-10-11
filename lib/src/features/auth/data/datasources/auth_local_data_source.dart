import 'dart:convert';

import 'package:yum_quick/src/core/storage/secure_storage_service.dart';

import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens({required String accessToken, String? refreshToken});
  Future<String?> getAccessToken();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAuth();
  Future<void> saveUsername(String username);
  Future<String?> getSavedUsername();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SecureStorageService secureStorage;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
  });

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
    await secureStorage.setOnboardingCompleted(true);
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
  Future<void> saveUsername(String username) async {
    await secureStorage.saveUsername(username);
  }

  @override
  Future<String?> getSavedUsername() async {
    return secureStorage.getSavedUsername();
  }
}
