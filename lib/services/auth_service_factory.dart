import 'package:bank123/services/auth_service.dart';
import 'package:bank123/services/basic_auth_service.dart';
import 'package:bank123/services/firebase_auth_service.dart';

class AuthServiceFactory {
  static IAuthService createAuthService() {
    const authMode = String.fromEnvironment(
      'AUTH_MODE',
      defaultValue: 'firebase',
    );

    if (authMode == 'basic') {
      return BasicAuthService();
    }

    return FirebaseAuthService();
  }
}
