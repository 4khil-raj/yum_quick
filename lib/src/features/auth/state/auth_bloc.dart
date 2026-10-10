import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yum_quick/src/core/errors/failures.dart';

import '../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthSessionReq>(_onCheckAuthSession);
    on<LoginReq>(_onLogin);
    on<BiometricLoginReq>(_onBiometricLogin);
    on<EnableBiometricReq>(_onEnableBiometric);
    on<LogoutReq>(_onLogout);
    on<SessionExpiredReq>(_onSessionExpired);
  }

  Future<void> _onCheckAuthSession(
    CheckAuthSessionReq event,
    Emitter<AuthState> emit,
  ) async {
    final isBioAvailable = await authRepository.isBiometricAvailable();
    final isBioEnabled = await authRepository.isBiometricEnabled();
    final savedUsername = await authRepository.getSavedUsername();

    final user = await authRepository.restoreSession();
    if (user != null) {
      emit(
        Authenticated(
          user: user,
          isBiometricSupported: isBioAvailable,
          isBiometricEnabled: isBioEnabled,
        ),
      );
    } else {
      emit(
        Unauthenticated(
          savedUsername: savedUsername,
          isBiometricSupported: isBioAvailable,
          isBiometricEnabled: isBioEnabled,
        ),
      );
    }
  }

  Future<void> _onLogin(LoginReq event, Emitter<AuthState> emit) async {
    final isBioAvailable = await authRepository.isBiometricAvailable();
    final isBioEnabled = await authRepository.isBiometricEnabled();

    emit(const AuthLoading(message: 'Logging in...'));
    try {
      final user = await authRepository.login(
        username: event.username,
        password: event.password,
      );
      emit(
        Authenticated(
          user: user,
          isBiometricSupported: isBioAvailable,
          isBiometricEnabled: isBioEnabled,
        ),
      );
    } on Failure catch (e) {
      emit(
        AuthError(
          message: e.message,
          savedUsername: event.username,
          isBiometricSupported: isBioAvailable,
        ),
      );
    } catch (e) {
      emit(
        AuthError(
          message: e.toString(),
          savedUsername: event.username,
          isBiometricSupported: isBioAvailable,
        ),
      );
    }
  }

  Future<void> _onBiometricLogin(
    BiometricLoginReq event,
    Emitter<AuthState> emit,
  ) async {
    final isBioAvailable = await authRepository.isBiometricAvailable();
    final isBioEnabled = await authRepository.isBiometricEnabled();
    final savedUsername = await authRepository.getSavedUsername();

    if (!isBioAvailable || !isBioEnabled) {
      emit(
        AuthError(
          message: 'Biometric authentication is not enabled or available.',
          savedUsername: savedUsername,
          isBiometricSupported: isBioAvailable,
        ),
      );
      return;
    }

    final success = await authRepository.authenticateWithBiometrics();
    if (success) {
      final user = await authRepository.restoreSession();
      if (user != null) {
        emit(
          Authenticated(
            user: user,
            isBiometricSupported: isBioAvailable,
            isBiometricEnabled: isBioEnabled,
          ),
        );
      } else {
        emit(
          Unauthenticated(
            savedUsername: savedUsername,
            isBiometricSupported: isBioAvailable,
            isBiometricEnabled: isBioEnabled,
            sessionExpiredMessage:
                'No active session found. Please enter your password.',
          ),
        );
      }
    } else {
      emit(
        AuthError(
          message: 'Biometric authentication cancelled or failed.',
          savedUsername: savedUsername,
          isBiometricSupported: isBioAvailable,
        ),
      );
    }
  }

  Future<void> _onEnableBiometric(
    EnableBiometricReq event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.setBiometricEnabled(event.enable);
    if (state is Authenticated) {
      final curr = state as Authenticated;
      emit(
        Authenticated(
          user: curr.user,
          isBiometricSupported: curr.isBiometricSupported,
          isBiometricEnabled: event.enable,
        ),
      );
    } else if (state is Unauthenticated) {
      final curr = state as Unauthenticated;
      emit(
        Unauthenticated(
          savedUsername: curr.savedUsername,
          isBiometricSupported: curr.isBiometricSupported,
          isBiometricEnabled: event.enable,
        ),
      );
    }
  }

  Future<void> _onLogout(LogoutReq event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    final isBioAvailable = await authRepository.isBiometricAvailable();
    final isBioEnabled = await authRepository.isBiometricEnabled();
    final savedUsername = await authRepository.getSavedUsername();

    emit(
      Unauthenticated(
        savedUsername: savedUsername,
        isBiometricSupported: isBioAvailable,
        isBiometricEnabled: isBioEnabled,
      ),
    );
  }

  Future<void> _onSessionExpired(
    SessionExpiredReq event,
    Emitter<AuthState> emit,
  ) async {
    await authRepository.logout();
    final isBioAvailable = await authRepository.isBiometricAvailable();
    final isBioEnabled = await authRepository.isBiometricEnabled();
    final savedUsername = await authRepository.getSavedUsername();

    emit(
      Unauthenticated(
        savedUsername: savedUsername,
        isBiometricSupported: isBioAvailable,
        isBiometricEnabled: isBioEnabled,
        sessionExpiredMessage:
            'Your session has expired. Please sign in again.',
      ),
    );
  }
}
