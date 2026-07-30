import 'package:bank123/controllers/login_controller.dart';
import 'package:bank123/services/auth_service.dart';
import 'package:bank123/telas/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class FakeAuthService implements IAuthService {
  bool shouldSucceed = true;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    lastEmail = email;
    lastPassword = password;
    if (shouldSucceed) {
      return AuthResult(
        uid: 'user-123',
        email: email,
        token: 'fake-token-123',
        claims: {
          'bank123/jwt/claims': {'numeroconta': '12345-6'}
        },
      );
    } else {
      throw Exception('firebase_auth: Credenciais inválidas');
    }
  }

  @override
  Future<void> signOut() async {}

  @override
  bool get isAuthenticated => true;

  @override
  Future<String?> getIdToken() async => 'fake-token-123';
}

void main() {
  late FakeAuthService fakeAuthService;
  late LoginController controller;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    TestWidgetsFlutterBinding.ensureInitialized();
    fakeAuthService = FakeAuthService();
    Get.put<IAuthService>(fakeAuthService);
    controller = Get.put(LoginController());
  });

  tearDown(() {
    Get.closeAllSnackbars();
    Get.reset();
  });

  Widget createWidgetUnderTest() {
    return GetMaterialApp(
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/home-page', page: () => const SizedBox()),
        GetPage(name: '/cadastro', page: () => const SizedBox()),
      ],
    );
  }

  group('LoginScreen Widget Tests', () {
    testWidgets('renders all essential elements on LoginScreen', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Bank123'), findsOneWidget);
      expect(find.text('Bem-vindo'), findsOneWidget);

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('E-mail'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);

      expect(find.widgetWithText(FilledButton, 'Entrar'), findsOneWidget);
      expect(find.text('Não tem conta? Cadastre-se'), findsOneWidget);
    });

    testWidgets('user can input email and password', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'fabao@bank123.com');
      await tester.enterText(passwordField, 'senha123');

      expect(controller.emailController.text, equals('fabao@bank123.com'));
      expect(controller.passwordController.text, equals('senha123'));
    });

    testWidgets('shows biometric button when isBiometricAllowed is true', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Login com biometria'), findsNothing);

      controller.isBiometricAllowed.value = true;
      await tester.pump();

      expect(find.text('Login com biometria'), findsOneWidget);
      expect(find.byIcon(Icons.fingerprint), findsOneWidget);
    });

    testWidgets('displays loading indicator when controller is loading', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      controller.isLoading.value = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });
  });

  group('LoginController Unit Tests', () {
    testWidgets('initial state of controller is correct', (WidgetTester tester) async {
      expect(controller.isLoading.value, isFalse);
      expect(controller.isBiometricAllowed.value, isFalse);
    });

    testWidgets('login with empty credentials triggers validation error', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      controller.emailController.text = '';
      controller.passwordController.text = '';

      await controller.login();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      expect(fakeAuthService.lastEmail, isNull);
      expect(controller.isLoading.value, isFalse);
    });

    testWidgets('login with valid credentials invokes auth service and navigates', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      controller.emailController.text = 'usuario@teste.com';
      controller.passwordController.text = '123456';

      await controller.login();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(fakeAuthService.lastEmail, equals('usuario@teste.com'));
      expect(fakeAuthService.lastPassword, equals('123456'));
      expect(controller.isLoading.value, isFalse);
    });
  });
}
