import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'glassmorphism/glass_sidebar.dart';
import 'glassmorphism/glass_container.dart';

class ResponsiveShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ResponsiveShell({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF020617), // Deep dark base color
      ),
      child: Stack(
        children: [
          // Top-Left Cyan Glow
          Positioned(
            top: -300,
            left: -300,
            child: Container(
              width: 500,
              height: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x3300B2FF), // 20% opacity
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Top-Right/Middle Purple Glow
          Positioned(
            top: -300,
            right: -200,
            child: Container(
              width: 500,
              height: 500,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x33E228FF), // 20% opacity
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Bottom-Right Green Glow
          Positioned(
            bottom: -400,
            right: -300,
            child: Container(
              width: 600,
              height: 600,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x3300FF5E), // 20% opacity
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Bottom-Left Dark Blue Glow
          Positioned(
            bottom: -200,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x661E3A8A), // 40% opacity
                    Colors.transparent,
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // Global backdrop filter removed for massive performance gains
          // Foreground content
          Positioned.fill(
            child: ResponsiveBuilder(
              builder: (context, sizingInformation) {
                // Desktop / Tablet layout (Glass Sidebar on the left)
                if (sizingInformation.deviceScreenType == DeviceScreenType.desktop ||
              sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassContainer(
                    width: double.infinity,
                    height: double.infinity,
                    blurX: 50,
                    blurY: 50,
                    opacity: 0.6,
                    backgroundColor: const Color(0xFF0A0F1A),
                    borderRadius: 24,
                    borderColor: Colors.white.withValues(alpha: 0.08),
                    child: Row(
                      children: [
                        GlassSidebar(navigationShell: navigationShell),
                        Expanded(child: navigationShell),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          // Mobile layout (Bottom Navigation Bar)
          return Scaffold(
            backgroundColor: Colors.transparent,
            body: navigationShell,
            bottomNavigationBar: NavigationBar(
              backgroundColor: Colors.black.withValues(alpha: 0.5),
              indicatorColor: Colors.white.withValues(alpha: 0.2),
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onTap,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: 'Volunteers',
                ),
                NavigationDestination(
                  icon: Icon(Icons.report_problem_outlined),
                  selectedIcon: Icon(Icons.report_problem),
                  label: 'Issues',
                ),
                NavigationDestination(
                  icon: Icon(Icons.insert_chart_outlined),
                  selectedIcon: Icon(Icons.insert_chart),
                  label: 'Reports',
                ),
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          );
        },
      ),
    ),
    ],
    ),
    );
  }
}
