import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/issue_details_controller.dart';
import '../../../../models/issue.dart';

class IssueDetailsScreen extends ConsumerWidget {
  final String issueId;

  const IssueDetailsScreen({super.key, required this.issueId});

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

  void _shareIssue(Issue issue) {
    final text = 'Check out this issue on Community Hero: ${issue.title} (${issue.category})\nLocation: ${issue.latitude}, ${issue.longitude}';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(issueDetailsProvider(issueId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
        actions: [
          if (stateAsync.value?.issue != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareIssue(stateAsync.value!.issue!),
            )
        ],
      ),
      body: stateAsync.when(
        data: (state) {
          final issue = state.issue;
          if (issue == null) {
            return const Center(child: Text('Issue not found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Section
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey.shade200,
                  child: issue.imageUrl != null
                      ? Image.network(issue.imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              issue.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Chip(
                            label: Text(issue.status, style: const TextStyle(color: Colors.white)),
                            backgroundColor: issue.status.toLowerCase() == 'resolved' ? Colors.green : Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Metadata Tags (AI Category, Severity)
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                            label: Text(issue.category, style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.purple,
                          ),
                          Chip(
                            avatar: const Icon(Icons.warning, size: 16, color: Colors.white),
                            label: Text(issue.severity, style: const TextStyle(color: Colors.white)),
                            backgroundColor: _getSeverityColor(issue.severity),
                          ),
                          Chip(
                            avatar: const Icon(Icons.verified, size: 16, color: Colors.blue),
                            label: Text('${issue.verificationCount} Verifications'),
                            backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(issue.description),
                      const SizedBox(height: 24),

                      // Timeline
                      if (state.timeline.isNotEmpty) ...[
                        Text('Timeline', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        ...state.timeline.map((event) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.timeline),
                              title: Text('Status changed to ${event['new_status']}'),
                              subtitle: Text(event['timestamp'].toString()),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // Map Location
                      Text('Location', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(issue.latitude, issue.longitude),
                              initialZoom: 15.0,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none, // Read-only map
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.communityhero.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(issue.latitude, issue.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: state.isVerifying
                              ? null
                              : () async {
                                  final success = await ref.read(issueDetailsProvider(issueId).notifier).verifyIssue();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(success ? 'Issue verified successfully!' : 'Verification failed.'),
                                        backgroundColor: success ? Colors.green : Colors.red,
                                      ),
                                    );
                                  }
                                },
                          icon: state.isVerifying
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Icon(Icons.verified_user),
                          label: const Text('I am here! Verify Issue'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
