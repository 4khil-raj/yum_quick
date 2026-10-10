import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yum_quick/src/core/errors/failures.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';

import '../../recipes/domain/entities/recipe_entity.dart';
import '../../recipes/domain/repositories/recipe_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final RecipeRepository recipeRepository;
  List<RecipeEntity> _rawSearchResults = [];

  SearchBloc({required this.recipeRepository}) : super(const SearchInitial()) {
    on<SearchRecipesReq>(_onSearchRecipes);
    on<UpdateFilterReq>(_onUpdateFilter);
    on<ClearFiltersReq>(_onClearFilters);
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
      final result = cleanQuery.isEmpty
          ? await recipeRepository.getRecipes(limit: 30, skip: 0)
          : await recipeRepository.searchRecipes(
              query: cleanQuery,
              limit: 30,
              skip: 0,
            );

      _rawSearchResults = result.recipes;
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
    final newCategory = event.category ?? state.selectedCategory;
    final newSort = event.sortOption ?? state.sortOption;
    final newMaxPrice = event.maxPrice ?? state.maxPrice;
    final newMinRating = event.minRating ?? state.minRating;
    final newTags = event.selectedTags ?? state.selectedTags;

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

    // 1. Filter by category
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

    // 2. Filter by subcategory tags (if any selected)
    if (tags.isNotEmpty) {
      list = list.where((r) {
        final lowerTags = r.tags.map((t) => t.toLowerCase()).toList();
        final lowerName = r.name.toLowerCase();
        return tags.any((tag) {
          final t = tag.toLowerCase();
          return lowerName.contains(t) || lowerTags.any((lt) => lt.contains(t));
        });
      }).toList();
    }

    // 3. Filter by min rating
    if (minStars > 0) {
      list = list.where((r) => r.rating >= minStars).toList();
    }

    // 4. Filter by max price
    list = list.where((r) => r.price <= priceCap).toList();

    // 5. Sort
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
