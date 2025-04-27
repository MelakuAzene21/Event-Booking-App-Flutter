import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/presentation/screens/main_screen.dart';
import 'package:event_booking_app/presentation/screens/home_screen.dart';
import 'package:event_booking_app/presentation/screens/favorites_screen.dart';
import 'package:event_booking_app/presentation/screens/tickets_screen.dart';
import 'package:event_booking_app/presentation/screens/notifications_screen.dart';
import 'package:event_booking_app/presentation/screens/profile_screen.dart';
import 'package:event_booking_app/presentation/screens/event_details_screen.dart';
import 'package:event_booking_app/presentation/screens/login_screen.dart';
import 'package:event_booking_app/presentation/screens/register_screen.dart';
import 'package:event_booking_app/presentation/screens/booking_screen.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainScreen(initialIndex: 0),
        routes: [
          GoRoute(
            path: 'favorites',
            builder: (context, state) => const MainScreen(initialIndex: 1),
          ),
          GoRoute(
            path: 'tickets',
            builder: (context, state) => const MainScreen(initialIndex: 2),
            redirect: (context, state) async {
              final authState = ref.read(authProvider);
              if (!authState.isAuthenticated) {
                return '/login';
              }
              return null;
            },
          ),
          GoRoute(
            path: 'notifications',
            builder: (context, state) => const MainScreen(initialIndex: 3),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const MainScreen(initialIndex: 4),
            redirect: (context, state) async {
              final authState = ref.read(authProvider);
              if (!authState.isAuthenticated) {
                return '/login';
              }
              return null;
            },
          ),
          GoRoute(
            path: 'event/:id',
            builder: (context, state) => EventDetailsScreen(
              eventId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'booking/:eventId',
            builder: (context, state) => BookingScreen(
              eventId: state.pathParameters['eventId']!,
            ),
            redirect: (context, state) async {
              final authState = ref.read(authProvider);
              if (!authState.isAuthenticated) {
                return '/login';
              }
              return null;
            },
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
});