import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../widgets/glassmorphism/glass_container.dart';
import '../../../../widgets/glassmorphism/neon_card.dart';
import '../widgets/nearby_issues_sidebar.dart';
import '../providers/dashboard_controller.dart';
import '../../../../theme/theme_provider.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent, // Background gradient is at Shell level
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // Top Section
                    ResponsiveBuilder(
                      builder: (context, sizingInformation) {
                        final isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
                        if (isMobile) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Sync City',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const _ThemeToggle(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const _GlassSearchBar(width: double.infinity),
                            ],
                          );
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sync City',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Row(
                              children: [
                                _GlassSearchBar(),
                                SizedBox(width: 16),
                                _ThemeToggle(),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // KPI Cards Row
                    ResponsiveBuilder(
                      builder: (context, sizingInformation) {
                        if (sizingInformation.deviceScreenType == DeviceScreenType.mobile) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 320, child: _OpenIssuesCard(stats: dashboardState.value?['stats'])),
                              const SizedBox(height: 16),
                              SizedBox(height: 320, child: _ResolvedCard(stats: dashboardState.value?['stats'])),
                              const SizedBox(height: 16),
                              SizedBox(height: 320, child: _NewVolunteersCard(stats: dashboardState.value?['stats'])),
                            ],
                          );
                        }
                        return SizedBox(
                          height: 320,
                          child: Row(
                            children: [
                              Expanded(child: _OpenIssuesCard(stats: dashboardState.value?['stats'])),
                              const SizedBox(width: 24),
                              Expanded(child: _ResolvedCard(stats: dashboardState.value?['stats'])),
                              const SizedBox(width: 24),
                              Expanded(child: _NewVolunteersCard(stats: dashboardState.value?['stats'])),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Recent Activity
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _RecentActivityList(activities: dashboardState.value?['recent_activity'] ?? []),
                  ],
                ),
              ),
            ),
              
              // Right Sidebar for Desktop/Tablet
              ResponsiveBuilder(
                builder: (context, sizingInformation) {
                  if (sizingInformation.deviceScreenType == DeviceScreenType.desktop || 
                      sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
                    return const Row(
                      children: [
                        SizedBox(width: 24),
                        NearbyIssuesSidebar(),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassSearchBar extends StatelessWidget {
  final double? width;

  const _GlassSearchBar({this.width = 250});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintColor = isDark ? Colors.white60 : Colors.black54;
    final textColor = isDark ? Colors.white : Colors.black87;
    final borderColor = isDark ? Colors.white24 : Colors.black12;

    return GlassContainer(
      width: width,
      height: 48,
      borderRadius: 24,
      blurX: 10,
      blurY: 10,
      opacity: isDark ? 0.1 : 0.6,
      backgroundColor: isDark ? Colors.white : Colors.white.withOpacity(0.8),
      borderWidth: 1.0,
      borderColor: borderColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, color: hintColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: hintColor),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggle extends ConsumerWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          ref.read(themeProvider.notifier).toggleTheme();
        },
      ),
    );
  }
}

class _OpenIssuesCard extends StatelessWidget {
  final Map<String, dynamic>? stats;
  const _OpenIssuesCard({this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final labelColor = isDark ? Colors.white54 : Colors.black45;

    final value = stats?['total_issues'] ?? 127; // Fallback to mockup value
    return NeonCard(
      glowColor: const Color(0xFF00FF5E), // Intense Neon Green
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(color: textColor, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text('Open Issues', style: TextStyle(color: subtitleColor)),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(color: labelColor, fontSize: 12);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = Text('Mon', style: style); break;
                          case 1: text = Text('Tue', style: style); break;
                          case 2: text = Text('Wed', style: style); break;
                          case 3: text = Text('Thu', style: style); break;
                          case 4: text = Text('Fri', style: style); break;
                          case 5: text = Text('Sat', style: style); break;
                          default: text = Text('', style: style); break;
                        }
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: text);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1),
                      FlSpot(1, 1.5),
                      FlSpot(2, 1.2),
                      FlSpot(3, 2),
                      FlSpot(4, 1.8),
                      FlSpot(5, 2.5),
                    ],
                    isCurved: true,
                    color: const Color(0xFF00FF5E),
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF00FF5E).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResolvedCard extends StatelessWidget {
  final Map<String, dynamic>? stats;
  const _ResolvedCard({this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final labelColor = isDark ? Colors.white54 : Colors.black45;

    final total = stats?['total_issues'] ?? 0;
    final resolved = stats?['resolved_issues'] ?? 0;
    final double percentage = total > 0 ? (resolved / total) * 100 : 0.0;
    final double progress = total > 0 ? (resolved / total) : 0.0;

    return NeonCard(
      glowColor: const Color(0xFF00B2FF), // Intense Neon Blue
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(color: textColor, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text('Resolved', style: TextStyle(color: subtitleColor)),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFF00B2FF).withValues(alpha: 0.2),
                      color: const Color(0xFF00B2FF),
                    ),
                    Center(
                      child: Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text('Community Impact', style: TextStyle(color: labelColor, fontSize: 12)),
        ],
      ),
    );
  }
}

