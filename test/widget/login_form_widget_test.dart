import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/features/auth/domain/repositories/auth_repository.dart';
import 'package:yum_quick/features/auth/presentation/screens/login_screen.dart';
import 'package:yum_quick/features/auth/presentation/bloc/auth_bloc.dart';

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

    expect(find.text('Log In'), findsWidgets);
    expect(find.byType(TextFormField), findsNWidgets(2));

    final usernameField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;

    await tester.enterText(usernameField, '');
    await tester.enterText(passwordField, '');
    await tester.pumpAndSettle();

    final loginButton = find.widgetWithText(ElevatedButton, 'Log In');
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('Please enter your username'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);

    await tester.enterText(usernameField, 'emilys');
    await tester.enterText(passwordField, 'emilyspass');
    await tester.pumpAndSettle();

    expect(find.text('emilys'), findsOneWidget);
    expect(find.text('emilyspass'), findsOneWidget);
  });
}
