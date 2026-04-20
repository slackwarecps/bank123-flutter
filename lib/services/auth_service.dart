class AuthResult {
  final String? uid;
  final String? email;
  final String? token;
  final Map<String, dynamic>? claims;

  AuthResult({this.uid, this.email, this.token, this.claims});
}

abstract class IAuthService {
  Future<AuthResult> signInWithEmailAndPassword(String email, String password);
  Future<void> signOut();
  bool get isAuthenticated;
  Future<String?> getIdToken();
}
