import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/report_repository.dart';
import '../../../../services/location_service.dart';
import '../../../../core/exceptions/app_exception.dart';

final reportControllerProvider = AsyncNotifierProvider<ReportController, void>(() {
  return ReportController();
});

class ReportController extends AsyncNotifier<void> {
  late final ReportRepository _reportRepository;
  late final LocationService _locationService;

  @override
  FutureOr<void> build() {
    _reportRepository = ref.watch(reportRepositoryProvider);
    _locationService = ref.watch(locationServiceProvider);
  }

  Future<bool> submitReport({
    required String title,
    required String description,
    required String category,
    required String severity,
    List<XFile> images = const [],
  }) async {
    state = const AsyncValue.loading();
    try {
      double latitude;
      double longitude;
      try {
        // Automatically fetch the user's current GPS location
        final position = await _locationService.getCurrentLocation();
        latitude = position.latitude;
        longitude = position.longitude;
      } catch (e) {
        // Fallback to default coordinates if GPS fails
        latitude = 22.5726;
        longitude = 88.3639;
      }

      await _reportRepository.submitReport(
        title: title,
        description: description,
        category: category,
        severity: severity,
        latitude: latitude,
        longitude: longitude,
        images: images,
      );

      state = const AsyncValue.data(null);
      return true;
    } on AppException catch (e) {
      state = AsyncValue.error(e.message, StackTrace.current);
      return false;
    } catch (e, st) {
      state = AsyncValue.error('An unexpected error occurred', st);
      return false;
    }
  }

  Future<Map<String, dynamic>?> analyzeImage(XFile image) async {
    try {
      return await _reportRepository.analyzeImage(image);
    } catch (e) {
      // Don't throw or set error state, just return null so UI knows analysis failed but doesn't block submission
      return null;
    }
  }
}

