import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_state.dart';
import 'package:yum_quick/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:yum_quick/features/search/presentation/screens/filter_screen.dart';
import 'package:yum_quick/features/search/presentation/bloc/search_bloc.dart';

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

    expect(find.text('Filter'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Snacks'), findsOneWidget);
    expect(find.text('Meal'), findsOneWidget);
    expect(find.text('Vegan'), findsOneWidget);
    expect(find.text('Dessert'), findsOneWidget);
    expect(find.text('Drinks'), findsOneWidget);

    expect(find.text('Sort by'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);

    expect(find.text('Skewers'), findsOneWidget);
    expect(find.text('Salmon'), findsOneWidget);

    await tester.tap(find.text('Meal'));
    await tester.pumpAndSettle();

    expect(find.text('Sushi'), findsOneWidget);
    expect(find.text('Curry'), findsOneWidget);
    expect(find.text('Burger'), findsOneWidget);

    expect(find.text('Price'), findsOneWidget);
    expect(find.text('₹99'), findsOneWidget);
    expect(find.text('₹199'), findsOneWidget);
    expect(find.text('₹299'), findsOneWidget);
    expect(find.text('₹499 >'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Apply'), findsOneWidget);

    final applyButton = find.widgetWithText(ElevatedButton, 'Apply');
    await tester.ensureVisible(applyButton);
    await tester.tap(applyButton);
    await tester.pumpAndSettle();
  });
}
