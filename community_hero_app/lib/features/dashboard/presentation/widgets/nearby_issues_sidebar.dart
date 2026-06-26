import 'package:flutter/material.dart';
import '../../../../widgets/glassmorphism/glass_container.dart';
import '../../../../models/issue.dart';

class NearbyIssuesSidebar extends StatelessWidget {
  const NearbyIssuesSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for UI layout
    final issues = [
      Issue(id: '1', title: 'Pothole on Elm St', description: '', category: 'Infrastructure', severity: 'High', latitude: 0, longitude: 0, status: 'Open', createdAt: DateTime.now()),
      Issue(id: '2', title: 'Park Cleanup', description: '', category: 'Environment', severity: 'Low', latitude: 0, longitude: 0, status: 'Resolved', createdAt: DateTime.now()),
      Issue(id: '3', title: 'Streetlight Out', description: '', category: 'Infrastructure', severity: 'Medium', latitude: 0, longitude: 0, status: 'Open', createdAt: DateTime.now()),
    ];

    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: GlassContainer(
        borderRadius: 24,
        blurX: 30,
        blurY: 30,
        opacity: 0.1,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nearby Issues',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: issues.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(12),
                    blurX: 5,
                    blurY: 5,
                    opacity: 0.1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map icon placeholder
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.map, color: Colors.white70),
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Icon(Icons.more_horiz, color: Colors.white60, size: 16),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '- ${index + 1}h ago',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: issue.status == 'Resolved' 
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
                                        color: issue.status == 'Resolved' ? Colors.blue : Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Status',
                                      style: TextStyle(
                                        color: issue.status == 'Resolved' ? Colors.blue : Colors.green,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
