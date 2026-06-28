import 'dart:async';
import 'dart:io';
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
    List<File> images = const [],
  }) async {
    state = const AsyncValue.loading();
    try {
      // Automatically fetch the user's current GPS location
      final position = await _locationService.getCurrentLocation();

      await _reportRepository.submitReport(
        title: title,
        description: description,
        category: category,
        severity: severity,
        latitude: position.latitude,
        longitude: position.longitude,
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

  Future<Map<String, dynamic>?> analyzeImage(File imageFile) async {
    try {
      return await _reportRepository.analyzeImage(imageFile);
    } catch (e) {
      // Don't throw or set error state, just return null so UI knows analysis failed but doesn't block submission
      return null;
    }
  }
}

