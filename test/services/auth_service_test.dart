import 'package:bank123/core/services/auth_service.dart';
import 'package:bank123/core/services/mock_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAuthService authService;

  setUp(() {
    authService = MockAuthService();
  });

  group('MockAuthService - signInWithEmailAndPassword', () {
    test('login com credenciais válidas retorna AuthResult correto', () async {
      final result = await authService.signInWithEmailAndPassword(
        'teste@teste.com.br',
        'teste123',
      );

      expect(result.uid, 'mock-uid-123');
      expect(result.email, 'teste@teste.com.br');
      expect(result.token, isNotNull);
      expect(result.token, isNotEmpty);
    });

    test('login com credenciais válidas contém claims esperadas', () async {
      final result = await authService.signInWithEmailAndPassword(
        'teste@teste.com.br',
        'teste123',
      );

      expect(result.claims, isNotNull);
      expect(result.claims!['bank123/jwt/claims'], isNotNull);
      expect(result.claims!['bank123/jwt/claims']['numeroconta'], '123456');
      expect(result.claims!['bank123/jwt/claims']['perfil'], 'ADMIN');
    });

    test('login com email errado lança exceção', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          'email-errado@teste.com',
          'teste123',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('login com senha errada lança exceção', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          'teste@teste.com.br',
          'senha-errada',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('login com ambos email e senha errados lança exceção', () async {
      expect(
        () => authService.signInWithEmailAndPassword(
          'usuario@teste.com',
          '123456',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('exceção de login contém mensagem descritiva', () async {
      try {
        await authService.signInWithEmailAndPassword(
          'invalido@teste.com',
          'invalido',
        );
        fail('Deveria ter lançado exceção');
      } catch (e) {
        expect(e, isA<Exception>());
        expect(e.toString(), contains('Credenciais de Mock inválidas'));
      }
    });
  });

  group('MockAuthService - isAuthenticated', () {
    test('isAuthenticated sempre retorna true', () {
      expect(authService.isAuthenticated, isTrue);
    });

    test('isAuthenticated é bool', () {
      final result = authService.isAuthenticated;
      expect(result is bool, isTrue);
    });
  });

  group('MockAuthService - getIdToken', () {
    test('getIdToken retorna token não-vazio', () async {
      final token = await authService.getIdToken();

      expect(token, isNotNull);
      expect(token, isNotEmpty);
    });

    test('getIdToken retorna JWT válido (contém pontos)', () async {
      final token = await authService.getIdToken();

      expect(token, contains('.'));
      expect(token!.split('.').length, 3);
    });

    test('getIdToken sempre retorna o mesmo token mock', () async {
      final token1 = await authService.getIdToken();
      final token2 = await authService.getIdToken();

      expect(token1, equals(token2));
    });
  });

  group('MockAuthService - signOut', () {
    test('signOut completa sem lançar exceção', () async {
      await expectLater(authService.signOut(), completes);
    });

    test('signOut não altera estado de isAuthenticated', () async {
      expect(authService.isAuthenticated, isTrue);
      await authService.signOut();
      expect(authService.isAuthenticated, isTrue);
    });
  });

  group('AuthResult', () {
    test('AuthResult pode ser instanciado com todos os parâmetros', () {
      final result = AuthResult(
        uid: 'test-uid',
        email: 'test@example.com',
        token: 'test-token',
        claims: {'key': 'value'},
      );

      expect(result.uid, 'test-uid');
      expect(result.email, 'test@example.com');
      expect(result.token, 'test-token');
      expect(result.claims, {'key': 'value'});
    });

    test('AuthResult pode ser instanciado com parâmetros nulos', () {
      final result = AuthResult();

      expect(result.uid, isNull);
      expect(result.email, isNull);
      expect(result.token, isNull);
      expect(result.claims, isNull);
    });

    test('AuthResult pode ser instanciado com alguns parâmetros', () {
      final result = AuthResult(
        uid: 'test-uid',
        email: 'test@example.com',
      );

      expect(result.uid, 'test-uid');
      expect(result.email, 'test@example.com');
      expect(result.token, isNull);
      expect(result.claims, isNull);
    });
  });

  group('MockAuthService - integração', () {
    test('fluxo completo: login -> isAuthenticated -> getIdToken -> signOut', () async {
      final result = await authService.signInWithEmailAndPassword(
        'teste@teste.com.br',
        'teste123',
      );

      expect(result.uid, isNotNull);
      expect(authService.isAuthenticated, isTrue);

      final token = await authService.getIdToken();
      expect(token, isNotNull);

      await authService.signOut();
      expect(authService.isAuthenticated, isTrue);
    });
  });
}
