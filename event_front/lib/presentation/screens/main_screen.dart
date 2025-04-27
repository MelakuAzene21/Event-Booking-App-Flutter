import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/presentation/screens/home_screen.dart';
import 'package:event_booking_app/presentation/screens/favorites_screen.dart';
import 'package:event_booking_app/presentation/screens/tickets_screen.dart';
import 'package:event_booking_app/presentation/screens/notifications_screen.dart';
import 'package:event_booking_app/presentation/screens/profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _selectedIndex;

  final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const TicketsScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  final List<String> _routes = [
    '/',
    '/favorites',
    '/tickets',
    '/notifications',
    '/profile',
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    // Sync selected index with current route
    final currentPath = GoRouterState.of(context).uri.toString();
    final routeIndex = _routes.indexWhere((route) => currentPath == route);
    if (routeIndex != -1 && routeIndex != _selectedIndex) {
      _selectedIndex = routeIndex;
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            activeIcon: Icon(Icons.confirmation_number_outlined),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            activeIcon: Icon(Icons.notifications_active),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
      ),
    );
  }
}