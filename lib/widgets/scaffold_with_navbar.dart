import 'package:house_pin/screens/main_nav/home_screen.dart';
import 'package:house_pin/screens/main_nav/map_screen.dart';
import 'package:house_pin/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ScaffoldWithNavbar extends StatelessWidget {
  final Widget child;
  final String location;

  const ScaffoldWithNavbar({
    super.key,
    required this.child,
    required this.location,
  });

  int get _selectedIndex {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/map')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final shouldUseRail = ResponsiveUtils.shouldUseRail(context);
    return shouldUseRail
        ? _buildDesktopLayout(context)
        : _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: const [HomeScreen(), MapScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.secondaryContainer,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => _navigateToIndex(context, index),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: colorScheme.onSurfaceVariant,
            ),
            selectedIcon: Icon(Icons.home, color: colorScheme.primary),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined, color: colorScheme.onSurfaceVariant),
            selectedIcon: Icon(Icons.map_rounded, color: colorScheme.primary),
            label: 'Map',
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: colorScheme.surface,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) => _navigateToIndex(context, index),
            labelType: NavigationRailLabelType.all,
            indicatorColor: colorScheme.secondaryContainer,
            selectedIconTheme: IconThemeData(color: colorScheme.primary),
            unselectedIconTheme: IconThemeData(
              color: colorScheme.onSurfaceVariant,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded),
                label: Text('Map'),
              ),
            ],
            leading: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.pin_drop,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pin\nIt',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: const [HomeScreen(), MapScreen()],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/map');
        break;
    }
  }
}
