import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../models/user.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/leaderboard_repository.dart';

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return LeaderboardRepository(dio);
});

final leaderboardControllerProvider =
    AsyncNotifierProvider<LeaderboardController, List<User>>(() {
  return LeaderboardController();
});

class LeaderboardController extends AsyncNotifier<List<User>> {
  @override
  FutureOr<List<User>> build() async {
    return ref.read(leaderboardRepositoryProvider).getLeaderboard();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.read(leaderboardRepositoryProvider).getLeaderboard());
  }
}
