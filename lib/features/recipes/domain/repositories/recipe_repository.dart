import 'package:yum_quick/core/utils/category_mapper.dart';

import '../entities/recipe_entity.dart';

class RecipeListResult {
  final List<RecipeEntity> recipes;
  final int total;
  final int skip;
  final int limit;
  final bool isFromCache;

  const RecipeListResult({
    required this.recipes,
    required this.total,
    required this.skip,
    required this.limit,
    this.isFromCache = false,
  });

  bool get hasMore => (skip + recipes.length) < total;
}

abstract class RecipeRepository {
  Future<RecipeListResult> getRecipes({
    int limit = 10,
    int skip = 0,
    RecipeCategory category = RecipeCategory.all,
  });

  Future<RecipeEntity> getRecipeById(int id);

  Future<RecipeListResult> searchRecipes({
    required String query,
    int limit = 10,
    int skip = 0,
  });

  Future<List<RecipeEntity>> getCachedRecipes();

  Set<int> getFavoriteRecipeIds();

  Future<void> toggleFavorite(int recipeId);
}