class _NewVolunteersCard extends StatelessWidget {
  final Map<String, dynamic>? stats;
  const _NewVolunteersCard({this.stats});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final labelColor = isDark ? Colors.white54 : Colors.black45;

    final value = stats?['total_volunteers'] ?? 0;
    return NeonCard(
      glowColor: const Color(0xFFE228FF), // Intense Neon Magenta
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(color: textColor, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text('New Volunteers', style: TextStyle(color: subtitleColor)),
          Expanded(
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (value, meta) {
                        final style = TextStyle(color: labelColor, fontSize: 12);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = Text('11st', style: style); break;
                          case 1: text = Text('We', style: style); break;
                          case 2: text = Text('Th', style: style); break;
                          case 3: text = Text('Fri', style: style); break;
                          case 4: text = Text('Sat', style: style); break;
                          default: text = Text('', style: style); break;
                        }
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: text);
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildStackedBar(0, 2, 4, 7),
                  _buildStackedBar(1, 3, 5, 8),
                  _buildStackedBar(2, 2, 6, 9),
                  _buildStackedBar(3, 1, 3, 6),
                  _buildStackedBar(4, 4, 7, 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildStackedBar(int x, double y1, double y2, double y3) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y3,
          width: 8,
          borderRadius: BorderRadius.circular(4),
          rodStackItems: [
            BarChartRodStackItem(0, y1, const Color(0xFF00B2FF)), // Bottom: Cyan
            BarChartRodStackItem(y1, y2, const Color(0xFF7E57C2)), // Middle: Light Purple
            BarChartRodStackItem(y2, y3, const Color(0xFFE228FF)), // Top: Magenta
          ],
        ),
      ],
    );
  }
}

class _RecentActivityList extends ConsumerWidget {
  final List<dynamic> activities;
  const _RecentActivityList({required this.activities});

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pothole':
      case 'road_damage':
        return Icons.construction;
      case 'streetlight out':
      case 'broken_streetlight':
        return Icons.lightbulb_outline;
      case 'graffiti':
        return Icons.brush;
      case 'litter':
      case 'garbage_dump':
        return Icons.delete_outline;
      case 'water leak':
      case 'water_leakage':
      case 'drainage_issue':
        return Icons.water_drop_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pothole':
      case 'road_damage':
        return const Color(0xFFFF8A65); // Orange
      case 'streetlight out':
      case 'broken_streetlight':
        return const Color(0xFFFFD54F); // Yellow
      case 'graffiti':
        return const Color(0xFFBA68C8); // Purple
      case 'litter':
      case 'garbage_dump':
        return const Color(0xFF81C784); // Green
      case 'water leak':
      case 'water_leakage':
      case 'drainage_issue':
        return const Color(0xFF4FC3F7); // Blue
      default:
        return const Color(0xFFE228FF); // Magenta
    }
  }

  String _getRelativeTime(String? dateStr) {
    if (dateStr == null) return 'Just now';
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) {
        return '${diff.inDays}d ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h ago';
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (_) {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 48, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
              const SizedBox(height: 12),
              Text(
                'No recent activity found',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                'Report issues to see them appear here',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final itemBgColor = isDark ? Colors.white : Colors.black;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = activities[index];
        final category = item['category'] as String? ?? 'Other';
        final status = item['status'] as String? ?? 'Pending';
        final title = item['title'] as String? ?? 'Community Issue';
        final dateStr = item['created_at'] as String?;

        final icon = _getIconForCategory(category);
        final color = _getColorForCategory(category);
        final timeStr = _getRelativeTime(dateStr);

        return InkWell(
          onTap: () => context.push('/issue-details/${item['id']}'),
          borderRadius: BorderRadius.circular(16),
          child: GlassContainer(
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            blurX: 10,
            blurY: 10,
            opacity: 0.05,
            backgroundColor: itemBgColor,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Status: $status | Category: $category',
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                    ),
                    if (status.toLowerCase() != 'resolved') ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          final id = item['id'];
                          if (id != null) {
                            ref.read(dashboardControllerProvider.notifier).resolveIssue(id);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_outline, color: Colors.green, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Mark Resolved',
                                style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
