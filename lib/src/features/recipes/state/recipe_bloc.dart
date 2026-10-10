import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yum_quick/src/core/errors/failures.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';

import '../domain/repositories/recipe_repository.dart';
import 'recipe_event.dart';
import 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipeRepository recipeRepository;
  static const int _pageSize = 10;

  RecipeBloc({required this.recipeRepository}) : super(const RecipeInitial()) {
    on<FetchRecipesReq>(_onFetchRecipes);
    on<RefreshRecipesReq>(_onRefreshRecipes);
    on<LoadMoreRecipesReq>(_onLoadMoreRecipes);
    on<ChangeCategoryReq>(_onChangeCategory);
    on<ToggleFavoriteReq>(_onToggleFavorite);
  }

  RecipeCategory _currentCategory = RecipeCategory.all;

  Future<void> _onFetchRecipes(
    FetchRecipesReq event,
    Emitter<RecipeState> emit,
  ) async {
    _currentCategory = event.category;
    emit(RecipeLoading(category: _currentCategory));

    try {
      final favIds = recipeRepository.getFavoriteRecipeIds();
      final result = await recipeRepository.getRecipes(
        limit: _pageSize,
        skip: 0,
        category: _currentCategory,
      );

      if (result.recipes.isEmpty) {
        emit(RecipeEmpty(category: _currentCategory));
      } else {
        emit(
          RecipeSuccess(
            recipes: result.recipes,
            category: _currentCategory,
            favoriteIds: favIds,
            total: result.total,
            skip: 0,
            hasMore: result.hasMore,
            isOfflineFallback: result.isFromCache,
          ),
        );
      }
    } on Failure catch (e) {
      emit(RecipeError(category: _currentCategory, message: e.message));
    } catch (e) {
      emit(RecipeError(category: _currentCategory, message: e.toString()));
    }
  }

  Future<void> _onRefreshRecipes(
    RefreshRecipesReq event,
    Emitter<RecipeState> emit,
  ) async {
    try {
      final favIds = recipeRepository.getFavoriteRecipeIds();
      final result = await recipeRepository.getRecipes(
        limit: _pageSize,
        skip: 0,
        category: _currentCategory,
      );

      if (result.recipes.isEmpty) {
        emit(RecipeEmpty(category: _currentCategory));
      } else {
        emit(
          RecipeSuccess(
            recipes: result.recipes,
            category: _currentCategory,
            favoriteIds: favIds,
            total: result.total,
            skip: 0,
            hasMore: result.hasMore,
            isOfflineFallback: result.isFromCache,
          ),
        );
      }
    } on Failure catch (e) {
      if (state is! RecipeSuccess) {
        emit(RecipeError(category: _currentCategory, message: e.message));
      }
    }
  }

  Future<void> _onLoadMoreRecipes(
    LoadMoreRecipesReq event,
    Emitter<RecipeState> emit,
  ) async {
    final curr = state;
    if (curr is! RecipeSuccess || curr.isLoadingMore || !curr.hasMore) {
      return;
    }

    emit(curr.copyWith(isLoadingMore: true, paginationError: null));

    try {
      final nextSkip = curr.skip + _pageSize;
      final result = await recipeRepository.getRecipes(
        limit: _pageSize,
        skip: nextSkip,
        category: _currentCategory,
      );

      final combined = [...curr.recipes, ...result.recipes];
      emit(
        curr.copyWith(
          recipes: combined,
          skip: nextSkip,
          hasMore: result.hasMore,
          isLoadingMore: false,
          paginationError: null,
        ),
      );
    } on Failure catch (e) {
      emit(curr.copyWith(isLoadingMore: false, paginationError: e.message));
    } catch (e) {
      emit(
        curr.copyWith(
          isLoadingMore: false,
          paginationError: 'Failed to load more recipes',
        ),
      );
    }
  }

  Future<void> _onChangeCategory(
    ChangeCategoryReq event,
    Emitter<RecipeState> emit,
  ) async {
    if (_currentCategory == event.category && state is RecipeSuccess) {
      return;
    }
    add(FetchRecipesReq(category: event.category));
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteReq event,
    Emitter<RecipeState> emit,
  ) async {
    await recipeRepository.toggleFavorite(event.recipeId);
    final favIds = recipeRepository.getFavoriteRecipeIds();

    if (state is RecipeSuccess) {
      final curr = state as RecipeSuccess;
      emit(curr.copyWith(favoriteIds: favIds));
    }
  }
}
