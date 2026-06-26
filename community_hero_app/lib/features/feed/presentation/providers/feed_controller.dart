import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/feed_repository.dart';
import '../../../../models/issue.dart';

// 1. The active filter state
final feedCategoryFilterProvider = StateProvider<String>((ref) => 'All');

// 2. The Pagination State Holder
class FeedState {
  final List<Issue> issues;
  final bool isLoadingMore;
  final bool hasReachedMax;

  FeedState({
    this.issues = const [],
    this.isLoadingMore = false,
    this.hasReachedMax = false,
  });

  FeedState copyWith({
    List<Issue>? issues,
    bool? isLoadingMore,
    bool? hasReachedMax,
  }) {
    return FeedState(
      issues: issues ?? this.issues,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

// 3. The AsyncNotifier for Infinite Scrolling
final feedControllerProvider = AsyncNotifierProvider<FeedController, FeedState>(() {
  return FeedController();
});

class FeedController extends AsyncNotifier<FeedState> {
  static const int _limit = 10;
  int _offset = 0;

  @override
  FutureOr<FeedState> build() async {
    // When the filter changes, the build method runs again
    // so we reset pagination and fetch the first page.
    ref.listen<String>(feedCategoryFilterProvider, (previous, next) {
      if (previous != next) {
        refresh();
      }
    });

    _offset = 0;
    return _fetchInitial();
  }

  Future<FeedState> _fetchInitial() async {
    final repo = ref.read(feedRepositoryProvider);
    final category = ref.read(feedCategoryFilterProvider);

    final issues = await repo.getIssues(limit: _limit, offset: _offset, category: category);
    
    return FeedState(
      issues: issues,
      hasReachedMax: issues.length < _limit,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _offset = 0;
    state = await AsyncValue.guard(() => _fetchInitial());
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    // Skip if currently loading, already reached max, or if there's no data yet.
    if (currentState == null || currentState.isLoadingMore || currentState.hasReachedMax) return;

    // Set loading indicator for the bottom spinner
    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    try {
      _offset += _limit;
      final repo = ref.read(feedRepositoryProvider);
      final category = ref.read(feedCategoryFilterProvider);
      
      final newIssues = await repo.getIssues(limit: _limit, offset: _offset, category: category);

      state = AsyncValue.data(currentState.copyWith(
        issues: [...currentState.issues, ...newIssues],
        hasReachedMax: newIssues.length < _limit,
        isLoadingMore: false,
      ));
    } catch (e) {
      // Revert loading state but don't drop the entire list
      state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      // Optionally handle error (e.g. log it or set a separate error state)
    }
  }
}

