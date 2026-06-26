import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/exceptions/app_exception.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    dio: ref.watch(dioProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthRepository({
    required Dio dio,
    required FlutterSecureStorage secureStorage,
  })  : _dio = dio,
        _secureStorage = secureStorage;

  Future<void> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'username': email, // FastAPI OAuth2 expects 'username' field
          'password': password,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType, // Required by OAuth2PasswordRequestForm
        ),
      );

      final token = response.data['access_token'];
      if (token != null) {
        await _secureStorage.write(key: AppConstants.tokenKey, value: token);
      } else {
        throw AuthException('Failed to retrieve access token.');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 400) {
        throw AuthException('Invalid email or password.');
      }
      throw NetworkException(e.message ?? 'An unknown network error occurred');
    }
  }

  Future<void> register(String email, String password, String username) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'username': username,
        },
      );
      
      // Auto-login after successful registration (optional, depends on backend logic)
      if (response.statusCode == 200 || response.statusCode == 201) {
        await login(email, password);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400 || e.response?.statusCode == 409) {
        throw AuthException(e.response?.data['detail'] ?? 'Registration failed.');
      }
      throw NetworkException(e.message ?? 'An unknown network error occurred');
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.userKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    return token != null;
  }
}
