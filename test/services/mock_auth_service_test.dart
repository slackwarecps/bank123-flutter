import 'package:bank123/services/mock_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAuthService service;

  setUp(() {
    service = MockAuthService();
  });

  group('MockAuthService.signInWithEmailAndPassword', () {
    test('aceita as credenciais mockadas válidas', () async {
      final result = await service.signInWithEmailAndPassword(
        'teste@teste.com.br',
        'teste123',
      );

      expect(result.uid, 'mock-uid-123');
      expect(result.email, 'teste@teste.com.br');
      expect(result.token, isNotEmpty);
      expect(
        result.claims?['bank123/jwt/claims']?['numeroconta'],
        '123456',
      );
      expect(
        result.claims?['bank123/jwt/claims']?['perfil'],
        'ADMIN',
      );
    });

    test('rejeita email correto com senha errada', () async {
      expect(
        () => service.signInWithEmailAndPassword('teste@teste.com.br', 'senha-errada'),
        throwsA(isA<Exception>()),
      );
    });

    test('rejeita credenciais completamente inválidas', () async {
      expect(
        () => service.signInWithEmailAndPassword('usuario@teste.com', '123456'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MockAuthService - demais métodos', () {
    test('isAuthenticated é sempre true', () {
      expect(service.isAuthenticated, isTrue);
    });

    test('getIdToken retorna o token mockado', () async {
      final token = await service.getIdToken();
      expect(token, isNotEmpty);
    });

    test('signOut completa sem lançar exceção', () async {
      await expectLater(service.signOut(), completes);
    });
  });
}
