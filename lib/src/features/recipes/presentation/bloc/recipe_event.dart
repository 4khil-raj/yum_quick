import 'package:equatable/equatable.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';

sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

class FetchRecipesReq extends RecipeEvent {
  final RecipeCategory category;

  const FetchRecipesReq({this.category = RecipeCategory.all});

  @override
  List<Object?> get props => [category];
}

class RefreshRecipesReq extends RecipeEvent {
  const RefreshRecipesReq();
}

class LoadMoreRecipesReq extends RecipeEvent {
  const LoadMoreRecipesReq();
}

class ChangeCategoryReq extends RecipeEvent {
  final RecipeCategory category;

  const ChangeCategoryReq(this.category);

  @override
  List<Object?> get props => [category];
}

class ToggleFavoriteReq extends RecipeEvent {
  final int recipeId;

  const ToggleFavoriteReq(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}
