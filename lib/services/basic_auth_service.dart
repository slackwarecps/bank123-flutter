import 'package:bank123/models/basic_auth_token.dart';
import 'package:bank123/services/auth_exceptions.dart';
import 'package:bank123/services/auth_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BasicAuthService implements IAuthService {
  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();
  BasicAuthToken? _currentToken;
  String? _currentUser;

  // Expose for testing
  BasicAuthToken? get currentToken => _currentToken;
  set currentToken(BasicAuthToken? token) => _currentToken = token;
  Dio get dio => _dio;
  set dio(Dio dioInstance) => _dio = dioInstance;

  BasicAuthService() {
    _dio = Dio(BaseOptions(
      baseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8089'),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ));
  }

  @override
  Future<AuthResult> signInWithEmailAndPassword(String email, String password) async {
    print('╔════════════════════════════════════════════════════════════');
    print('║ [BasicAuthService] Starting login');
    print('║ Mode: BASIC AUTH (offline, no Firebase)');
    print('║ Email: $email');
    print('║ API Base URL: ${_dio.options.baseUrl}');
    print('╚════════════════════════════════════════════════════════════');

    try {
      print('[BasicAuthService] 🔄 Posting to /auth/login...');
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      print('[BasicAuthService] ✅ Response: ${response.statusCode}');

      print('[BasicAuthService] ✅ Response received: ${response.statusCode}');
      print('[BasicAuthService] Response body: ${response.data}');

      if (response.statusCode == 200) {
        final token = response.data['token'] as String;
        print('[BasicAuthService] ✅ Token extracted: ${token.substring(0, 50)}...');

        _currentToken = BasicAuthToken.fromJwt(token);
        _currentUser = email;

        await _secureStorage.write(
          key: 'basic_auth_token',
          value: token,
        );

        print('[BasicAuthService] ✅ POST /auth/login successful');
        print('[BasicAuthService] ✅ Token stored in secure storage');
        print('[BasicAuthService] ✅ Navigating to /home-page');

        return AuthResult(
          uid: _currentToken!.userId,
          email: _currentToken!.email,
          token: token,
          claims: _currentToken!.claims,
        );
      }

      print('[BasicAuthService] ❌ Login failed: status ${response.statusCode}');
      throw InvalidCredentialsError('Falha ao fazer login');
    } on DioException catch (e) {
      print('[BasicAuthService] ❌ DioException: ${e.type}');
      print('[BasicAuthService] Error: ${e.message}');
      print('[BasicAuthService] Response: ${e.response?.statusCode}');

      if (e.response?.statusCode == 401) {
        throw InvalidCredentialsError('E-mail ou senha inválidos');
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        throw ConnectivityError(
          'Servidor de autenticação indisponível. Verifique se Mockoon está rodando em :8089',
        );
      }
      throw ConnectivityError('Erro de conexão. Verifique sua internet');
    } catch (e) {
      print('[BasicAuthService] ❌ Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
      debugPrint('[BasicAuthService] Logout error (non-fatal): $e');
    }

    _currentToken = null;
    _currentUser = null;
    await _secureStorage.delete(key: 'basic_auth_token');
  }

  @override
  Future<String> getIdToken() async {
    if (_currentToken?.isValid ?? false) {
      return _currentToken!.token;
    }

    if (_currentToken?.isExpired ?? false) {
      debugPrint('[BasicAuthService] Token auto-refresh triggered');
      try {
        final response = await _dio.post(
          '/auth/refresh',
          data: {'token': _currentToken!.token},
        );

        if (response.statusCode == 200) {
          final newToken = response.data['token'] as String;
          _currentToken = BasicAuthToken.fromJwt(newToken);
          await _secureStorage.write(key: 'basic_auth_token', value: newToken);
          return newToken;
        }
      } catch (e) {
        debugPrint('[BasicAuthService] Token refresh failed: $e');
      }
    }

    final storedToken = await _secureStorage.read(key: 'basic_auth_token');
    if (storedToken != null) {
      _currentToken = BasicAuthToken.fromJwt(storedToken);
      return storedToken;
    }

    throw TokenExpiredError('Token expirado ou não encontrado');
  }

  @override
  bool get isAuthenticated {
    try {
      return _currentToken?.isValid ?? false;
    } catch (e) {
      return false;
    }
  }
}
