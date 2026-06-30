import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_constants.dart';
import '../navigation/navigator_service.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          // Update last active time
          await secureStorage.write(
            key: 'session_last_active_time',
            value: DateTime.now().toIso8601String(),
          );
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Clear credentials
          await secureStorage.delete(key: AppConstants.tokenKey);
          await secureStorage.delete(key: AppConstants.userKey);
          await secureStorage.delete(key: 'session_last_active_time');

          // Redirect to login screen
          final context = rootNavigatorKey.currentContext;
          if (context != null && context.mounted) {
            context.go('/login');
          }
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
