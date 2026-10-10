import 'package:dio/dio.dart';
import 'package:yum_quick/src/core/constants/api_constants.dart';
import 'package:yum_quick/src/core/errors/exceptions.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});

  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'username': username.trim(),
          'password': password.trim(),
          'expiresInMins': 60,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw AuthException(response.data?['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        final message =
            e.response?.data?['message'] as String? ??
            'Invalid username or password.';
        throw AuthException(message);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          'Unable to connect to server. Check your internet connection.',
        );
      }
      throw ServerException(
        e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      if (e is AuthException || e is NetworkException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await dio.get(ApiConstants.meEndpoint);
      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw const AuthException('Session expired');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Session expired. Please log in again.');
      }
      throw ServerException(
        e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
