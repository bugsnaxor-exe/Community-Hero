import 'package:dio/dio.dart';
import '../../../models/user.dart';
import '../../../models/issue.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<User> getUserProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Issue>> getMyReportedIssues() async {
    try {
      final response = await _dio.get('/users/me/issues');
      final List<dynamic> data = response.data;
      return data.map((json) => Issue.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Issue>> getMyVerifiedIssues() async {
    try {
      final response = await _dio.get('/users/me/verifications');
      final List<dynamic> data = response.data;
      return data.map((json) => Issue.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
