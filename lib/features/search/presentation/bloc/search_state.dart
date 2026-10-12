import 'package:equatable/equatable.dart';
import 'package:yum_quick/core/utils/category_mapper.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';

import 'search_event.dart';

sealed class SearchState extends Equatable {
  final String query;
  final RecipeCategory selectedCategory;
  final SortOption sortOption;
  final double maxPrice;
  final double minRating;
  final Set<String> selectedTags;

  const SearchState({
    this.query = '',
    this.selectedCategory = RecipeCategory.all,
    this.sortOption = SortOption.relevance,
    this.maxPrice = 500.0,
    this.minRating = 0.0,
    this.selectedTags = const {},
  });

  @override
  List<Object?> get props => [
    query,
    selectedCategory,
    sortOption,
    maxPrice,
    minRating,
    selectedTags,
  ];
}

class SearchInitial extends SearchState {
  const SearchInitial({
    super.query,
    super.selectedCategory,
    super.sortOption,
    super.maxPrice,
    super.minRating,
    super.selectedTags,
  });
}

class SearchLoading extends SearchState {
  const SearchLoading({
    required super.query,
    required super.selectedCategory,
    required super.sortOption,
    required super.maxPrice,
    super.minRating,
    super.selectedTags,
  });
}

class SearchSuccess extends SearchState {
  final List<RecipeEntity> results;
  final int totalCount;

  const SearchSuccess({
    required this.results,
    required this.totalCount,
    required super.query,
    required super.selectedCategory,
    required super.sortOption,
    required super.maxPrice,
    super.minRating,
    super.selectedTags,
  });

  @override
  List<Object?> get props => [
    results,
    totalCount,
    query,
    selectedCategory,
    sortOption,
    maxPrice,
    minRating,
    selectedTags,
  ];
}

class SearchEmpty extends SearchState {
  const SearchEmpty({
    required super.query,
    required super.selectedCategory,
    required super.sortOption,
    required super.maxPrice,
    super.minRating,
    super.selectedTags,
  });
}

class SearchError extends SearchState {
  final String message;

  const SearchError({
    required this.message,
    required super.query,
    required super.selectedCategory,
    required super.sortOption,
    required super.maxPrice,
    super.minRating,
    super.selectedTags,
  });

  @override
  List<Object?> get props => [
    message,
    query,
    selectedCategory,
    sortOption,
    maxPrice,
    minRating,
    selectedTags,
  ];
}
