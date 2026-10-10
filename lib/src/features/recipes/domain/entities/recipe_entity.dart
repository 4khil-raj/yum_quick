import 'package:equatable/equatable.dart';
import 'package:yum_quick/src/core/utils/pricing_calculator.dart';

class RecipeEntity extends Equatable {
  final int id;
  final String name;
  final String image;
  final double rating;
  final int reviewCount;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tags;
  final List<String> mealType;
  final String cuisine;
  final int servings;
  final int caloriesPerServing;
  final String difficulty;

  const RecipeEntity({
    required this.id,
    required this.name,
    required this.image,
    required this.rating,
    required this.reviewCount,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.ingredients,
    required this.instructions,
    required this.tags,
    required this.mealType,
    required this.cuisine,
    required this.servings,
    required this.caloriesPerServing,
    required this.difficulty,
  });

  /// Deterministic price for this recipe
  double get price => PricingCalculator.priceForRecipe(id);

  /// Total time in minutes (prep + cook)
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    rating,
    reviewCount,
    prepTimeMinutes,
    cookTimeMinutes,
    ingredients,
    instructions,
    tags,
    mealType,
    cuisine,
    servings,
    caloriesPerServing,
    difficulty,
  ];
}
