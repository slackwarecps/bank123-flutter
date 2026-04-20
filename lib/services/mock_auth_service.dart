import 'package:bank123/services/auth_service.dart';

class MockAuthService implements IAuthService {
  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    // Simula latência de rede
    await Future.delayed(const Duration(seconds: 2));

    if (email == "teste@teste.com.br" && password == "teste123") {
      return AuthResult(
        uid: "mock-uid-123",
        email: email,
        token: "eyMockToken.Header.Payload.Signature",
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
    print("MOCK: Usuário deslogado");
  }

  @override
  bool get isAuthenticated => true;

  @override
  Future<String?> getIdToken() async {
    return "eyMockToken.Header.Payload.Signature";
  }
}
