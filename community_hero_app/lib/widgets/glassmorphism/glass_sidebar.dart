import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'glass_container.dart';

class GlassSidebar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const GlassSidebar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: GlassContainer(
        borderRadius: 24,
        blurX: 30,
        blurY: 30,
        opacity: 0.1,
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            // User Profile Section
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              'Alex Chen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),

            // Navigation Links
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              isSelected: navigationShell.currentIndex == 3, // Assuming Dashboard is index 3
              onTap: () => _onTap(3),
            ),
            const SizedBox(height: 8),
            _NavItem(
              icon: Icons.report_problem_rounded,
              label: 'Issues',
              isSelected: navigationShell.currentIndex == 1, // Assuming Map/Issues is index 1
              onTap: () => _onTap(1),
            ),
            const SizedBox(height: 8),
            _NavItem(
              icon: Icons.insert_chart_rounded,
              label: 'Reports',
              isSelected: navigationShell.currentIndex == 2, // Assuming Report is index 2
              onTap: () => _onTap(2),
            ),
            const SizedBox(height: 8),
            _NavItem(
              icon: Icons.people_alt_rounded,
              label: 'Volunteers',
              isSelected: navigationShell.currentIndex == 0, // Assuming Home is index 0
              onTap: () => _onTap(0),
            ),
            const SizedBox(height: 8),
            _NavItem(
              icon: Icons.settings_rounded,
              label: 'Settings',
              isSelected: navigationShell.currentIndex == 4, // Assuming Profile/Settings is index 4
              onTap: () => _onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isSelected
            ? BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white60,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
