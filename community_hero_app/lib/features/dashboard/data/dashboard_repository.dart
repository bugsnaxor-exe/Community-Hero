import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(dio: ref.watch(dioProvider));
});

class DashboardRepository {
  final Dio _dio;

  DashboardRepository({required Dio dio}) : _dio = dio;

  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      final response = await _dio.get('/dashboard/analytics/dashboard');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Return empty fallback map if network fails
      return {
        "stats": {
          "total_issues": 0,
          "verified_issues": 0,
          "resolved_issues": 0,
          "pending_issues": 0,
          "avg_resolution_time_hours": 0.0
        },
        "categories": [],
        "severity": [],
        "leaderboard": [],
        "recent_activity": []
      };
    }
  }

  Future<void> resolveIssue(dynamic issueId) async {
    try {
      await _dio.patch('/issues/$issueId/status', data: {'status': 'RESOLVED'});
    } catch (e) {
      // throw error to be handled by controller
      throw Exception('Failed to resolve issue: $e');
    }
  }
}
