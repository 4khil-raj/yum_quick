import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:yum_quick/src/features/auth/presentation/screens/login_screen.dart';
import 'package:yum_quick/src/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.getSavedUsername())
        .thenAnswer((_) async => null);
    when(() => mockAuthRepository.restoreSession())
        .thenAnswer((_) async => null);

    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  testWidgets('LoginScreen renders inputs and validates empty credentials', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and elements
    expect(find.text('Sign In'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Clear username and password
    final usernameField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;

    await tester.enterText(usernameField, '');
    await tester.enterText(passwordField, '');
    await tester.pumpAndSettle();

    // Tap Sign In button
    final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
    await tester.tap(signInButton);
    await tester.pumpAndSettle();

    // Verify validation errors appear
    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    // Tap demo pill button to auto-fill
    final demoPill = find.text('Fill Demo: emilys / emilyspass');
    expect(demoPill, findsOneWidget);
    await tester.tap(demoPill);
    await tester.pumpAndSettle();

    // Check that values are filled
    expect(find.text('emilys'), findsOneWidget);
    expect(find.text('emilyspass'), findsOneWidget);
  });
}
