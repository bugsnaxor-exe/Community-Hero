import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'glassmorphism/glass_sidebar.dart';
import 'glassmorphism/glass_container.dart';
import 'app_background.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final glassBgColor = isDark ? const Color(0xFF0A0F1A) : Colors.white;
    final glassOpacity = isDark ? 0.6 : 0.6;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    return AppBackground(
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
                          opacity: glassOpacity,
                          backgroundColor: glassBgColor,
                          borderRadius: 24,
                          borderColor: borderColor,
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
                    backgroundColor: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
                    indicatorColor: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1),
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: _onTap,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: 'Dashboard',
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
                  icon: Icon(Icons.people_alt_outlined),
                  selectedIcon: Icon(Icons.people_alt),
                  label: 'Volunteers',
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
    );
  }
}
