import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yum_quick/core/errors/failures.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthSessionReq>(_onCheckAuthSession);
    on<LoginReq>(_onLogin);
    on<LogoutReq>(_onLogout);
    on<SessionExpiredReq>(_onSessionExpired);
  }

  Future<void> _onCheckAuthSession(
    CheckAuthSessionReq event,
    Emitter<AuthState> emit,
  ) async {
    final savedUsername = await authRepository.getSavedUsername();
    final user = await authRepository.restoreSession();
    if (user != null) {
      emit(Authenticated(user: user));
    } else {
      emit(Unauthenticated(savedUsername: savedUsername));
    }
  }

  Future<void> _onLogin(LoginReq event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(message: 'Logging in...'));
    try {
      final user = await authRepository.login(
        username: event.username,
        password: event.password,
      );
      emit(Authenticated(user: user));
    } on Failure catch (e) {
      emit(
        AuthError(
          message: e.message,
          savedUsername: event.username,
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          message: e.toString(),
          savedUsername: event.username,
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutReq event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    final savedUsername = await authRepository.getSavedUsername();
    emit(Unauthenticated(savedUsername: savedUsername));
  }

  Future<void> _onSessionExpired(
    SessionExpiredReq event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    final savedUsername = await authRepository.getSavedUsername();
    emit(
      Unauthenticated(
        savedUsername: savedUsername,
        sessionExpiredMessage:
            'Your session has expired. Please sign in again.',
      ),
    );
  }
}
