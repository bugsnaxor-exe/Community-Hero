import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/leaderboard_controller.dart';
import '../../../../models/user.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardState = ref.watch(leaderboardControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
      ),
      body: leaderboardState.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No heroes yet. Be the first!'));
          }

          final top3 = users.take(3).toList();
          final theRest = users.skip(3).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(leaderboardControllerProvider.notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: _PodiumWidget(top3: top3),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = theRest[index];
                      return _LeaderboardRow(
                        user: user,
                        rank: index + 4,
                      );
                    },
                    childCount: theRest.length,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _PodiumWidget extends StatelessWidget {
  final List<User> top3;

  const _PodiumWidget({required this.top3});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (top3.length > 1) _PodiumItem(user: top3[1], rank: 2, height: 120, color: Colors.blueGrey),
        if (top3.isNotEmpty) _PodiumItem(user: top3[0], rank: 1, height: 160, color: Colors.amber),
        if (top3.length > 2) _PodiumItem(user: top3[2], rank: 3, height: 100, color: Colors.brown.shade300),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final User user;
  final int rank;
  final double height;
  final Color color;

  const _PodiumItem({
    required this.user,
    required this.rank,
    required this.height,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: rank == 1 ? 40 : 30,
          backgroundColor: color,
          child: Text(
            user.name?.substring(0, 1).toUpperCase() ?? 'U',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name ?? 'Unknown',
          style: TextStyle(
            fontWeight: rank == 1 ? FontWeight.bold : FontWeight.normal,
            fontSize: rank == 1 ? 16 : 14,
          ),
        ),
        Text('${user.reputationScore} XP', style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          width: rank == 1 ? 100 : 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: rank == 1 ? 48 : 36,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final User user;
  final int rank;

  const _LeaderboardRow({required this.user, required this.rank});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade200,
        child: Text('#$rank', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
      ),
      title: Text(user.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text('Level ${user.level}'),
      trailing: Text(
        '${user.reputationScore} XP',
        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
      ),
    );
  }
}
