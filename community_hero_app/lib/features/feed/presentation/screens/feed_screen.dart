import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/feed_controller.dart';
import '../../../home/presentation/widgets/issue_card.dart';
import '../../../../widgets/app_background.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<String> _filters = [
    'All',
    'Pothole',
    'Streetlight Out',
    'Graffiti',
    'Litter',
    'Water Leak'
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // If we are within 200 pixels of the bottom, load more
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(feedControllerProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedStateAsync = ref.watch(feedControllerProvider);
    final activeFilter = ref.watch(feedCategoryFilterProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Issue Feed'),
          leading: BackButton(onPressed: () => context.go('/home')),
          bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref.read(feedCategoryFilterProvider.notifier).state = filter;
                      }
                    },
                    selectedColor: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    checkmarkColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      body: feedStateAsync.when(
        data: (feedState) {
          if (feedState.issues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No issues found for "$activeFilter"'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(feedCategoryFilterProvider.notifier).state = 'All',
                    child: const Text('Clear Filters'),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: feedState.issues.length + (feedState.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == feedState.issues.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final issue = feedState.issues[index];
                return IssueCard(issue: issue);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(feedControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
      ),
    ));
  }
}
