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
    final decoded = JwtDecoder.decode(jwtToken);
    return BasicAuthToken(
      token: jwtToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (decoded['exp'] as int) * 1000,
      ),
      userId: decoded['sub'] as String,
      email: decoded['email'] as String,
      claims: decoded,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isValid => !isExpired && token.isNotEmpty;
}
