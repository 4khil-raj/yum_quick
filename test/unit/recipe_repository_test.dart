import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/src/core/errors/exceptions.dart';
import 'package:yum_quick/src/core/errors/failures.dart';
import 'package:yum_quick/src/core/utils/category_mapper.dart';
import 'package:yum_quick/src/features/recipes/data/datasources/recipe_local_data_source.dart';
import 'package:yum_quick/src/features/recipes/data/datasources/recipe_remote_data_source.dart';
import 'package:yum_quick/src/features/recipes/data/models/recipe_model.dart';
import 'package:yum_quick/src/features/recipes/data/repositories/recipe_repository_impl.dart';

class MockRecipeRemoteDataSource extends Mock
    implements RecipeRemoteDataSource {}

class MockRecipeLocalDataSource extends Mock implements RecipeLocalDataSource {}

void main() {
  late MockRecipeRemoteDataSource mockRemoteDataSource;
  late MockRecipeLocalDataSource mockLocalDataSource;
  late RecipeRepositoryImpl repository;

  final sampleRecipeModel = RecipeModel(
    id: 1,
    name: 'Classic Margherita Pizza',
    image: 'https://cdn.dummyjson.com/recipe-images/1.webp',
    rating: 4.6,
    reviewCount: 98,
    prepTimeMinutes: 20,
    cookTimeMinutes: 15,
    ingredients: const ['Pizza dough', 'Tomato sauce', 'Mozzarella cheese'],
    instructions: const [
      'Preheat oven',
      'Roll dough',
      'Bake until crust is golden',
    ],
    tags: const ['Pizza', 'Italian', 'Vegetarian'],
    mealType: const ['Dinner'],
    cuisine: 'Italian',
    servings: 4,
    caloriesPerServing: 300,
    difficulty: 'Easy',
  );

  final sampleRawResponse = {
    'recipes': [sampleRecipeModel.toJson()],
    'total': 50,
    'skip': 0,
    'limit': 10,
  };

  setUp(() {
    mockRemoteDataSource = MockRecipeRemoteDataSource();
    mockLocalDataSource = MockRecipeLocalDataSource();
    repository = RecipeRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('RecipeRepository Tests', () {
    test(
      'getRecipes returns remote recipes and caches first page on success',
      () async {
        when(() => mockRemoteDataSource.fetchRecipesRaw(limit: 10, skip: 0))
            .thenAnswer((_) async => sampleRawResponse);
        when(() => mockLocalDataSource.cacheFirstPageRecipes(sampleRawResponse))
            .thenAnswer((_) async => Future.value());

        final result = await repository.getRecipes(limit: 10, skip: 0);

        expect(result.recipes.length, equals(1));
        expect(result.recipes.first.name, equals('Classic Margherita Pizza'));
        expect(result.total, equals(50));
        expect(result.isFromCache, isFalse);
        verify(
          () => mockLocalDataSource.cacheFirstPageRecipes(sampleRawResponse),
        ).called(1);
      },
    );

    test('getRecipes falls back to cached recipes when offline/NetworkException occurs', () async {
      when(() => mockRemoteDataSource.fetchRecipesRaw(limit: 10, skip: 0))
          .thenThrow(const NetworkException('No connection'));
      when(() => mockLocalDataSource.getCachedFirstPageRecipes())
          .thenReturn([sampleRecipeModel]);

      final result = await repository.getRecipes(limit: 10, skip: 0);

      expect(result.recipes.length, equals(1));
      expect(result.isFromCache, isTrue);
      expect(result.recipes.first.name, equals('Classic Margherita Pizza'));
    });

    test(
      'getRecipes throws ServerFailure when server fails and cache is empty',
      () async {
        when(() => mockRemoteDataSource.fetchRecipesRaw(limit: 10, skip: 0))
            .thenThrow(
              const ServerException('Internal Server Error', statusCode: 500),
            );
        when(() => mockLocalDataSource.getCachedFirstPageRecipes())
            .thenReturn([]);

        expect(
          () => repository.getRecipes(limit: 10, skip: 0),
          throwsA(isA<ServerFailure>()),
        );
      },
    );

    test('getRecipeById returns mapped RecipeEntity', () async {
      when(() => mockRemoteDataSource.fetchRecipeById(1))
          .thenAnswer((_) async => sampleRecipeModel);

      final recipe = await repository.getRecipeById(1);

      expect(recipe.id, equals(1));
      expect(recipe.name, equals('Classic Margherita Pizza'));
      expect(recipe.price, equals(sampleRecipeModel.price));
    });

    test('filters recipes by category correctly', () async {
      when(() => mockRemoteDataSource.fetchRecipesRaw(limit: 10, skip: 0))
          .thenAnswer((_) async => sampleRawResponse);
      when(() => mockLocalDataSource.cacheFirstPageRecipes(sampleRawResponse))
          .thenAnswer((_) async => Future.value());

      // Category Meal should match Dinner
      final mealResult = await repository.getRecipes(
        limit: 10,
        skip: 0,
        category: RecipeCategory.meal,
      );
      expect(mealResult.recipes.length, equals(1));

      // Category Drinks should NOT match Dinner Pizza
      final drinksResult = await repository.getRecipes(
        limit: 10,
        skip: 0,
        category: RecipeCategory.drinks,
      );
      expect(drinksResult.recipes.length, equals(0));
    });
  });
}
