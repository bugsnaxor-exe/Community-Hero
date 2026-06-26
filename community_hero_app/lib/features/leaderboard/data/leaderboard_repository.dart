import 'package:dio/dio.dart';
import '../../../models/user.dart';

class LeaderboardRepository {
  final Dio _dio;

  LeaderboardRepository(this._dio);

  Future<List<User>> getLeaderboard({int limit = 10}) async {
    try {
      final response = await _dio.get('/users/leaderboard', queryParameters: {'limit': limit});
      return (response.data as List).map((e) => User.fromJson(e)).toList();
    } catch (e) {
      // Re-throw or handle error
      rethrow;
    }
  }
}
