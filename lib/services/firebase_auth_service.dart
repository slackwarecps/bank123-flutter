import 'package:firebase_auth/firebase_auth.dart';
import 'package:bank123/services/auth_service.dart';

class FirebaseAuthService implements IAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email, 
      password: password
    );

    final tokenResult = await credential.user?.getIdTokenResult();

    return AuthResult(
      uid: credential.user?.uid,
      email: credential.user?.email,
      token: tokenResult?.token,
      claims: tokenResult?.claims,
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  bool get isAuthenticated => _auth.currentUser != null;

  @override
  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }
}
