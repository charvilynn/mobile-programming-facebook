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
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/chat')) return 1;
    if (location.startsWith('/groups') ||
        location.startsWith('/events') ||
        location.startsWith('/marketplace') ||
        location.startsWith('/search')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0; // default to feed
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/feed');
      case 1: context.go('/chat');
      case 2: context.go('/search');
      case 3: context.go('/notifications');
      case 4: context.go('/profile/me');
    }
  }
}