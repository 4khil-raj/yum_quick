import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/features/auth/domain/entities/user_entity.dart';
import 'package:yum_quick/features/auth/domain/repositories/auth_repository.dart';
import 'package:yum_quick/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yum_quick/features/cart/domain/repositories/cart_repository.dart';
import 'package:yum_quick/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:yum_quick/features/profile/presentation/screens/profile_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}
class MockCartRepository extends Mock implements CartRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late MockCartRepository mockCartRepository;
  late AuthBloc authBloc;
  late CartBloc cartBloc;

  final testUser = const UserEntity(
    id: 1,
    username: 'emilys',
    email: 'emilys@email.com',
    firstName: 'Emily',
    lastName: 'Smith',
    accessToken: 'test_token',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockCartRepository = MockCartRepository();

    when(() => mockAuthRepository.getSavedUsername())
        .thenAnswer((_) async => 'emilys');
    when(() => mockAuthRepository.restoreSession())
        .thenAnswer((_) async => testUser);
    when(() => mockAuthRepository.logout())
        .thenAnswer((_) async {});
    when(() => mockCartRepository.getCartItems())
        .thenAnswer((_) async => []);
    when(() => mockCartRepository.clearCart())
        .thenAnswer((_) async {});

    authBloc = AuthBloc(authRepository: mockAuthRepository);
    cartBloc = CartBloc(cartRepository: mockCartRepository);
  });

  tearDown(() {
    authBloc.close();
    cartBloc.close();
  });

  testWidgets('Clicking Log Out shows confirmation popup with Cancel and Yes buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<CartBloc>.value(value: cartBloc),
        ],
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final logoutMenuItem = find.text('Log Out');
    expect(logoutMenuItem, findsOneWidget);

    await tester.tap(logoutMenuItem);
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to log out from YumQuick?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Yes, Log Out'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to log out from YumQuick?'), findsNothing);
    verifyNever(() => mockAuthRepository.logout());
  });
}
