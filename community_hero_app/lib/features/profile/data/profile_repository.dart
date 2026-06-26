import 'package:dio/dio.dart';
import '../../../models/user.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<User> getUserProfile(String userId) async {
    try {
      final response = await _dio.get('/users/me');
      return User.fromJson(response.data);
    } catch (e) {
      // Re-throw or handle error
      rethrow;
    }
  }
}
