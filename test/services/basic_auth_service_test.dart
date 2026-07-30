import 'package:bank123/models/basic_auth_token.dart';
import 'package:bank123/services/auth_exceptions.dart';
import 'package:bank123/services/basic_auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'basic_auth_service_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('BasicAuthService', () {
    late BasicAuthService authService;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      authService = BasicAuthService();
      authService.dio = mockDio;
    });

    group('signInWithEmailAndPassword', () {
      test('retorna AuthResult com sucesso quando login funciona', () async {
        const email = 'teste@teste.com.br';
        const password = 'teste123';
        const token =
            'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiJ1c2VyLTEyMyIsImVtYWlsIjoidGVzdGVAdGVzdGUuY29tLmJyIiwiaWF0IjoxNjI3NDEwNDAwLCJleHAiOjE2Mjc0OTY4MDB9.';

        when(mockDio.post('/auth/login',
                data: {'email': email, 'password': password}))
            .thenAnswer((_) async => Response(
                  data: {'token': token},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/auth/login'),
                ));

        final result =
            await authService.signInWithEmailAndPassword(email, password);

        expect(result.success, isTrue);
        expect(result.user, equals(email));
        expect(result.idToken, isNotEmpty);
      });

      test('lança InvalidCredentialsError quando status é 401', () async {
        const email = 'teste@teste.com.br';
        const password = 'wrong';

        when(mockDio.post('/auth/login',
                data: {'email': email, 'password': password}))
            .thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            response: Response(
              statusCode: 401,
              data: {'error': 'Invalid credentials'},
              requestOptions: RequestOptions(path: '/auth/login'),
            ),
          ),
        );

        expect(
          () => authService.signInWithEmailAndPassword(email, password),
          throwsA(isA<InvalidCredentialsError>()),
        );
      });

      test('lança ConnectivityError quando conexão falha', () async {
        const email = 'teste@teste.com.br';
        const password = 'teste123';

        when(mockDio.post('/auth/login',
                data: {'email': email, 'password': password}))
            .thenThrow(
          DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
        );

        expect(
          () => authService.signInWithEmailAndPassword(email, password),
          throwsA(isA<ConnectivityError>()),
        );
      });

      test('retorna erro quando status não é 200', () async {
        const email = 'teste@teste.com.br';
        const password = 'teste123';

        when(mockDio.post('/auth/login',
                data: {'email': email, 'password': password}))
            .thenAnswer((_) async => Response(
                  data: {'error': 'Server error'},
                  statusCode: 500,
                  requestOptions: RequestOptions(path: '/auth/login'),
                ));

        final result =
            await authService.signInWithEmailAndPassword(email, password);

        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });
    });

    group('signOut', () {
      test('chama /auth/logout e limpa token', () async {
        when(mockDio.post('/auth/logout'))
            .thenAnswer((_) async => Response(
                  data: {'status': 'logged_out'},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/auth/logout'),
                ));

        await authService.signOut();

        verify(mockDio.post('/auth/logout')).called(1);
      });

      test('não falha se logout retorna erro', () async {
        when(mockDio.post('/auth/logout')).thenThrow(
          DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: '/auth/logout'),
          ),
        );

        expect(() => authService.signOut(), returnsNormally);
      });
    });

    group('getIdToken', () {
      test('retorna token válido quando não expirado', () async {
        const token =
            'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiJ1c2VyLTEyMyIsImVtYWlsIjoidGVzdGVAdGVzdGUuY29tLmJyIiwiaWF0IjoxNjI3NDEwNDAwLCJleHAiOjk5OTk5OTk5OTl9.';

        authService.currentToken = BasicAuthToken.fromJwt(token);

        final result = await authService.getIdToken();

        expect(result, equals(token));
      });

      test('auto-refresh token quando expirado', () async {
        const expiredToken =
            'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiJ1c2VyLTEyMyIsImVtYWlsIjoidGVzdGVAdGVzdGUuY29tLmJyIiwiaWF0IjoxNjI3NDEwNDAwLCJleHAiOjE2Mjc0OTY4MDB9.';
        const newToken =
            'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiJ1c2VyLTEyMyIsImVtYWlsIjoidGVzdGVAdGVzdGUuY29tLmJyIiwiaWF0IjoxNjI3NDk2ODAwLCJleHAiOjk5OTk5OTk5OTl9.';

        authService.currentToken = BasicAuthToken.fromJwt(expiredToken);

        when(mockDio.post('/auth/refresh',
                data: {'token': expiredToken}))
            .thenAnswer((_) async => Response(
                  data: {'token': newToken},
                  statusCode: 200,
                  requestOptions: RequestOptions(path: '/auth/refresh'),
                ));

        final result = await authService.getIdToken();

        expect(result, equals(newToken));
        verify(mockDio.post('/auth/refresh', data: {'token': expiredToken}))
            .called(1);
      });

      test('lança TokenExpiredError quando nenhum token disponível', () async {
        authService.currentToken = null;

        expect(
          () => authService.getIdToken(),
          throwsA(isA<TokenExpiredError>()),
        );
      });
    });

    group('isAuthenticated', () {
      test('retorna true quando token válido', () async {
        const token =
            'eyJhbGciOiJub25lIiwidHlwIjoiSldUIn0.eyJzdWIiOiJ1c2VyLTEyMyIsImVtYWlsIjoidGVzdGVAdGVzdGUuY29tLmJyIiwiaWF0IjoxNjI3NDEwNDAwLCJleHAiOjk5OTk5OTk5OTl9.';

        authService.currentToken = BasicAuthToken.fromJwt(token);

        final isAuth = await authService.isAuthenticated();

        expect(isAuth, isTrue);
      });

      test('retorna false quando nenhum token', () async {
        final isAuth = await authService.isAuthenticated();

        expect(isAuth, isFalse);
      });
    });
  });
}
