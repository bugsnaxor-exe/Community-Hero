import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ProfileRepository(dio);
});

final profileControllerProvider =
    AsyncNotifierProvider.autoDispose<ProfileController, User>(() {
  return ProfileController();
});

class ProfileController extends AutoDisposeAsyncNotifier<User> {
  @override
  FutureOr<User> build() async {
    return ref.read(profileRepositoryProvider).getUserProfile();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(profileRepositoryProvider).getUserProfile());
  }
}
