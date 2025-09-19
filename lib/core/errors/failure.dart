import 'package:equatable/equatable.dart';

/// Base class for application-level failures.
abstract class Failure extends Equatable implements Exception {
  const Failure(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => <Object?>[message, cause];

  @override
  String toString() => 'Failure(message: ' + message + ', cause: ' + cause.toString() + ')';
}

/// Failure thrown when a workflow transition is not supported.
class InvalidTicketTransitionFailure extends Failure {
  InvalidTicketTransitionFailure({required String from, required String to})
      : super('La transición de estado $from → $to no está permitida.');
}

/// Failure thrown when a requested resource cannot be located.
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Failure representing persistence issues (database, filesystem, etc.).
class PersistenceFailure extends Failure {
  const PersistenceFailure(String message, [Object? cause]) : super(message, cause);
}

/// Failure used for authentication or authorization errors.
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}
