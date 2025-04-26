import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailsProvider(eventId));
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Event Details')),
      body: eventAsync.when(
        data: (event) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text('Date: ${DateFormat('MMM dd, yyyy').format(event.eventDate)}'),
                Text('Time: ${event.eventTime}'),
                Text('Location: ${event.location}'),
                Text('Category: ${event.category}'),
                const SizedBox(height: 16),
                Text('Description:', style: Theme.of(context).textTheme.titleMedium),
                Text(event.description),
                const SizedBox(height: 16),
                Text('Organizer: ${event.organizer.name}'),
                Text('Email: ${event.organizer.email}'),
                if (event.organizer.organizationName != null)
                  Text('Organization: ${event.organizer.organizationName}'),
                const SizedBox(height: 16),
                Text('Tickets:', style: Theme.of(context).textTheme.titleMedium),
                ...event.ticketTypes.map((ticket) => ListTile(
                      title: Text(ticket.name),
                      subtitle: Text('Price: \$${ticket.price} | Available: ${ticket.available}'),
                    )),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (authState.isAuthenticated) {
                      context.push('/booking/${event.id}');
                    } else {
                      context.push('/login');
                    }
                  },
                  child: const Text('Book Now'),
                ),
              ],
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}