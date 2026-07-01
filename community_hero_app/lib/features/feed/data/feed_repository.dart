import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../models/issue.dart';

final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(dio: ref.watch(dioProvider));
});

class FeedRepository {
  final Dio _dio;

  FeedRepository({required Dio dio}) : _dio = dio;

  Future<List<Issue>> getIssues({
    required int limit,
    required int offset,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      
      if (category != null && category.isNotEmpty && category != 'All') {
        queryParams['category'] = category;
      }

      final response = await _dio.get('/issues/', queryParameters: queryParams);
      
      final List<dynamic> data = response.data;
      return data.map((json) => Issue.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load issues: $e');
    }
  }
}
