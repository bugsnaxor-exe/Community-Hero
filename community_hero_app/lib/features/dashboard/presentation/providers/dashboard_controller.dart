import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_repository.dart';
import '../../../home/presentation/providers/home_providers.dart' as home_providers;
import '../../../feed/presentation/providers/feed_controller.dart' as feed_providers;

class DashboardController extends AutoDisposeAsyncNotifier<Map<String, dynamic>> {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    final repository = ref.watch(dashboardRepositoryProvider);
    return repository.getDashboardAnalytics();
  }

  Future<void> toggleIssueStatus(dynamic issueId, bool isResolved) async {
    final repository = ref.read(dashboardRepositoryProvider);
    final newStatus = isResolved ? 'REPORTED' : 'RESOLVED';
    await repository.updateIssueStatus(issueId, newStatus);
    ref.invalidateSelf();
    ref.invalidate(home_providers.nearbyIssuesProvider);
    ref.invalidate(feed_providers.feedControllerProvider);
  }
}

final dashboardControllerProvider = AsyncNotifierProvider.autoDispose<DashboardController, Map<String, dynamic>>(() => DashboardController());
