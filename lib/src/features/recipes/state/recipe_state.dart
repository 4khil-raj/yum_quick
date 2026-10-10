import 'package:equatable/equatable.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';

import '../domain/entities/recipe_entity.dart';

sealed class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

class RecipeLoading extends RecipeState {
  final RecipeCategory category;

  const RecipeLoading({this.category = RecipeCategory.all});

  @override
  List<Object?> get props => [category];
}

class RecipeSuccess extends RecipeState {
  final List<RecipeEntity> recipes;
  final RecipeCategory category;
  final Set<int> favoriteIds;
  final int total;
  final int skip;
  final bool hasMore;
  final bool isOfflineFallback;
  final bool isLoadingMore;
  final String? paginationError;

  const RecipeSuccess({
    required this.recipes,
    required this.category,
    required this.favoriteIds,
    required this.total,
    required this.skip,
    required this.hasMore,
    this.isOfflineFallback = false,
    this.isLoadingMore = false,
    this.paginationError,
  });

  RecipeSuccess copyWith({
    List<RecipeEntity>? recipes,
    RecipeCategory? category,
    Set<int>? favoriteIds,
    int? total,
    int? skip,
    bool? hasMore,
    bool? isOfflineFallback,
    bool? isLoadingMore,
    String? paginationError,
  }) {
    return RecipeSuccess(
      recipes: recipes ?? this.recipes,
      category: category ?? this.category,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      total: total ?? this.total,
      skip: skip ?? this.skip,
      hasMore: hasMore ?? this.hasMore,
      isOfflineFallback: isOfflineFallback ?? this.isOfflineFallback,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: paginationError,
    );
  }

  @override
  List<Object?> get props => [
    recipes,
    category,
    favoriteIds,
    total,
    skip,
    hasMore,
    isOfflineFallback,
    isLoadingMore,
    paginationError,
  ];
}

class RecipeEmpty extends RecipeState {
  final RecipeCategory category;
  final String message;

  const RecipeEmpty({
    required this.category,
    this.message = 'No recipes found for this category.',
  });

  @override
  List<Object?> get props => [category, message];
}

class RecipeError extends RecipeState {
  final RecipeCategory category;
  final String message;

  const RecipeError({required this.category, required this.message});

  @override
  List<Object?> get props => [category, message];
}
