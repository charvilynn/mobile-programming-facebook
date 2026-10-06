import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _indexFromLocation(location);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth >= 768;

        if (isWideScreen) {
          return Scaffold(
            backgroundColor: AppColors.bgDeep,
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (i) => _onNavTap(context, i),
                  backgroundColor: AppColors.bgSurface,
                  indicatorColor: AppColors.cyanGlow,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'PB',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.home_outlined),
                      selectedIcon: Icon(Icons.home, color: AppColors.cyan),
                      label: Text('Beranda'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.chat_bubble_outline),
                      selectedIcon: Icon(Icons.chat_bubble, color: AppColors.cyan),
                      label: Text('PaceChat'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.explore_outlined),
                      selectedIcon: Icon(Icons.explore, color: AppColors.cyan),
                      label: Text('Jelajah'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.notifications_outlined),
                      selectedIcon: Icon(Icons.notifications, color: AppColors.cyan),
                      label: Text('Notifikasi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.person_outline),
                      selectedIcon: Icon(Icons.person, color: AppColors.cyan),
                      label: Text('Profil'),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderSubtle),
                Expanded(child: child),
              ],
            ),
          );
        }

        return Scaffold(
          body: child,
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: NavigationBar(
              selectedIndex: selectedIndex,
              backgroundColor: AppColors.bgSurface,
              indicatorColor: AppColors.cyanGlow,
              height: 64,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.cyan),
                  label: 'Beranda',
                  tooltip: 'Beranda',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.chat_bubble_outline),
                  selectedIcon: Icon(Icons.chat_bubble, color: AppColors.cyan),
                  label: 'PaceChat',
                  tooltip: 'PaceChat',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: Icon(Icons.explore, color: AppColors.cyan),
                  label: 'Jelajah',
                  tooltip: 'Jelajah',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.notifications_outlined),
                  selectedIcon: Icon(Icons.notifications, color: AppColors.cyan),
                  label: 'Notifikasi',
                  tooltip: 'Notifikasi',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person, color: AppColors.cyan),
                  label: 'Profil',
                  tooltip: 'Profil',
                ),
              ],
              onDestinationSelected: (i) => _onNavTap(context, i),
            ),
          ),
        );
      },
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/groups') ||
        location.startsWith('/events') ||
        location.startsWith('/marketplace') ||
        location.startsWith('/search')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; 
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/feed');
        break;
      case 1:
        context.go('/chat');
        break;
      case 2:
        context.go('/search');
        break;
      case 3:
        context.go('/notifications');
        break;
      case 4:
        context.go('/profile/me');
        break;
    }
  }
}