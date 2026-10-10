import 'package:dio/dio.dart';
import 'package:yum_quick/src/core/constants/api_constants.dart';
import 'package:yum_quick/src/core/errors/exceptions.dart';

import '../models/recipe_model.dart';

abstract class RecipeRemoteDataSource {
  Future<Map<String, dynamic>> fetchRecipesRaw({int limit = 10, int skip = 0});
  Future<RecipeModel> fetchRecipeById(int id);
  Future<Map<String, dynamic>> searchRecipesRaw({
    required String query,
    int limit = 10,
    int skip = 0,
  });
  Future<List<RecipeModel>> fetchRecipesByTag(String tag);
  Future<List<RecipeModel>> fetchRecipesByMealType(String mealType);
}

class RecipeRemoteDataSourceImpl implements RecipeRemoteDataSource {
  final Dio dio;

  RecipeRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> fetchRecipesRaw({
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.recipesEndpoint,
        queryParameters: {'limit': limit, 'skip': skip},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw ServerException(
        'Failed to fetch recipes',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('Network error while fetching recipes');
      }
      throw ServerException(
        e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<RecipeModel> fetchRecipeById(int id) async {
    try {
      final response = await dio.get('${ApiConstants.recipesEndpoint}/$id');
      if (response.statusCode == 200 && response.data != null) {
        return RecipeModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw ServerException(
        'Failed to fetch recipe #$id',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('Network error while fetching recipe');
      }
      throw ServerException(
        e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> searchRecipesRaw({
    required String query,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.searchRecipesEndpoint,
        queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      );
      if (response.statusCode == 200 && response.data != null) {
        return Map<String, dynamic>.from(response.data as Map);
      }
      throw ServerException(
        'Failed to search recipes',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const NetworkException('Network error during search');
      }
      throw ServerException(
        e.message ?? 'Server error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<RecipeModel>> fetchRecipesByTag(String tag) async {
    try {
      final response = await dio.get('${ApiConstants.tagRecipesEndpoint}/$tag');
      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data['recipes'] as List?) ?? [];
        return list
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<RecipeModel>> fetchRecipesByMealType(String mealType) async {
    try {
      final response = await dio.get(
        '${ApiConstants.mealTypeRecipesEndpoint}/$mealType',
      );
      if (response.statusCode == 200 && response.data != null) {
        final list = (response.data['recipes'] as List?) ?? [];
        return list
            .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
