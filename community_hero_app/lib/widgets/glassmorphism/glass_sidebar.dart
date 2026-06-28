import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'glass_container.dart';
import '../../features/profile/presentation/providers/profile_controller.dart';

class GlassSidebar extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const GlassSidebar({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;

    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: GlassContainer(
        borderRadius: 24,
        blurX: 30,
        blurY: 30,
        opacity: isDark ? 0.1 : 0.6,
        backgroundColor: isDark ? Colors.white : Colors.white.withOpacity(0.8),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
        child: Column(
          children: [
            // User Profile Section
            profileState.when(
              data: (user) {
                final displayName = user.name?.isNotEmpty == true ? user.name! : 'Unknown Hero';
                final displayInitial = (user.name?.isNotEmpty == true ? user.name!.substring(0, 1) : user.email.substring(0, 1)).toUpperCase();
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        displayInitial,
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${(user.name?.isNotEmpty == true ? user.name! : user.email.split('@').first).replaceAll(' ', '').toLowerCase()}',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                );
              },
              loading: () => Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isDark ? Colors.white24 : Colors.grey.shade300,
                    child: const CircularProgressIndicator(),
                  ),
                  const SizedBox(height: 16),
                  Text('Loading...', style: TextStyle(color: textColor)),
                ],
              ),
              error: (_, __) => Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: isDark ? Colors.white24 : Colors.grey.shade300,
                    child: Icon(Icons.person, size: 40, color: textColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unknown Hero',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? Colors.white : Colors.black87;
    final inactiveColor = isDark ? Colors.white60 : Colors.black54;
    final bgActiveColor = isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.08);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: isSelected
            ? BoxDecoration(
                color: bgActiveColor,
                borderRadius: BorderRadius.circular(16),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
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
