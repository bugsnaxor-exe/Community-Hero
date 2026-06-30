import 'package:flutter/material.dart';
import '../../../../widgets/glassmorphism/glass_container.dart';
import '../../../../models/issue.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;

  const IssueCard({super.key, required this.issue});

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtextColor = isDark ? Colors.white70 : Colors.black54;
    final hintColor = isDark ? Colors.white54 : Colors.black38;
    final cardBgColor = Colors.white;
    final cardOpacity = isDark ? 0.05 : 0.6;
    final placeholderColor = isDark ? Colors.white38 : Colors.black38;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        borderRadius: 12,
        blurX: 10,
        blurY: 10,
        opacity: cardOpacity,
        backgroundColor: cardBgColor,
        child: InkWell(
          onTap: () => context.go('/issue-details/${issue.id}'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 90,
                    height: 100,
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    child: issue.imageUrl != null && issue.imageUrl!.isNotEmpty
                        ? Image.network(
                            issue.imageUrl!.startsWith('http') 
                                ? issue.imageUrl! 
                                : '${AppConstants.baseUrl.replaceAll(RegExp(r'/api$'), '')}${issue.imageUrl}',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.broken_image_outlined, color: placeholderColor),
                          )
                        : Icon(Icons.image_not_supported_outlined, color: placeholderColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(issue.severity).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              issue.severity.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getSeverityColor(issue.severity),
                              ),
                            ),
                          ),
                          Text(
                            _getTimeAgo(issue.createdAt ?? DateTime.now()),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        issue.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Category & Status
                      Row(
                        children: [
                          Text(
                            issue.category,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: subtextColor,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(width: 8),
                          Text('•', style: TextStyle(color: hintColor)),
                          const SizedBox(width: 8),
                          Text(
                            issue.status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: issue.status.toLowerCase() == 'resolved' ? Colors.green : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Location and Verification Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: hintColor),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${issue.latitude.toStringAsFixed(4)}, ${issue.longitude.toStringAsFixed(4)}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: subtextColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.verified, size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                '${issue.verificationCount}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
