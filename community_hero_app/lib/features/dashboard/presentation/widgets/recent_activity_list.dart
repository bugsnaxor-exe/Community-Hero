import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecentActivityList extends StatelessWidget {
  final List<dynamic> activities;

  const RecentActivityList({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        if (activities.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No recent activity on the platform.'),
          ),
        ...activities.map((activity) {
          final isResolved = activity['status'] == 'RESOLVED';
          final isVerified = activity['status'] == 'VERIFIED';
          
          IconData icon = Icons.report_problem;
          Color color = Colors.orange;

          if (isResolved) {
            icon = Icons.check_circle;
            color = Colors.green;
          } else if (isVerified) {
            icon = Icons.verified;
            color = Colors.blue;
          }

          return ListTile(
            leading: Icon(icon, color: color),
            title: Text(activity['title']),
            subtitle: Text('${activity['category']} • ${activity['status']}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/issue-details/${activity['id']}');
            },
          );
        }),
      ],
    );
  }
}
