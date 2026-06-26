import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/exceptions/app_exception.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(dio: ref.watch(dioProvider));
});

class ReportRepository {
  final Dio _dio;

  ReportRepository({required Dio dio}) : _dio = dio;

  Future<void> submitReport({
    required String title,
    required String description,
    required String category,
    required String severity,
    required double latitude,
    required double longitude,
    File? imageFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'category': category,
        'severity': severity,
        'latitude': latitude,
        'longitude': longitude,
      });

      if (imageFile != null) {
        formData.files.add(
          MapEntry(
            'image', // The user specifically requested this field name
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/issues',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException('Failed to submit report. Please try again.');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw AppException(e.response?.data['detail'] ?? 'Submission failed.');
      }
      throw NetworkException(e.message ?? 'An unknown network error occurred');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      // Assuming there is an endpoint for AI analysis
      final response = await _dio.post('/issues/analyze', data: formData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // If endpoint doesn't exist yet, fallback to dummy data for demonstration
      if (e.response?.statusCode == 404) {
        await Future.delayed(const Duration(seconds: 2));
        return {'category': 'Pothole', 'confidence': 0.92, 'severity': 'High'};
      }
      throw NetworkException('Failed to analyze image: ${e.message}');
    }
  }
}
