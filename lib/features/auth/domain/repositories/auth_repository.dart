import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String username,
    required String password,
  });

  Future<UserEntity?> restoreSession();

  Future<void> logout();

  Future<String?> getSavedUsername();

  Future<void> saveUsername(String username);
}
