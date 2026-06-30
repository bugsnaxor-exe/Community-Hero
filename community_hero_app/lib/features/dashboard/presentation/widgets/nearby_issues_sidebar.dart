import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../widgets/glassmorphism/glass_container.dart';
import '../../../../models/issue.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../providers/dashboard_controller.dart';

class NearbyIssuesSidebar extends ConsumerWidget {
  const NearbyIssuesSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    final hintColor = isDark ? Colors.white38 : Colors.black38;

    final nearbyIssuesAsync = ref.watch(nearbyIssuesProvider);

    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: GlassContainer(
        borderRadius: 24,
        blurX: 30,
        blurY: 30,
        opacity: isDark ? 0.1 : 0.7,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Issues',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: subtextColor),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: nearbyIssuesAsync.when(
                data: (issues) {
                  if (issues.isEmpty) {
                    return Center(
                      child: Text('No nearby issues', style: TextStyle(color: hintColor)),
                    );
                  }
                  return ListView.separated(
                    itemCount: issues.length > 5 ? 5 : issues.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final issue = issues[index];
                      // Calculate time ago
                      String timeAgo = 'Just now';
                      if (issue.createdAt != null) {
                        String ds = issue.createdAt!.toIso8601String();
                        if (!ds.endsWith('Z')) ds += 'Z';
                        final date = DateTime.parse(ds).toLocal();
                        final diff = DateTime.now().difference(date);
                        if (diff.inDays > 0) {
                          timeAgo = '${diff.inDays}d ago';
                        } else if (diff.inHours > 0) {
                          timeAgo = '${diff.inHours}h ago';
                        } else if (diff.inMinutes > 0) {
                          timeAgo = '${diff.inMinutes}m ago';
                        }
                      }
                      
                      return InkWell(
                        onTap: () => context.push('/issue-details/${issue.id}'),
                        borderRadius: BorderRadius.circular(16),
                        child: GlassContainer(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          blurX: 5,
                          blurY: 5,
                          opacity: isDark ? 0.1 : 0.4,
                          backgroundColor: Colors.white,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          issue.imageUrl!.startsWith('http') ? issue.imageUrl! : 'https://community-hero.onrender.com${issue.imageUrl!}',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(Icons.map, color: subtextColor),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            issue.title,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Icon(Icons.more_horiz, color: hintColor, size: 16),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '- $timeAgo',
                                      style: TextStyle(
                                        color: subtextColor,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: issue.status.toLowerCase() == 'resolved' 
                                                ? Colors.blue.withValues(alpha: 0.2) 
                                                : Colors.green.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: issue.status.toLowerCase() == 'resolved' ? Colors.blue : Colors.green,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                issue.status,
                                                style: TextStyle(
                                                  color: issue.status.toLowerCase() == 'resolved' ? Colors.blue : Colors.green,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () {
                                              final isResolved = issue.status.toLowerCase() == 'resolved';
                                              ref.read(dashboardControllerProvider.notifier).toggleIssueStatus(issue.id, isResolved);
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: (issue.status.toLowerCase() == 'resolved') ? Colors.orange.withValues(alpha: 0.2) : Colors.green.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: (issue.status.toLowerCase() == 'resolved') ? Colors.orange.withValues(alpha: 0.5) : Colors.green.withValues(alpha: 0.5)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon((issue.status.toLowerCase() == 'resolved') ? Icons.undo : Icons.check_circle_outline, color: (issue.status.toLowerCase() == 'resolved') ? Colors.orange : Colors.green, size: 10),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    (issue.status.toLowerCase() == 'resolved') ? 'Reopen' : 'Resolve',
                                                    style: TextStyle(color: (issue.status.toLowerCase() == 'resolved') ? Colors.orange : Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error loading issues', style: TextStyle(color: Colors.red.withValues(alpha: 0.7)))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
