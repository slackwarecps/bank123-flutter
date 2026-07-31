import 'package:jwt_decoder/jwt_decoder.dart';

class BasicAuthToken {
  final String token;
  final DateTime expiresAt;
  final String userId;
  final String email;
  final Map<String, dynamic> claims;

  BasicAuthToken({
    required this.token,
    required this.expiresAt,
    required this.userId,
    required this.email,
    this.claims = const {},
  });

  factory BasicAuthToken.fromJwt(String jwtToken) {
    try {
      final decoded = JwtDecoder.decode(jwtToken);

      if (!decoded.containsKey('exp') || !decoded.containsKey('sub') || !decoded.containsKey('email')) {
        throw FormatException('Token JWT inválido: campos obrigatórios ausentes');
      }

      return BasicAuthToken(
        token: jwtToken,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (decoded['exp'] as int) * 1000,
        ),
        userId: decoded['sub'] as String,
        email: decoded['email'] as String,
        claims: decoded,
      );
    } catch (e) {
      throw FormatException('Erro ao decodificar JWT: $e');
    }
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && token.isNotEmpty;
}
