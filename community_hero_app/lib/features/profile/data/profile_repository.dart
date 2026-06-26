import 'package:dio/dio.dart';
import '../../../models/user.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<User> getUserProfile(String userId) async {
    // try {
    //   final response = await _dio.get('/users/$userId/profile');
    //   return User.fromJson(response.data);
    // } catch (e) {
      // Mock data fallback
      return User(
        id: userId,
        email: 'mock_hero@example.com',
        name: 'Super Hero',
        reputationScore: 1250,
        level: 5,
      );
    // }
  }
}
