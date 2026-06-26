import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:go_router/go_router.dart';

import '../providers/home_providers.dart';
import '../widgets/issue_card.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/statistics_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Hero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          if (sizingInformation.deviceScreenType == DeviceScreenType.desktop ||
              sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return _buildDesktopLayout(context, ref);
          }
          return _buildMobileLayout(context, ref);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/report'),
        icon: const Icon(Icons.add_alert),
        label: const Text('Report Issue'),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SearchFilterBar(),
          const SizedBox(height: 24),
          _buildStatsOverview(ref),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Nearby Issues', () => context.go('/map')),
          _buildNearbyIssuesList(ref),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Recent Issues', () {}),
          _buildRecentIssuesList(ref),
          const SizedBox(height: 80), // Padding for FAB
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 400,
            child: SearchFilterBar(),
          ),
          const SizedBox(height: 24),
          _buildStatsOverview(ref),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Nearby Issues', () => context.go('/map')),
                      Expanded(child: _buildNearbyIssuesList(ref)),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Recent Issues', () {}),
                      Expanded(child: _buildRecentIssuesList(ref)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, VoidCallback onSeeAll) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: () => context.go('/feed'),
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return statsAsync.when(
      data: (stats) => LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 600;
          return GridView.count(
            crossAxisCount: isSmall ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isSmall ? 1.5 : 2.0,
            children: [
              StatisticsCard(
                title: 'Total Issues',
                value: stats.totalIssues.toString(),
                icon: Icons.report_problem_outlined,
                color: Colors.blue,
              ),
              StatisticsCard(
                title: 'Resolved',
                value: stats.resolvedIssues.toString(),
                icon: Icons.check_circle_outline,
                color: Colors.green,
              ),
              StatisticsCard(
                title: 'Pending',
                value: stats.pendingIssues.toString(),
                icon: Icons.hourglass_empty,
                color: Colors.orange,
              ),
              StatisticsCard(
                title: 'Verified',
                value: stats.verifiedIssues.toString(),
                icon: Icons.verified_user_outlined,
                color: Colors.purple,
              ),
            ],
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading stats: $err')),
    );
  }

  Widget _buildNearbyIssuesList(WidgetRef ref) {
    final issuesAsync = ref.watch(nearbyIssuesProvider);

    return issuesAsync.when(
      data: (issues) {
        if (issues.isEmpty) {
          return const Center(child: Text('No issues reported near you!'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: issues.length,
          itemBuilder: (context, index) => IssueCard(issue: issues[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildRecentIssuesList(WidgetRef ref) {
    final issuesAsync = ref.watch(recentIssuesProvider);

    return issuesAsync.when(
      data: (issues) {
        if (issues.isEmpty) {
          return const Center(child: Text('No recent issues.'));
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: issues.length,
          itemBuilder: (context, index) => IssueCard(issue: issues[index]),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}
