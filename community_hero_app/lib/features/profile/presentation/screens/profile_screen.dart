import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../providers/profile_controller.dart';
import '../../../../models/user.dart';
import '../../../../models/issue.dart';
import '../../../home/presentation/widgets/issue_card.dart';

final profileSubTabProvider = StateProvider.autoDispose<String>((ref) => 'reported');

class BadgeItem {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  BadgeItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });
}

List<BadgeItem> calculateBadges(User user, int reportedCount, int verifiedCount) {
  return [
    BadgeItem(
      title: 'Green Citizen',
      description: 'Reported your first community issue',
      icon: Icons.eco,
      isUnlocked: reportedCount >= 1,
      color: Colors.green,
    ),
    BadgeItem(
      title: 'Eco Watchdog',
      description: 'Reported 5 or more community issues',
      icon: Icons.shield,
      isUnlocked: reportedCount >= 5,
      color: Colors.teal,
    ),
    BadgeItem(
      title: 'Community Pillar',
      description: 'Reported 10 or more community issues',
      icon: Icons.domain,
      isUnlocked: reportedCount >= 10,
      color: Colors.indigo,
    ),
    BadgeItem(
      title: 'First Responder',
      description: 'Verified your first community issue',
      icon: Icons.flash_on,
      isUnlocked: verifiedCount >= 1,
      color: Colors.amber,
    ),
    BadgeItem(
      title: 'Truth Seeker',
      description: 'Verified 5 or more community issues',
      icon: Icons.verified_user,
      isUnlocked: verifiedCount >= 5,
      color: Colors.blue,
    ),
    BadgeItem(
      title: 'Local Hero',
      description: 'Verified 15 or more community issues',
      icon: Icons.stars,
      isUnlocked: verifiedCount >= 15,
      color: Colors.purple,
    ),
    BadgeItem(
      title: 'Rising Star',
      description: 'Reached Level 2',
      icon: Icons.trending_up,
      isUnlocked: user.level >= 2,
      color: Colors.orange,
    ),
    BadgeItem(
      title: 'Veteran Defender',
      description: 'Reached Level 5',
      icon: Icons.military_tech,
      isUnlocked: user.level >= 5,
      color: Colors.red,
    ),
  ];
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settings', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface), onPressed: () {}),
        ],
      ),
      body: profileState.when(
        data: (user) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.read(profileControllerProvider.notifier).refresh();
              ref.invalidate(myReportedIssuesProvider);
              ref.invalidate(myVerifiedIssuesProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _ProfileHeader(user: user),
                  Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
                  _GamificationStats(user: user),
                  Divider(height: 1, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.12)),
                  _ProfileTabContent(user: user),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await ref.read(authControllerProvider.notifier).logout();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Session Expired or Unauthorized',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please log in again to continue.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Go to Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
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

class _ProfileHeader extends StatelessWidget {
  final User user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  (user.name?.isNotEmpty == true ? user.name!.substring(0, 1) : user.email.substring(0, 1)).toUpperCase(),
                  style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified, color: Colors.white, size: 20),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name?.isNotEmpty == true ? user.name! : 'Unknown Hero',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
          ),
          Text(
            '@${(user.name?.isNotEmpty == true ? user.name! : user.email.split('@').first).replaceAll(' ', '').toLowerCase()}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}

class _GamificationStats extends ConsumerWidget {
  final User user;

  const _GamificationStats({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLevelBaseXP = (user.level - 1) * 200;
    final nextLevelXP = user.level * 200;
    final progress = (user.reputationScore - currentLevelBaseXP) / (nextLevelXP - currentLevelBaseXP);

    final reportedAsync = ref.watch(myReportedIssuesProvider);
    final verifiedAsync = ref.watch(myVerifiedIssuesProvider);
    final selectedTab = ref.watch(profileSubTabProvider);

    final reportedCount = reportedAsync.valueOrNull?.length ?? 0;
    final verifiedCount = verifiedAsync.valueOrNull?.length ?? 0;
    final badgesCount = calculateBadges(user, reportedCount, verifiedCount).where((b) => b.isUnlocked).length;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Level ${user.level}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
              Text('${user.reputationScore} / $nextLevelXP XP', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.report_problem,
                value: reportedAsync.when(
                  data: (list) => '${list.length}',
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
                label: 'Reported',
                isSelected: selectedTab == 'reported',
                onTap: () => ref.read(profileSubTabProvider.notifier).state = 'reported',
              ),
              _StatItem(
                icon: Icons.check_circle,
                value: verifiedAsync.when(
                  data: (list) => '${list.length}',
                  loading: () => '...',
                  error: (_, __) => '0',
                ),
                label: 'Verified',
                isSelected: selectedTab == 'verified',
                onTap: () => ref.read(profileSubTabProvider.notifier).state = 'verified',
              ),
              _StatItem(
                icon: Icons.military_tech,
                value: '$badgesCount',
                label: 'Badges',
                isSelected: selectedTab == 'badges',
                onTap: () => ref.read(profileSubTabProvider.notifier).state = 'badges',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = Theme.of(context).primaryColor;
    final textColor = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.08) : Colors.transparent,
          border: Border.all(
            color: isSelected ? activeColor.withOpacity(0.3) : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? activeColor : textColor.withOpacity(0.6),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isSelected ? activeColor : textColor,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : textColor.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTabContent extends ConsumerWidget {
  final User user;

  const _ProfileTabContent({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(profileSubTabProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;

    switch (selectedTab) {
      case 'reported':
        final reportedAsync = ref.watch(myReportedIssuesProvider);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Reported Issues',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
              ),
              const SizedBox(height: 16),
              reportedAsync.when(
                data: (issues) {
                  if (issues.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'You haven\'t reported any issues yet.',
                          style: TextStyle(color: textColor.withOpacity(0.6)),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: issues.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: IssueCard(issue: issues[index]),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('Error loading issues: $error', style: const TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'verified':
        final verifiedAsync = ref.watch(myVerifiedIssuesProvider);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Verified Issues',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
              ),
              const SizedBox(height: 16),
              verifiedAsync.when(
                data: (issues) {
                  if (issues.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          'You haven\'t verified any issues yet.',
                          style: TextStyle(color: textColor.withOpacity(0.6)),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: issues.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: IssueCard(issue: issues[index]),
                      );
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Text('Error loading verifications: $error', style: const TextStyle(color: Colors.redAccent)),
                  ),
                ),
              ),
            ],
          ),
        );

      case 'badges':
        final reportedAsync = ref.watch(myReportedIssuesProvider);
        final verifiedAsync = ref.watch(myVerifiedIssuesProvider);

        final reportedCount = reportedAsync.valueOrNull?.length ?? 0;
        final verifiedCount = verifiedAsync.valueOrNull?.length ?? 0;
        final badges = calculateBadges(user, reportedCount, verifiedCount);

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Achievements & Badges',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: badge.isUnlocked
                          ? badge.color.withOpacity(0.08)
                          : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02)),
                      border: Border.all(
                        color: badge.isUnlocked
                            ? badge.color.withOpacity(0.3)
                            : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: badge.isUnlocked
                                  ? badge.color.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              child: Icon(
                                badge.icon,
                                size: 28,
                                color: badge.isUnlocked ? badge.color : Colors.grey,
                              ),
                            ),
                            if (!badge.isUnlocked)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lock, size: 12, color: Colors.grey),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: badge.isUnlocked ? textColor : textColor.withOpacity(0.5),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          badge.description,
                          style: TextStyle(
                            fontSize: 10,
                            color: textColor.withOpacity(0.4),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
