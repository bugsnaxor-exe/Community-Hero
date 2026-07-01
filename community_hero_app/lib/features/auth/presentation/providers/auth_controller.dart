import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../profile/presentation/providers/profile_controller.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, void>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<void> {
  late final AuthRepository _authRepository;

  @override
  FutureOr<void> build() {
    _authRepository = ref.watch(authRepositoryProvider);
  }

  Future<bool> login(String email, String password, {String? username}) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.login(email, password, name: username);
      ref.invalidate(profileControllerProvider);
      state = const AsyncValue.data(null);
      return true;
    } on AppException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred', st);
      return false;
    }
  }

  Future<bool> register(String email, String password, String username) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.register(email, password, username);
      ref.invalidate(profileControllerProvider);
      state = const AsyncValue.data(null);
      return true;
    } on AppException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred', st);
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.forgotPassword(email);
      state = const AsyncValue.data(null);
      return true;
    } on AppException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred', st);
      return false;
    }
  }

  Future<bool> resetPassword(String email, String code, String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.resetPassword(email, code, newPassword);
      state = const AsyncValue.data(null);
      return true;
    } on AppException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred', st);
      return false;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authRepository.logout();
    ref.invalidate(profileControllerProvider);
    state = const AsyncValue.data(null);
  }
}

