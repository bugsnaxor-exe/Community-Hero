import 'package:flutter/material.dart';

class LeaderboardWidget extends StatelessWidget {
  final List<dynamic> leaderboard;

  const LeaderboardWidget({super.key, required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('Top Community Heroes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        if (leaderboard.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No leaderboard data yet.'),
          ),
        ...leaderboard.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final isTop3 = index < 3;
          
          Color? medalColor;
          if (index == 0) medalColor = Colors.amber;
          else if (index == 1) medalColor = Colors.grey[400];
          else if (index == 2) medalColor = Colors.brown[300];

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isTop3 ? medalColor?.withOpacity(0.2) : Colors.grey[200],
              child: isTop3 
                  ? Icon(Icons.star, color: medalColor)
                  : Text('${index + 1}', style: TextStyle(color: Colors.grey[700])),
            ),
            title: Text(user['email'].toString().split('@')[0]), // Safe display name fallback
            trailing: Chip(
              label: Text('${user['reputation_score']} pts'),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          );
        }),
      ],
    );
  }
}
