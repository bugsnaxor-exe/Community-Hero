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
    AsyncNotifierProvider.family<ProfileController, User, String>(() {
  return ProfileController();
});

class ProfileController extends FamilyAsyncNotifier<User, String> {
  @override
  FutureOr<User> build(String arg) async {
    return ref.read(profileRepositoryProvider).getUserProfile(arg);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(profileRepositoryProvider).getUserProfile(arg));
  }
}
