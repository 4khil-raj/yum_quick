import 'package:yum_quick/src/core/errors/exceptions.dart';
import 'package:yum_quick/src/core/errors/failures.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';

import '../../domain/entities/recipe_entity.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_data_source.dart';
import '../datasources/recipe_remote_data_source.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeRemoteDataSource remoteDataSource;
  final RecipeLocalDataSource localDataSource;

  RecipeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<RecipeListResult> getRecipes({
    int limit = 10,
    int skip = 0,
    RecipeCategory category = RecipeCategory.all,
  }) async {
    try {
      final raw = await remoteDataSource.fetchRecipesRaw(
        limit: limit,
        skip: skip,
      );

      // Cache the first page when successfully loaded
      if (skip == 0) {
        await localDataSource.cacheFirstPageRecipes(raw);
      }

      final rawList = (raw['recipes'] as List?) ?? [];
      final models = rawList
          .map((e) => RecipeModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final total = raw['total'] as int? ?? models.length;

      // Filter by category if specified
      final filtered = category == RecipeCategory.all
          ? models
          : models
                .where(
                  (r) => CategoryMapper.matchesCategory(
                    category: category,
                    mealTypes: r.mealType,
                    tags: r.tags,
                  ),
                )
                .toList();

      return RecipeListResult(
        recipes: filtered,
        total: total,
        skip: skip,
        limit: limit,
        isFromCache: false,
      );
    } on NetworkException {
      // Offline fallback for first page
      if (skip == 0) {
        final cached = localDataSource.getCachedFirstPageRecipes();
        if (cached.isNotEmpty) {
          final filtered = category == RecipeCategory.all
              ? cached
              : cached
                    .where(
                      (r) => CategoryMapper.matchesCategory(
                        category: category,
                        mealTypes: r.mealType,
                        tags: r.tags,
                      ),
                    )
                    .toList();

          return RecipeListResult(
            recipes: filtered,
            total: filtered.length,
            skip: 0,
            limit: limit,
            isFromCache: true,
          );
        }
      }
      throw const NetworkFailure(
        'No network connection and no cached recipes available.',
      );
    } on ServerException catch (e) {
      // If server error on first page, check cache
      if (skip == 0) {
        final cached = localDataSource.getCachedFirstPageRecipes();
        if (cached.isNotEmpty) {
          final filtered = category == RecipeCategory.all
              ? cached
              : cached
                    .where(
                      (r) => CategoryMapper.matchesCategory(
                        category: category,
                        mealTypes: r.mealType,
                        tags: r.tags,
                      ),
                    )
                    .toList();

          return RecipeListResult(
            recipes: filtered,
            total: filtered.length,
            skip: 0,
            limit: limit,
            isFromCache: true,
          );
        }
      }
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<RecipeEntity> getRecipeById(int id) async {
    try {
      final model = await remoteDataSource.fetchRecipeById(id);
      return model.toEntity();
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<RecipeListResult> searchRecipes({
    required String query,
    int limit = 10,
    int skip = 0,
  }) async {
    try {
      final raw = await remoteDataSource.searchRecipesRaw(
        query: query,
        limit: limit,
        skip: skip,
      );
      final rawList = (raw['recipes'] as List?) ?? [];
      final models = rawList
          .map((e) => RecipeModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      final total = raw['total'] as int? ?? models.length;

      return RecipeListResult(
        recipes: models,
        total: total,
        skip: skip,
        limit: limit,
        isFromCache: false,
      );
    } on NetworkException catch (e) {
      throw NetworkFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message, statusCode: e.statusCode);
    } catch (e) {
      throw UnexpectedFailure(e.toString());
    }
  }

  @override
  Future<List<RecipeEntity>> getCachedRecipes() async {
    return localDataSource.getCachedFirstPageRecipes();
  }

  @override
  Set<int> getFavoriteRecipeIds() {
    return localDataSource.getFavoriteIds();
  }

  @override
  Future<void> toggleFavorite(int recipeId) async {
    await localDataSource.toggleFavorite(recipeId);
  }
}
