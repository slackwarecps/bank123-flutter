abstract class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class ConnectivityError extends AuthException {
  ConnectivityError(String message) : super(message);
}

class InvalidCredentialsError extends AuthException {
  InvalidCredentialsError(String message) : super(message);
}

class TokenExpiredError extends AuthException {
  TokenExpiredError(String message) : super(message);
}
