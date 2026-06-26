import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/responsive_shell.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/report/presentation/screens/report_screen.dart';
import '../../features/feed/presentation/screens/feed_screen.dart';
import '../../features/issue_details/presentation/screens/issue_details_screen.dart';

// --- DUMMY SCREENS (For Navigation Only) ---
class DummyScreen extends StatelessWidget {
  final String title;
  final String? extra;
  const DummyScreen({super.key, required this.title, this.extra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Screen: $title', style: const TextStyle(fontSize: 24)),
            if (extra != null) ...[
              const SizedBox(height: 16),
              Text('Param: $extra', style: const TextStyle(fontSize: 18, color: Colors.grey)),
            ]
          ],
        ),
      ),
    );
  }
}

// --- ROUTER CONFIGURATION ---
final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'homeShell');
final shellNavigatorMapKey = GlobalKey<NavigatorState>(debugLabel: 'mapShell');
final shellNavigatorReportKey = GlobalKey<NavigatorState>(debugLabel: 'reportShell');
final shellNavigatorDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboardShell');
final shellNavigatorProfileKey = GlobalKey<NavigatorState>(debugLabel: 'profileShell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/login', // Defaulting to login for now
    debugLogDiagnostics: true,
    routes: [
      // Auth & Initial Routes
      GoRoute(
        path: '/',
        builder: (context, state) => const DummyScreen(title: 'Splash Screen'),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Stateful Shell Route for Bottom Nav / Nav Rail
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ResponsiveShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Map
          StatefulShellBranch(
            navigatorKey: shellNavigatorMapKey,
            routes: [
              GoRoute(
                path: '/map',
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          // Branch 2: Report
          StatefulShellBranch(
            navigatorKey: shellNavigatorReportKey,
            routes: [
              GoRoute(
                path: '/report',
                builder: (context, state) => const ReportScreen(),
              ),
            ],
          ),
          // Branch 3: Dashboard
          StatefulShellBranch(
            navigatorKey: shellNavigatorDashboardKey,
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            navigatorKey: shellNavigatorProfileKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const DummyScreen(title: 'Profile'),
              ),
            ],
          ),
        ],
      ),

      // Sub-routes and Top-level views (Not in the bottom nav)
      GoRoute(
        path: '/issue-details/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return IssueDetailsScreen(issueId: id);
        },
      ),
      GoRoute(
        path: '/leaderboard',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DummyScreen(title: 'Leaderboard'),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const DummyScreen(title: 'Settings'),
      ),
      GoRoute(
        path: '/feed',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const FeedScreen(),
      ),
    ],
  );
});
