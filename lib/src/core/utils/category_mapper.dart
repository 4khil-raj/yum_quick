import '../constants/app_assets.dart';

enum RecipeCategory {
  all('All', 'All', ''),
  snacks('Snacks', 'Snacks', AppAssets.icSnacks),
  meal('Meal', 'Meal', AppAssets.icKnifeFork),
  vegan('Vegan', 'Vegan', AppAssets.icVegetables),
  dessert('Dessert', 'Dessert', AppAssets.icDesserts),
  drinks('Drinks', 'Drinks', AppAssets.icBeverages);

  final String id;
  final String label;
  final String iconPath;

  const RecipeCategory(this.id, this.label, this.iconPath);

  static RecipeCategory fromString(String? val) {
    if (val == null) return RecipeCategory.all;
    final lower = val.trim().toLowerCase();
    for (final cat in RecipeCategory.values) {
      if (cat.name.toLowerCase() == lower || cat.label.toLowerCase() == lower) {
        return cat;
      }
    }
    return RecipeCategory.all;
  }
}

class CategoryMapper {
  CategoryMapper._();

  /// Determines whether a recipe belongs to a specific category
  /// based on its mealType list and tags list from DummyJSON.
  static bool matchesCategory({
    required RecipeCategory category,
    required List<String> mealTypes,
    required List<String> tags,
  }) {
    if (category == RecipeCategory.all) return true;

    final lowerMealTypes = mealTypes.map((e) => e.toLowerCase()).toList();
    final lowerTags = tags.map((e) => e.toLowerCase()).toList();

    switch (category) {
      case RecipeCategory.snacks:
        return lowerMealTypes.any(
              (m) => m.contains('snack') || m.contains('appetizer'),
            ) ||
            lowerTags.any(
              (t) =>
                  t.contains('snack') ||
                  t.contains('appetizer') ||
                  t.contains('finger food') ||
                  t.contains('dip'),
            );

      case RecipeCategory.meal:
        return lowerMealTypes.any(
              (m) =>
                  m.contains('dinner') ||
                  m.contains('lunch') ||
                  m.contains('breakfast'),
            ) ||
            lowerTags.any(
              (t) =>
                  t.contains('dinner') ||
                  t.contains('lunch') ||
                  t.contains('main') ||
                  t.contains('pasta') ||
                  t.contains('pizza') ||
                  t.contains('curry') ||
                  t.contains('chicken') ||
                  t.contains('beef'),
            );

      case RecipeCategory.vegan:
        return lowerTags.any(
          (t) =>
              t.contains('vegan') ||
              t.contains('vegetarian') ||
              t.contains('plant-based'),
        );

      case RecipeCategory.dessert:
        return lowerMealTypes.any((m) => m.contains('dessert')) ||
            lowerTags.any(
              (t) =>
                  t.contains('dessert') ||
                  t.contains('cake') ||
                  t.contains('cookie') ||
                  t.contains('sweet') ||
                  t.contains('chocolate') ||
                  t.contains('baking') ||
                  t.contains('pudding') ||
                  t.contains('ice cream'),
            );

      case RecipeCategory.drinks:
        return lowerMealTypes.any(
              (m) => m.contains('beverage') || m.contains('drink'),
            ) ||
            lowerTags.any(
              (t) =>
                  t.contains('drink') ||
                  t.contains('beverage') ||
                  t.contains('smoothie') ||
                  t.contains('cocktail') ||
                  t.contains('juice') ||
                  t.contains('shake') ||
                  t.contains('tea') ||
                  t.contains('coffee'),
            );

      case RecipeCategory.all:
        return true;
    }
  }
}
