import 'package:equatable/equatable.dart';

import '../domain/entities/user_entity.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String? message;
  const AuthLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class Authenticated extends AuthState {
  final UserEntity user;
  final bool isBiometricSupported;
  final bool isBiometricEnabled;

  const Authenticated({
    required this.user,
    this.isBiometricSupported = false,
    this.isBiometricEnabled = false,
  });

  @override
  List<Object?> get props => [user, isBiometricSupported, isBiometricEnabled];
}

class Unauthenticated extends AuthState {
  final String? savedUsername;
  final bool isBiometricSupported;
  final bool isBiometricEnabled;
  final String? sessionExpiredMessage;

  const Unauthenticated({
    this.savedUsername,
    this.isBiometricSupported = false,
    this.isBiometricEnabled = false,
    this.sessionExpiredMessage,
  });

  @override
  List<Object?> get props => [
    savedUsername,
    isBiometricSupported,
    isBiometricEnabled,
    sessionExpiredMessage,
  ];
}

class AuthError extends AuthState {
  final String message;
  final String? savedUsername;
  final bool isBiometricSupported;

  const AuthError({
    required this.message,
    this.savedUsername,
    this.isBiometricSupported = false,
  });

  @override
  List<Object?> get props => [message, savedUsername, isBiometricSupported];
}
