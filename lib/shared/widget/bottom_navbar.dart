import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavbar extends StatelessWidget {
  const BottomNavbar({super.key});

  int _indexFromLocation(String location) {
    if (location.startsWith('/courses')) return 1;
    if (location.startsWith('/schedule')) return 2;
    if (location.startsWith('/todos')) return 3;
    return 0; // default -> dashboard/home
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _indexFromLocation(location);

    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            context.go('/dashboard');
            break;
          case 1:
            context.go('/courses');
            break;
          case 2:
            context.go('/schedule');
            break;
          case 3:
            context.go('/todos');
            break;
        }
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.book_outlined), selectedIcon: Icon(Icons.book), label: 'Courses'),
        NavigationDestination(icon: Icon(Icons.schedule_outlined), selectedIcon: Icon(Icons.schedule), label: 'Jadwal'),
        NavigationDestination(icon: Icon(Icons.checklist_outlined), selectedIcon: Icon(Icons.checklist), label: 'Todo'),
      ],
    );
  }
}