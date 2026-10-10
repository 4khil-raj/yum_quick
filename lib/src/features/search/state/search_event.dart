import 'package:equatable/equatable.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';

enum SortOption {
  relevance('Relevance'),
  ratingHighToLow('Top Rated'),
  priceLowToHigh('Price: Low to High'),
  priceHighToLow('Price: High to Low'),
  timeFastest('Fastest Prep');

  final String label;
  const SortOption(this.label);
}

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchRecipesReq extends SearchEvent {
  final String query;

  const SearchRecipesReq(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateFilterReq extends SearchEvent {
  final RecipeCategory? category;
  final SortOption? sortOption;
  final double? maxPrice;
  final double? minRating;
  final Set<String>? selectedTags;

  const UpdateFilterReq({
    this.category,
    this.sortOption,
    this.maxPrice,
    this.minRating,
    this.selectedTags,
  });

  @override
  List<Object?> get props => [
    category,
    sortOption,
    maxPrice,
    minRating,
    selectedTags,
  ];
}

class ClearFiltersReq extends SearchEvent {
  const ClearFiltersReq();
}
