import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/exceptions/app_exception.dart';
import '../../../../models/issue.dart';

final issueDetailsRepositoryProvider = Provider<IssueDetailsRepository>((ref) {
  return IssueDetailsRepository(dio: ref.watch(dioProvider));
});

class IssueDetailsRepository {
  final Dio _dio;

  IssueDetailsRepository({required Dio dio}) : _dio = dio;

  Future<Issue> getIssueDetails(String id) async {
    try {
      final response = await _dio.get('/issues/$id');
      return Issue.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw AppException('Issue not found.');
      }
      throw NetworkException(e.message ?? 'An unknown error occurred');
    }
  }

  Future<bool> verifyIssue(String id, double latitude, double longitude) async {
    try {
      final response = await _dio.post(
        '/verifications/issue/$id',
        data: {
          'is_valid': true,
          'latitude': latitude,
          'longitude': longitude,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        throw AppException(e.response?.data['detail'] ?? 'Verification failed.');
      }
      throw NetworkException(e.message ?? 'Network error.');
    }
  }

  Future<List<Map<String, dynamic>>> getIssueTimeline(String id) async {
    try {
      final response = await _dio.get('/issues/$id/status/history');
      final List<dynamic> data = response.data;
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (_) {
      // Return empty timeline if endpoint doesn't exist yet or fails
      return [];
    }
  }
}
