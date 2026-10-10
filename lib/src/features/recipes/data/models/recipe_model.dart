import '../../domain/entities/recipe_entity.dart';

class RecipeModel extends RecipeEntity {
  const RecipeModel({
    required super.id,
    required super.name,
    required super.image,
    required super.rating,
    required super.reviewCount,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.ingredients,
    required super.instructions,
    required super.tags,
    required super.mealType,
    required super.cuisine,
    required super.servings,
    required super.caloriesPerServing,
    required super.difficulty,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] as int? ?? 0,
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 15,
      cookTimeMinutes: json['cookTimeMinutes'] as int? ?? 15,
      ingredients:
          (json['ingredients'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      instructions:
          (json['instructions'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      mealType:
          (json['mealType'] as List?)?.map((e) => e.toString()).toList() ?? [],
      cuisine: json['cuisine'] as String? ?? 'General',
      servings: json['servings'] as int? ?? 1,
      caloriesPerServing: json['caloriesPerServing'] as int? ?? 250,
      difficulty: json['difficulty'] as String? ?? 'Easy',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'rating': rating,
      'reviewCount': reviewCount,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'ingredients': ingredients,
      'instructions': instructions,
      'tags': tags,
      'mealType': mealType,
      'cuisine': cuisine,
      'servings': servings,
      'caloriesPerServing': caloriesPerServing,
      'difficulty': difficulty,
    };
  }

  RecipeEntity toEntity() => this;
}
