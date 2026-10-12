import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/core/utils/category_mapper.dart';
import 'package:yum_quick/features/recipes/domain/entities/recipe_entity.dart';
import 'package:yum_quick/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_bloc.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_event.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_state.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  late MockRecipeRepository mockRepository;
  late SearchBloc searchBloc;

  const sampleRecipes = [
    RecipeEntity(
      id: 1,
      name: 'Classic Margherita Pizza',
      image: 'https://example.com/pizza.jpg',
      rating: 4.6,
      reviewCount: 98,
      prepTimeMinutes: 20,
      cookTimeMinutes: 15,
      ingredients: ['Pizza dough', 'Tomato sauce', 'Mozzarella'],
      instructions: ['Bake'],
      tags: ['Pizza', 'Italian'],
      mealType: ['Dinner'],
      cuisine: 'Italian',
      servings: 4,
      caloriesPerServing: 300,
      difficulty: 'Easy',
    ),
    RecipeEntity(
      id: 3,
      name: 'Chocolate Chip Cookies',
      image: 'https://example.com/cookies.jpg',
      rating: 4.9,
      reviewCount: 120,
      prepTimeMinutes: 15,
      cookTimeMinutes: 10,
      ingredients: ['Flour', 'Chocolate chips', 'Butter'],
      instructions: ['Bake'],
      tags: ['Cookies', 'Dessert', 'Baking'],
      mealType: ['Snack', 'Dessert'],
      cuisine: 'American',
      servings: 12,
      caloriesPerServing: 180,
      difficulty: 'Easy',
    ),
    RecipeEntity(
      id: 7,
      name: 'Tomato Basil Bruschetta',
      image: 'https://example.com/bruschetta.jpg',
      rating: 4.7,
      reviewCount: 45,
      prepTimeMinutes: 10,
      cookTimeMinutes: 5,
      ingredients: ['Baguette', 'Tomatoes', 'Basil', 'Olive oil'],
      instructions: ['Toast and top'],
      tags: ['Bruschetta', 'Italian'],
      mealType: ['Appetizer'],
      cuisine: 'Italian',
      servings: 4,
      caloriesPerServing: 120,
      difficulty: 'Easy',
    ),
    RecipeEntity(
      id: 29,
      name: 'Lebanese Falafel Wrap',
      image: 'https://example.com/falafel.jpg',
      rating: 4.7,
      reviewCount: 88,
      prepTimeMinutes: 20,
      cookTimeMinutes: 10,
      ingredients: ['Chickpeas', 'Tahini', 'Pita'],
      instructions: ['Fry and wrap'],
      tags: ['Falafel', 'Lebanese', 'Wrap'],
      mealType: ['Lunch'],
      cuisine: 'Lebanese',
      servings: 2,
      caloriesPerServing: 350,
      difficulty: 'Medium',
    ),
    RecipeEntity(
      id: 22,
      name: 'Mango Lassi',
      image: 'https://example.com/lassi.jpg',
      rating: 4.7,
      reviewCount: 65,
      prepTimeMinutes: 5,
      cookTimeMinutes: 0,
      ingredients: ['Mango', 'Yogurt', 'Cardamom'],
      instructions: ['Blend'],
      tags: ['Lassi', 'Mango', 'Indian'],
      mealType: ['Beverage'],
      cuisine: 'Indian',
      servings: 2,
      caloriesPerServing: 190,
      difficulty: 'Easy',
    ),
  ];

  setUpAll(() {
    registerFallbackValue(RecipeCategory.all);
  });

  setUp(() {
    mockRepository = MockRecipeRepository();
    when(
      () => mockRepository.getRecipes(
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
        category: any(named: 'category'),
      ),
    ).thenAnswer(
      (_) async => const RecipeListResult(
        recipes: sampleRecipes,
        total: 5,
        skip: 0,
        limit: 50,
        isFromCache: false,
      ),
    );

    when(
      () => mockRepository.searchRecipes(
        query: any(named: 'query'),
        limit: any(named: 'limit'),
        skip: any(named: 'skip'),
      ),
    ).thenAnswer((invocation) async {
      final q = (invocation.namedArguments[#query] as String).toLowerCase();
      final filtered = sampleRecipes
          .where(
            (r) =>
                r.name.toLowerCase().contains(q) ||
                r.ingredients.any((i) => i.toLowerCase().contains(q)),
          )
          .toList();
      return RecipeListResult(
        recipes: filtered,
        total: filtered.length,
        skip: 0,
        limit: 50,
        isFromCache: false,
      );
    });

    searchBloc = SearchBloc(recipeRepository: mockRepository);
  });

  tearDown(() {
    searchBloc.close();
  });

  test('Initial state is SearchInitial', () {
    expect(searchBloc.state, isA<SearchInitial>());
  });

  test('SearchRecipesReq with empty query loads all recipes and emits SearchSuccess', () async {
    searchBloc.add(const SearchRecipesReq(''));

    await expectLater(
      searchBloc.stream,
      emitsInOrder([
        isA<SearchLoading>(),
        predicate<SearchSuccess>((state) => state.results.length == 5),
      ]),
    );
  });

  test('Filter by Category snacks correctly returns snack recipes', () async {
    searchBloc.add(const SearchRecipesReq(''));
    await expectLater(
      searchBloc.stream,
      emitsThrough(isA<SearchSuccess>()),
    );

    searchBloc.add(const UpdateFilterReq(category: RecipeCategory.snacks));
    await expectLater(
      searchBloc.stream,
      emits(
        predicate<SearchSuccess>((state) {
          return state.selectedCategory == RecipeCategory.snacks &&
              state.results.length == 2 &&
              state.results.any((r) => r.name.contains('Bruschetta')) &&
              state.results.any((r) => r.name.contains('Cookies'));
        }),
      ),
    );
  });

  test('Switching category automatically clears subcategory tags', () async {
    searchBloc.add(const SearchRecipesReq(''));
    await expectLater(searchBloc.stream, emitsThrough(isA<SearchSuccess>()));

    searchBloc.add(
      const UpdateFilterReq(
        category: RecipeCategory.snacks,
        selectedTags: {'Bruschetta'},
      ),
    );

    await expectLater(
      searchBloc.stream,
      emits(
        predicate<SearchSuccess>((state) {
          return state.results.length == 1 &&
              state.results.first.name == 'Tomato Basil Bruschetta';
        }),
      ),
    );

    searchBloc.add(const UpdateFilterReq(category: RecipeCategory.meal));

    await expectLater(
      searchBloc.stream,
      emits(
        predicate<SearchSuccess>((state) {
          return state.selectedCategory == RecipeCategory.meal &&
              state.selectedTags.isEmpty &&
              state.results.length == 2 &&
              state.results.any((r) => r.name.contains('Pizza'));
        }),
      ),
    );
  });

  test('Search query matches cuisine and ingredients', () async {
    searchBloc.add(const SearchRecipesReq('Italian'));

    await expectLater(
      searchBloc.stream,
      emitsInOrder([
        isA<SearchLoading>(),
        predicate<SearchSuccess>((state) {
          return state.results.length == 2 &&
              state.results.any((r) => r.name.contains('Pizza')) &&
              state.results.any((r) => r.name.contains('Bruschetta'));
        }),
      ]),
    );
  });

  test('ClearFiltersReq resets category, rating, tags, and price', () async {
    searchBloc.add(const SearchRecipesReq(''));
    await expectLater(searchBloc.stream, emitsThrough(isA<SearchSuccess>()));

    searchBloc.add(
      const UpdateFilterReq(
        category: RecipeCategory.vegan,
        minRating: 4.5,
        maxPrice: 400,
        selectedTags: {'Falafel'},
      ),
    );

    await expectLater(searchBloc.stream, emitsThrough(isA<SearchSuccess>()));

    searchBloc.add(const ClearFiltersReq());

    await expectLater(
      searchBloc.stream,
      emits(
        predicate<SearchSuccess>((state) {
          return state.selectedCategory == RecipeCategory.all &&
              state.minRating == 0.0 &&
              state.maxPrice == 500.0 &&
              state.selectedTags.isEmpty &&
              state.results.length == 5;
        }),
      ),
    );
  });
}
