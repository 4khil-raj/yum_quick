import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:yum_quick/core/errors/failures.dart';
import 'package:yum_quick/features/auth/domain/entities/user_entity.dart';
import 'package:yum_quick/features/auth/domain/repositories/auth_repository.dart';
import 'package:yum_quick/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:yum_quick/features/auth/presentation/bloc/auth_event.dart';
import 'package:yum_quick/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthBloc authBloc;

  const testUser = UserEntity(
    id: 1,
    username: 'emilys',
    email: 'emilys@example.com',
    firstName: 'Emily',
    lastName: 'Smith',
    image: 'https://example.com/avatar.png',
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(authRepository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  test('Initial state is AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  test('CheckAuthSessionReq emits Authenticated when session is restored', () async {
    when(() => mockAuthRepository.getSavedUsername())
        .thenAnswer((_) async => 'emilys');
    when(() => mockAuthRepository.restoreSession())
        .thenAnswer((_) async => testUser);

    authBloc.add(const CheckAuthSessionReq());

    await expectLater(
      authBloc.stream,
      emits(predicate<Authenticated>((state) => state.user == testUser)),
    );
  });

  test('CheckAuthSessionReq emits Unauthenticated when session is null', () async {
    when(() => mockAuthRepository.getSavedUsername())
        .thenAnswer((_) async => 'emilys');
    when(() => mockAuthRepository.restoreSession())
        .thenAnswer((_) async => null);

    authBloc.add(const CheckAuthSessionReq());

    await expectLater(
      authBloc.stream,
      emits(
        predicate<Unauthenticated>(
          (state) => state.savedUsername == 'emilys' && state.sessionExpiredMessage == null,
        ),
      ),
    );
  });

  test('LoginReq emits AuthLoading then Authenticated on success', () async {
    when(() => mockAuthRepository.login(username: 'emilys', password: 'password123'))
        .thenAnswer((_) async => testUser);

    authBloc.add(const LoginReq(username: 'emilys', password: 'password123'));

    await expectLater(
      authBloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        predicate<Authenticated>((state) => state.user == testUser),
      ]),
    );
  });

  test('LoginReq emits AuthLoading then AuthError on failure', () async {
    when(() => mockAuthRepository.login(username: 'emilys', password: 'wrong'))
        .thenThrow(const AuthFailure('Invalid credentials'));

    authBloc.add(const LoginReq(username: 'emilys', password: 'wrong'));

    await expectLater(
      authBloc.stream,
      emitsInOrder([
        isA<AuthLoading>(),
        predicate<AuthError>((state) => state.message == 'Invalid credentials'),
      ]),
    );
  });

  test('LogoutReq calls logout and emits Unauthenticated', () async {
    when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
    when(() => mockAuthRepository.getSavedUsername()).thenAnswer((_) async => 'emilys');

    authBloc.add(const LogoutReq());

    await expectLater(
      authBloc.stream,
      emits(predicate<Unauthenticated>((state) => state.savedUsername == 'emilys')),
    );
    verify(() => mockAuthRepository.logout()).called(1);
  });

  test('SessionExpiredReq logs out and emits Unauthenticated with message', () async {
    when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
    when(() => mockAuthRepository.getSavedUsername()).thenAnswer((_) async => 'emilys');

    authBloc.add(const SessionExpiredReq());

    await expectLater(
      authBloc.stream,
      emits(
        predicate<Unauthenticated>(
          (state) =>
              state.sessionExpiredMessage != null &&
              state.sessionExpiredMessage!.contains('expired'),
        ),
      ),
    );
  });
}
