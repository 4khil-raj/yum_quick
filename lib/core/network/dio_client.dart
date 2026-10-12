import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

typedef OnUnauthorizedCallback = void Function();

class DioClient {
  final Dio dio;
  final SecureStorageService secureStorage;
  final OnUnauthorizedCallback? onUnauthorized;

  DioClient({required this.secureStorage, this.onUnauthorized, Dio? customDio})
    : dio = customDio ?? Dio() {
    dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final path = error.requestOptions.path;
            if (!path.contains(ApiConstants.loginEndpoint)) {
              onUnauthorized?.call();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
