import 'package:dio/dio.dart';
import '../../../models/user.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<User> getUserProfile(String userId) async {
    // Return mock data to bypass 401 for UI development
    return User(
      id: userId,
      name: 'Alex Chen',
      email: 'alex.chen@example.com',
      reputationScore: 1250,
      level: 7,
    );
  }
}
