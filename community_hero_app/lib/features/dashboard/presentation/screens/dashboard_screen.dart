import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../widgets/glassmorphism/glass_container.dart';
import '../../../../widgets/glassmorphism/neon_card.dart';
import '../widgets/nearby_issues_sidebar.dart';
import '../providers/dashboard_controller.dart';

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Community Hero',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _GlassSearchBar(),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // KPI Cards Row
                    SizedBox(
                      height: 320,
                      child: Row(
                        children: [
                          Expanded(child: _OpenIssuesCard(stats: dashboardState.value?['stats'])),
                          const SizedBox(width: 24),
                          Expanded(child: _ResolvedCard(stats: dashboardState.value?['stats'])),
                          const SizedBox(width: 24),
                          const Expanded(child: _NewVolunteersCard()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Recent Activity
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _RecentActivityList(activities: dashboardState.value?['recent_activity'] ?? []),
                    ),
                  ],
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
  @override
  Widget build(BuildContext context) {
    return const GlassContainer(
      width: 250,
      height: 48,
      borderRadius: 24,
      blurX: 10,
      blurY: 10,
      opacity: 0.1,
      backgroundColor: Colors.white,
      borderWidth: 1.0,
      borderColor: Colors.white24,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.white60, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.white60),
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

class _OpenIssuesCard extends StatelessWidget {
  final Map<String, dynamic>? stats;
  const _OpenIssuesCard({this.stats});

  @override
  Widget build(BuildContext context) {
    final value = stats?['total_issues'] ?? 127; // Fallback to mockup value
    return NeonCard(
      glowColor: const Color(0xFF00FF5E), // Intense Neon Green
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('Open Issues', style: TextStyle(color: Colors.white70)),
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
                        const style = TextStyle(color: Colors.white54, fontSize: 12);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('Mon', style: style); break;
                          case 1: text = const Text('Tue', style: style); break;
                          case 2: text = const Text('Wed', style: style); break;
                          case 3: text = const Text('Thu', style: style); break;
                          case 4: text = const Text('Fri', style: style); break;
                          case 5: text = const Text('Sat', style: style); break;
                          default: text = const Text('', style: style); break;
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
                      FlSpot(5, 3),
                      FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: const Color(0xFF00FF5E),
                    barWidth: 2,
                    isStrokeCapRound: true,
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
    return NeonCard(
      glowColor: const Color(0xFF00B2FF), // Intense Neon Blue
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '85%',
            style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('Resolved', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 0.85,
                      strokeWidth: 10,
                      backgroundColor: const Color(0xFF00B2FF).withValues(alpha: 0.2),
                      color: const Color(0xFF00B2FF),
                    ),
                    const Center(
                      child: Text('85%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Community Impact', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }
}

class _NewVolunteersCard extends StatelessWidget {
  const _NewVolunteersCard();

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      glowColor: const Color(0xFFE228FF), // Intense Neon Magenta
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '312',
            style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const Text('New Volunteers', style: TextStyle(color: Colors.white70)),
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
                        const style = TextStyle(color: Colors.white54, fontSize: 12);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('11st', style: style); break;
                          case 1: text = const Text('We', style: style); break;
                          case 2: text = const Text('Th', style: style); break;
                          case 3: text = const Text('Fri', style: style); break;
                          case 4: text = const Text('Sat', style: style); break;
                          default: text = const Text('', style: style); break;
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

class _RecentActivityList extends StatelessWidget {
  final List<dynamic> activities;
  const _RecentActivityList({required this.activities});

  @override
  Widget build(BuildContext context) {
    // Generate some mock items if empty
    final items = activities.isNotEmpty ? activities : [
      {'title': 'Alex Chen was answered', 'time': '3 minutes ago', 'subtitle': '13 weeks ago', 'icon': Icons.comment, 'color': const Color(0xFF00FF5E)},
      {'title': 'Community Impact in Resolved', 'time': '2 mins ago', 'subtitle': '30 weeks ago', 'icon': Icons.flag, 'color': const Color(0xFFE228FF)},
      {'title': 'Community Impact started', 'time': '41 mins ago', 'subtitle': '41 weeks ago', 'icon': Icons.play_arrow, 'color': const Color(0xFF00B2FF)},
    ];

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          blurX: 10,
          blurY: 10,
          opacity: 0.05,
          backgroundColor: Colors.white,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (item['color'] as Color? ?? Colors.white).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item['icon'] as IconData? ?? Icons.notifications, color: item['color'] as Color? ?? Colors.white70, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'] as String? ?? 'Activity',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String? ?? '',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                item['time'] as String? ?? 'Just now',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}
