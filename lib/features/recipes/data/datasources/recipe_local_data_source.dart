import 'package:yum_quick/core/storage/hive_storage_service.dart';

import '../models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<void> cacheFirstPageRecipes(Map<String, dynamic> rawJson);
  List<RecipeModel> getCachedFirstPageRecipes();
  Set<int> getFavoriteIds();
  Future<void> toggleFavorite(int recipeId);
  bool isFavorite(int recipeId);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final HiveStorageService hiveStorage;

  RecipeLocalDataSourceImpl({required this.hiveStorage});

  @override
  Future<void> cacheFirstPageRecipes(Map<String, dynamic> rawJson) async {
    await hiveStorage.cacheFirstPageRecipes(rawJson);
  }

  @override
  List<RecipeModel> getCachedFirstPageRecipes() {
    final cached = hiveStorage.getCachedFirstPageRecipes();
    if (cached == null) return [];
    try {
      final list = (cached['recipes'] as List?) ?? [];
      return list
          .map((e) => RecipeModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Set<int> getFavoriteIds() {
    return hiveStorage.getFavoriteIds();
  }

  @override
  Future<void> toggleFavorite(int recipeId) async {
    await hiveStorage.toggleFavorite(recipeId);
  }

  @override
  bool isFavorite(int recipeId) {
    return hiveStorage.isFavorite(recipeId);
  }
}
