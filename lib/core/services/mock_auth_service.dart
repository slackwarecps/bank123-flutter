import 'package:bank123/core/services/auth_service.dart';
import 'dart:developer' as developer;

class MockAuthService implements IAuthService {
  // Um Token Mock que parece um JWT real para não quebrar o JwtDecoder
  static const String _mockJwt = 
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9."
      "eyJzdWIiOiJtb2NrLXVpZC0xMjMiLCJlbWFpbCI6InRlc3RlQHRlc3RlLmNvbS5iciIsImlhdCI6MTcxMzU2MDAwMCwiZXhwIjoxODEzNTYwMDAwLCJiYW5rMTIzL2p3dC9jbGFpbXMiOnsibnVtZXJvY29udGEiOiIxMjM0NTYiLCJwZXJmaWwiOiJBRE1JTiJ9fQ==."
      "signature";

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    // Simula latência de rede
    await Future.delayed(const Duration(seconds: 2));

    if (email == "teste@teste.com.br" && password == "teste123") {
      return AuthResult(
        uid: "mock-uid-123",
        email: email,
        token: _mockJwt,
        claims: {
          "bank123/jwt/claims": {
            "numeroconta": "123456",
            "perfil": "ADMIN"
          }
        },
      );
    } else {
      throw Exception("Credenciais de Mock inválidas (Use: teste@teste.com.br / teste123)");
    }
  }

  @override
  Future<void> signOut() async {
    developer.log("MOCK: Usuário deslogado", name: 'MockAuthService');
  }

  @override
  bool get isAuthenticated => true;

  @override
  Future<String?> getIdToken() async {
    return _mockJwt;
  }
}
