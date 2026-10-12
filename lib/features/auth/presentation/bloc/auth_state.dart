import 'package:equatable/equatable.dart';

import '../../domain/entities/user_entity.dart';

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

  const Authenticated({required this.user});

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {
  final String? savedUsername;
  final String? sessionExpiredMessage;

  const Unauthenticated({
    this.savedUsername,
    this.sessionExpiredMessage,
  });

  @override
  List<Object?> get props => [savedUsername, sessionExpiredMessage];
}

class AuthError extends AuthState {
  final String message;
  final String? savedUsername;

  const AuthError({
    required this.message,
    this.savedUsername,
  });

  @override
  List<Object?> get props => [message, savedUsername];
}
