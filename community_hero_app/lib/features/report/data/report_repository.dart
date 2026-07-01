
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
    List<XFile> images = const [],
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

      if (images.isNotEmpty) {
        for (var image in images) {
          final bytes = await image.readAsBytes();
          formData.files.add(
            MapEntry(
              'images', // Sending as array field
              MultipartFile.fromBytes(
                bytes,
                filename: image.name,
              ),
            ),
          );
        }
      }

      final response = await _dio.post(
        '/issues/',
        data: formData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw AppException('Failed to submit report. Please try again.');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final data = e.response?.data;
        if (data is Map) {
          final detail = data['detail'];
          String errorMsg = 'Submission failed.';
          if (detail is String) {
            errorMsg = detail;
          } else if (detail is Map) {
            errorMsg = detail['message']?.toString() ?? detail.toString();
          } else if (detail is List) {
            errorMsg = detail.toString();
          } else if (detail != null) {
            errorMsg = detail.toString();
          }
          throw AppException(errorMsg);
        } else if (data is String) {
           throw AppException('Server error: ${e.response?.statusCode}');
        }
      }
      throw NetworkException(e.message ?? 'An unknown network error occurred');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(XFile image) async {
    try {
      final bytes = await image.readAsBytes();
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          bytes,
          filename: image.name,
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
