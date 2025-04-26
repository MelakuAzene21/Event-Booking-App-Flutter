import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/presentation/screens/home_screen.dart';
import 'package:event_booking_app/presentation/screens/event_details_screen.dart';
import 'package:event_booking_app/presentation/screens/login_screen.dart';
import 'package:event_booking_app/presentation/screens/register_screen.dart';
import 'package:event_booking_app/presentation/screens/booking_screen.dart';
import 'package:event_booking_app/presentation/screens/ticket_screen.dart';
import 'package:event_booking_app/presentation/screens/profile_screen.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/event/:id',
        builder: (context, state) => EventDetailsScreen(eventId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/booking/:eventId',
        builder: (context, state) => BookingScreen(eventId: state.pathParameters['eventId']!),
        redirect: (context, state) async {
          final authState = ref.read(authProvider);
          if (!authState.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/tickets',
        builder: (context, state) => const TicketScreen(),
        redirect: (context, state) async {
          final authState = ref.read(authProvider);
          if (!authState.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
        redirect: (context, state) async {
          final authState = ref.read(authProvider);
          if (!authState.isAuthenticated) {
            return '/login';
          }
          return null;
        },
      ),
    ],
  );
});