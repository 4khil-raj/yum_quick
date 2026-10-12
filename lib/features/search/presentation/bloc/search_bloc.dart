import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yum_quick/core/errors/failures.dart';
import 'package:yum_quick/core/utils/category_mapper.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/features/recipes/domain/repositories/recipe_repository.dart';

import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final RecipeRepository recipeRepository;
  List<RecipeEntity> _rawSearchResults = [];
  List<RecipeEntity> _allCatalog = [];

  SearchBloc({required this.recipeRepository}) : super(const SearchInitial()) {
    on<SearchRecipesReq>(_onSearchRecipes);
    on<UpdateFilterReq>(_onUpdateFilter);
    on<ClearFiltersReq>(_onClearFilters);
  }

  Future<void> _ensureCatalogLoaded() async {
    if (_allCatalog.isEmpty) {
      final res = await recipeRepository.getRecipes(limit: 50, skip: 0);
      _allCatalog = res.recipes;
    }
  }

  Future<void> _onSearchRecipes(
    SearchRecipesReq event,
    Emitter<SearchState> emit,
  ) async {
    final cleanQuery = event.query.trim();

    emit(
      SearchLoading(
        query: cleanQuery,
        selectedCategory: state.selectedCategory,
        sortOption: state.sortOption,
        maxPrice: state.maxPrice,
      ),
    );

    try {
      await _ensureCatalogLoaded();

      if (cleanQuery.isEmpty) {
        _rawSearchResults = _allCatalog;
      } else {
        List<RecipeEntity> remoteList = [];
        try {
          final remoteResult = await recipeRepository.searchRecipes(
            query: cleanQuery,
            limit: 50,
            skip: 0,
          );
          remoteList = remoteResult.recipes;
        } catch (_) {}

        final q = cleanQuery.toLowerCase();
        final localMatches = _allCatalog.where((r) {
          final matchName = r.name.toLowerCase().contains(q);
          final matchCuisine = r.cuisine.toLowerCase().contains(q);
          final matchMealType =
              r.mealType.any((m) => m.toLowerCase().contains(q));
          final matchTags = r.tags.any((t) => t.toLowerCase().contains(q));
          final matchIngredients =
              r.ingredients.any((i) => i.toLowerCase().contains(q));
          return matchName ||
              matchCuisine ||
              matchMealType ||
              matchTags ||
              matchIngredients;
        }).toList();

        final seenIds = <int>{};
        final combined = <RecipeEntity>[];
        for (final r in [...remoteList, ...localMatches]) {
          if (seenIds.add(r.id)) {
            combined.add(r);
          }
        }
        _rawSearchResults = combined;
      }

      _applyFiltersAndEmit(emit);
    } on Failure catch (e) {
      emit(
        SearchError(
          message: e.message,
          query: cleanQuery,
          selectedCategory: state.selectedCategory,
          sortOption: state.sortOption,
          maxPrice: state.maxPrice,
        ),
      );
    } catch (e) {
      emit(
        SearchError(
          message: e.toString(),
          query: cleanQuery,
          selectedCategory: state.selectedCategory,
          sortOption: state.sortOption,
          maxPrice: state.maxPrice,
        ),
      );
    }
  }

  void _onUpdateFilter(UpdateFilterReq event, Emitter<SearchState> emit) {
    final isCategoryChanged =
        event.category != null && event.category != state.selectedCategory;
    final newCategory = event.category ?? state.selectedCategory;
    final newSort = event.sortOption ?? state.sortOption;
    final newMaxPrice = event.maxPrice ?? state.maxPrice;
    final newMinRating = event.minRating ?? state.minRating;
    final newTags = event.selectedTags ??
        (isCategoryChanged ? const <String>{} : state.selectedTags);

    _applyFiltersAndEmit(
      emit,
      category: newCategory,
      sort: newSort,
      maxPrice: newMaxPrice,
      minRating: newMinRating,
      selectedTags: newTags,
    );
  }

  void _onClearFilters(ClearFiltersReq event, Emitter<SearchState> emit) {
    _applyFiltersAndEmit(
      emit,
      category: RecipeCategory.all,
      sort: SortOption.relevance,
      maxPrice: 500.0,
      minRating: 0.0,
      selectedTags: const {},
    );
  }

  void _applyFiltersAndEmit(
    Emitter<SearchState> emit, {
    RecipeCategory? category,
    SortOption? sort,
    double? maxPrice,
    double? minRating,
    Set<String>? selectedTags,
  }) {
    final cat = category ?? state.selectedCategory;
    final s = sort ?? state.sortOption;
    final priceCap = maxPrice ?? state.maxPrice;
    final minStars = minRating ?? state.minRating;
    final tags = selectedTags ?? state.selectedTags;

    if (_rawSearchResults.isEmpty &&
        _allCatalog.isNotEmpty &&
        state.query.isEmpty) {
      _rawSearchResults = _allCatalog;
    }

    var list = cat == RecipeCategory.all
        ? _rawSearchResults
        : _rawSearchResults
              .where(
                (r) => CategoryMapper.matchesCategory(
                  category: cat,
                  mealTypes: r.mealType,
                  tags: r.tags,
                ),
              )
              .toList();

    if (tags.isNotEmpty) {
      list = list.where((r) {
        final lowerTags = r.tags.map((t) => t.toLowerCase()).toList();
        final lowerName = r.name.toLowerCase();
        final lowerIngredients =
            r.ingredients.map((i) => i.toLowerCase()).toList();
        return tags.any((tag) {
          final t = tag.toLowerCase();
          return lowerName.contains(t) ||
              lowerTags.any((lt) => lt.contains(t)) ||
              lowerIngredients.any((li) => li.contains(t));
        });
      }).toList();
    }

    if (minStars > 0) {
      list = list.where((r) => r.rating >= minStars).toList();
    }

    if (priceCap < 500.0) {
      list = list.where((r) => r.price <= priceCap).toList();
    }

    final sorted = List<RecipeEntity>.from(list);
    switch (s) {
      case SortOption.ratingHighToLow:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.timeFastest:
        sorted.sort((a, b) => a.totalTimeMinutes.compareTo(b.totalTimeMinutes));
        break;
      case SortOption.relevance:
        break;
    }

    if (sorted.isEmpty) {
      emit(
        SearchEmpty(
          query: state.query,
          selectedCategory: cat,
          sortOption: s,
          maxPrice: priceCap,
          minRating: minStars,
          selectedTags: tags,
        ),
      );
    } else {
      emit(
        SearchSuccess(
          results: sorted,
          totalCount: sorted.length,
          query: state.query,
          selectedCategory: cat,
          sortOption: s,
          maxPrice: priceCap,
          minRating: minStars,
          selectedTags: tags,
        ),
      );
    }
  }
}
