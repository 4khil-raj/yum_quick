import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Invalid username or password.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to access local cached data.']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([
    super.message = 'An unexpected error occurred. Please try again.',
  ]);
}
