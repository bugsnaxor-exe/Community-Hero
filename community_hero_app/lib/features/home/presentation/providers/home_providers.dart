import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../services/location_service.dart';
import '../../../../models/issue.dart';
import '../../../../models/dashboard_stats.dart';

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final dio = ref.watch(dioProvider);
  // Mocking endpoint path assuming /api/dashboard exists
  final response = await dio.get('/dashboard/stats'); 
  return DashboardStats.fromJson(response.data);
});

final recentIssuesProvider = FutureProvider<List<Issue>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/issues', queryParameters: {'limit': 10, 'sort': 'recent'});
  
  final List<dynamic> data = response.data;
  return data.map((json) => Issue.fromJson(json)).toList();
});

final nearbyIssuesProvider = FutureProvider<List<Issue>>((ref) async {
  final dio = ref.watch(dioProvider);
  final locationService = ref.watch(locationServiceProvider);
  
  double latitude;
  double longitude;
  
  try {
    // 1. Try to get the current device GPS location
    final position = await locationService.getCurrentLocation();
    latitude = position.latitude;
    longitude = position.longitude;
  } catch (e) {
    // 2. Fallback to default coordinates if GPS fails (near test issues)
    latitude = 24.175;
    longitude = 87.786;
  }
  
  // 3. Fetch issues around this location within a 500km radius (for demo visibility)
  final response = await dio.get('/issues/nearby', queryParameters: {
    'lat': latitude,
    'lng': longitude,
    'radius': 500, // 500 km
  });
  
  final List<dynamic> data = response.data;
  return data.map((json) => Issue.fromJson(json)).toList();
});
