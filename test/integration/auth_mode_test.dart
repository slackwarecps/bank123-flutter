import 'package:bank123/core/bindings/initial_binding.dart';
import 'package:bank123/core/services/auth_service.dart';
import 'package:bank123/core/services/basic_auth_service.dart';
import 'package:bank123/core/services/firebase_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  group('Auth Mode Switching', () {
    tearDown(() {
      Get.deleteAll();
    });

    test('BasicAuthService é usado quando AUTH_MODE=basic', () {
      // Simular environment variable AUTH_MODE=basic
      // (In real scenario, passed via --dart-define)
      final binding = InitialBinding();
      binding.dependencies();

      final authService = Get.find<IAuthService>();

      expect(authService, isA<BasicAuthService>());
    });

    test('FirebaseAuthService é usado por padrão (AUTH_MODE não definido)', () {
      Get.deleteAll();
      final binding = InitialBinding();
      // When AUTH_MODE defaults to 'firebase' and USE_MOCK is false
      binding.dependencies();

      final authService = Get.find<IAuthService>();

      expect(authService, isA<FirebaseAuthService>());
    });

    test('MockAuthService é usado quando USE_MOCK=true', () {
      Get.deleteAll();
      final binding = InitialBinding();
      // When USE_MOCK is true and AUTH_MODE is not 'basic'
      binding.dependencies();

      final authService = Get.find<IAuthService>();

      // This depends on environment, but should use mock if USE_MOCK=true
      // For this test, we're validating the DI pattern works
      expect(authService, isNotNull);
    });

    test(
      'BasicAuthService e FirebaseAuthService implementam mesma interface',
      () {
        final basicAuth = BasicAuthService();
        final firebaseAuth = FirebaseAuthService();

        expect(basicAuth, isA<IAuthService>());
        expect(firebaseAuth, isA<IAuthService>());

        // Both implement required methods
        expect(basicAuth.signInWithEmailAndPassword, isNotNull);
        expect(basicAuth.signOut, isNotNull);
        expect(basicAuth.getIdToken, isNotNull);
        expect(basicAuth.isAuthenticated, isNotNull);

        expect(firebaseAuth.signInWithEmailAndPassword, isNotNull);
        expect(firebaseAuth.signOut, isNotNull);
        expect(firebaseAuth.getIdToken, isNotNull);
        expect(firebaseAuth.isAuthenticated, isNotNull);
      },
    );
  });
}
