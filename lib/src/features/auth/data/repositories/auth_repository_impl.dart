import 'package:yum_quick/src/core/errors/exceptions.dart';
import 'package:yum_quick/src/core/errors/failures.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.login(
        username: username,
        password: password,
      );

      if (user.accessToken != null) {
        await localDataSource.saveTokens(
          accessToken: user.accessToken!,
          refreshToken: user.refreshToken,
        );
      }
      await localDataSource.saveUser(user);
      await localDataSource.saveUsername(username);

      return user.toEntity();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<UserEntity?> restoreSession() async {
    try {
      final token = await localDataSource.getAccessToken();
      if (token == null || token.isEmpty) {
        return null;
      }

      final cachedUser = await localDataSource.getUser();
      return cachedUser?.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAuth();
  }

  @override
  Future<bool> isBiometricAvailable() async {
    return localDataSource.isBiometricAvailable();
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    return localDataSource.authenticateWithBiometrics();
  }

  @override
  Future<void> setBiometricEnabled(bool enabled) async {
    await localDataSource.setBiometricEnabled(enabled);
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return localDataSource.isBiometricEnabled();
  }

  @override
  Future<String?> getSavedUsername() async {
    return localDataSource.getSavedUsername();
  }

  @override
  Future<void> saveUsername(String username) async {
    await localDataSource.saveUsername(username);
  }
}
