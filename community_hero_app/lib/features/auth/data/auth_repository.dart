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

  Future<void> login(String email, String password, {String? name}) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          if (name != null) 'name': name,
        },
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
          'name': username,
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
    await _secureStorage.delete(key: 'session_last_active_time');
  }

  Future<void> updateLastActive() async {
    await _secureStorage.write(
      key: 'session_last_active_time',
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<bool> checkSessionValid() async {
    final token = await _secureStorage.read(key: AppConstants.tokenKey);
    if (token == null) return false;

    final lastActiveStr = await _secureStorage.read(key: 'session_last_active_time');
    if (lastActiveStr == null) {
      await updateLastActive();
      return true;
    }

    final lastActive = DateTime.tryParse(lastActiveStr);
    if (lastActive == null) {
      await updateLastActive();
      return true;
    }

    // 6 months session expiration (approx 180 days)
    if (DateTime.now().difference(lastActive).inDays > 180) {
      await logout();
      return false;
    }

    await updateLastActive();
    return true;
  }

  Future<bool> isAuthenticated() async {
    return checkSessionValid();
  }
}
