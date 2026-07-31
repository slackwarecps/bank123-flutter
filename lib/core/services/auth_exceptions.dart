abstract class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}

class ConnectivityError extends AuthException {
  ConnectivityError(super.message);
}

class InvalidCredentialsError extends AuthException {
  InvalidCredentialsError(super.message);
}

class TokenExpiredError extends AuthException {
  TokenExpiredError(super.message);
}
