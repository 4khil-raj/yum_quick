import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String username,
    required String password,
  });

  Future<UserEntity?> restoreSession();

  Future<void> logout();

  Future<bool> isBiometricAvailable();

  Future<bool> authenticateWithBiometrics();

  Future<void> setBiometricEnabled(bool enabled);

  Future<bool> isBiometricEnabled();

  Future<String?> getSavedUsername();

  Future<void> saveUsername(String username);
}
