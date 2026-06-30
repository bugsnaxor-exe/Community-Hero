import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../widgets/bounce_button.dart';
import '../providers/issue_details_controller.dart';
import '../../../../models/issue.dart';

class IssueDetailsScreen extends ConsumerStatefulWidget {
  final String issueId;

  const IssueDetailsScreen({super.key, required this.issueId});

  @override
  ConsumerState<IssueDetailsScreen> createState() => _IssueDetailsScreenState();
}

class _IssueDetailsScreenState extends ConsumerState<IssueDetailsScreen> {
  int _currentImageIndex = 0;

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFD32F2F);
      case 'high':
        return const Color(0xFFF57C00);
      case 'medium':
        return const Color(0xFFFBC02D);
      default:
        return const Color(0xFF388E3C);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
      case 'closed':
        return Colors.green;
      case 'in_progress':
      case 'assigned':
        return Colors.blue;
      case 'verified':
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }

  void _shareIssue(Issue issue) {
    final text = 'Check out this issue on Sync City:\n${issue.title} (${issue.category})\nLocation: ${issue.latitude.toStringAsFixed(6)}, ${issue.longitude.toStringAsFixed(6)}';
    Share.share(text);
  }

  String _buildImageUrl(String rawUrl) {
    if (rawUrl.startsWith('http')) return rawUrl;
    final baseDomain = AppConstants.baseUrl.replaceAll(RegExp(r'/api$'), '');
    return '$baseDomain$rawUrl';
  }

  @override
  Widget build(BuildContext context) {
    final stateAsync = ref.watch(issueDetailsProvider(widget.issueId));
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/dashboard');
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: stateAsync.when(
          data: (state) {
            final issue = state.issue;
            if (issue == null) {
              return Scaffold(
                appBar: AppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
                  ),
                  title: const Text('Issue Details'),
                ),
                body: const Center(child: Text('Issue not found')),
              );
            }

            // Collect all image URLs
            final List<String> imageUrls = [];
            if (issue.images.isNotEmpty) {
              for (final img in issue.images) {
                imageUrls.add(_buildImageUrl(img.imageUrl));
              }
            } else if (issue.imageUrl != null && issue.imageUrl!.isNotEmpty) {
              imageUrls.add(_buildImageUrl(issue.imageUrl!));
            }

            final hasValidLocation = issue.latitude != 0.0 || issue.longitude != 0.0;

            return CustomScrollView(
              slivers: [
                // Collapsible App Bar with image
                SliverAppBar(
                  expandedHeight: imageUrls.isNotEmpty ? 300.0 : 0.0,
                  floating: false,
                  pinned: true,
                  leading: IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
                  ),
                  actions: [
                    IconButton(
                      icon: Container(
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.share, color: Colors.white),
                      ),
                      onPressed: () => _shareIssue(issue),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: imageUrls.isNotEmpty
                      ? FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              PageView.builder(
                                itemCount: imageUrls.length,
                                onPageChanged: (i) => setState(() => _currentImageIndex = i),
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade900,
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                    errorBuilder: (context, error, stack) => Container(
                                      color: Colors.grey.shade900,
                                      child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                              // Image counter dots
                              if (imageUrls.length > 1)
                                Positioned(
                                  bottom: 12,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(imageUrls.length, (i) => Container(
                                      width: _currentImageIndex == i ? 12 : 7,
                                      height: 7,
                                      margin: const EdgeInsets.symmetric(horizontal: 3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: _currentImageIndex == i ? Colors.white : Colors.white54,
                                      ),
                                    )),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : null,
                  title: imageUrls.isEmpty
                      ? Text(issue.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                      : null,
                ),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          issue.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Status & metadata chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatusChip(
                              label: _formatStatus(issue.status),
                              color: _getStatusColor(issue.status),
                            ),
                            _StatusChip(
                              label: issue.category,
                              color: Colors.purple,
                              icon: Icons.category,
                            ),
                            _StatusChip(
                              label: issue.severity,
                              color: _getSeverityColor(issue.severity),
                              icon: Icons.warning_amber_rounded,
                            ),
                            _StatusChip(
                              label: '${issue.verificationCount} Verified',
                              color: Colors.teal,
                              icon: Icons.verified,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Description
                        _SectionHeader(title: 'Description', icon: Icons.description),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            issue.description.isEmpty ? 'No description provided.' : issue.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Timeline
                        if (state.timeline.isNotEmpty) ...[
                          _SectionHeader(title: 'Timeline', icon: Icons.timeline),
                          const SizedBox(height: 8),
                          ...state.timeline.asMap().entries.map((entry) {
                            final event = entry.value;
                            final isLast = entry.key == state.timeline.length - 1;
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: 12, height: 12,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue, shape: BoxShape.circle,
                                      ),
                                    ),
                                    if (!isLast)
                                      Container(width: 2, height: 36, color: Colors.blue.withValues(alpha: 0.3)),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Status → ${_formatStatus(event['new_status']?.toString() ?? '')}',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          event['timestamp']?.toString() ?? '',
                                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 24),
                        ],

                        // Map Location
                        _SectionHeader(title: 'Location', icon: Icons.location_on),
                        const SizedBox(height: 8),
                        if (hasValidLocation) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              height: 220,
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(issue.latitude, issue.longitude),
                                  initialZoom: 15.0,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.none,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.synccity.app',
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(issue.latitude, issue.longitude),
                                        width: 48,
                                        height: 48,
                                        child: const Icon(
                                          Icons.location_pin,
                                          color: Colors.red,
                                          size: 48,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${issue.latitude.toStringAsFixed(6)}, ${issue.longitude.toStringAsFixed(6)}',
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ] else
                          Container(
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Text('Location not available', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        const SizedBox(height: 32),

                        // Verify Button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: state.isVerifying
                                ? null
                                : () async {
                                    final errorMsg = await ref
                                        .read(issueDetailsProvider(widget.issueId).notifier)
                                        .verifyIssue();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(errorMsg ?? 'Issue verified successfully!'),
                                          backgroundColor: errorMsg == null ? Colors.green : Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            icon: state.isVerifying
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.verified_user),
                            label: Text(state.isVerifying ? 'Verifying...' : 'I am here! Verify Issue'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
              ),
            ),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.canPop() ? context.pop() : context.go('/dashboard'),
              ),
              title: const Text('Issue Details'),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Failed to load issue', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(err.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(issueDetailsProvider(widget.issueId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Helper Widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const _StatusChip({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
