import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/src/features/cart/state/cart_bloc.dart';
import 'package:yum_quick/src/features/cart/state/cart_state.dart';
import 'package:yum_quick/src/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:yum_quick/src/features/search/presentation/screens/filter_screen.dart';
import 'package:yum_quick/src/features/search/state/search_bloc.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}

class MockCartBloc extends Mock implements CartBloc {}

void main() {
  late MockRecipeRepository mockRecipeRepository;
  late MockCartBloc mockCartBloc;
  late SearchBloc searchBloc;

  setUp(() {
    mockRecipeRepository = MockRecipeRepository();
    mockCartBloc = MockCartBloc();
    when(() => mockCartBloc.state).thenReturn(const CartInitial());
    when(() => mockCartBloc.stream).thenAnswer((_) => const Stream.empty());

    searchBloc = SearchBloc(recipeRepository: mockRecipeRepository);
  });

  tearDown(() {
    searchBloc.close();
  });

  testWidgets('FilterScreen renders all Figma components and interacts properly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<SearchBloc>.value(value: searchBloc),
          BlocProvider<CartBloc>.value(value: mockCartBloc),
        ],
        child: const MaterialApp(home: FilterScreen()),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify Header Title and Back Icon
    expect(find.text('Filter'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

    // 2. Verify Categories section
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Snacks'), findsOneWidget);
    expect(find.text('Meal'), findsOneWidget);
    expect(find.text('Vegan'), findsOneWidget);
    expect(find.text('Dessert'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);

    // 3. Verify Sort by section with stars
    expect(find.text('Sort by'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);

    // 4. Verify initial snacks tags
    expect(find.text('Skewers'), findsOneWidget);
    expect(find.text('Salmon'), findsOneWidget);

    // 5. Switch to "Meal" category
    await tester.tap(find.text('Meal'));
    await tester.pumpAndSettle();

    // Verify Meal tags appear
    expect(find.text('Sushi'), findsOneWidget);
    expect(find.text('Curry'), findsOneWidget);
    expect(find.text('Burger'), findsOneWidget);

    // 6. Verify Price section and Apply button
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('\$1'), findsOneWidget);
    expect(find.text('\$10'), findsOneWidget);
    expect(find.text('\$50'), findsOneWidget);
    expect(find.text('\$100 >'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Apply'), findsOneWidget);

    // 7. Tap Apply button
    final applyButton = find.widgetWithText(ElevatedButton, 'Apply');
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();
  });
}
