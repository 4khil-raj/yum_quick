import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthSessionReq extends AuthEvent {
  const CheckAuthSessionReq();
}

class LoginReq extends AuthEvent {
  final String username;
  final String password;

  const LoginReq({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

class BiometricLoginReq extends AuthEvent {
  const BiometricLoginReq();
}

class EnableBiometricReq extends AuthEvent {
  final bool enable;

  const EnableBiometricReq(this.enable);

  @override
  List<Object?> get props => [enable];
}

class LogoutReq extends AuthEvent {
  const LogoutReq();
}

class SessionExpiredReq extends AuthEvent {
  const SessionExpiredReq();
}
