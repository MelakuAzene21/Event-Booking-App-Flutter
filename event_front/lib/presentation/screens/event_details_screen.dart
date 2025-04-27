import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';

class EventDetailsScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventDetailsProvider(eventId));
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: eventAsync.when(
        data: (event) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              floating: false,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  event.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'event-${event.id}',
                      child: CachedNetworkImage(
                        imageUrl: event.images.isNotEmpty ? event.images[0] : 'https://via.placeholder.com/300x200',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        radius: 20,
                        child: Icon(
                          event.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.red),
                            const SizedBox(width: 4),
                            Text('${event.likes} Likes'),
                          ],
                        ),
                        Chip(
                          label: Text(event.category),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ).animate().fadeIn(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('MMM dd, yyyy').format(event.eventDate),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          event.eventTime,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event.location.name.isNotEmpty ? event.location.name : 'Location not specified',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                    if (event.location.latitude != null && event.location.longitude != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 32.0),
                        child: Text(
                          'Lat: ${event.location.latitude}, Lon: ${event.location.longitude}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
                    const SizedBox(height: 8),
                    Text(
                      event.description.isNotEmpty ? event.description : 'No description available',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                    const SizedBox(height: 16),
                    Text(
                      'Organizer',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: event.organizer.avatar != null
                            ? NetworkImage(event.organizer.avatar!)
                            : null,
                        child: event.organizer.avatar == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(event.organizer.name),
                      subtitle: Text(event.organizer.email),
                    ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                    if (event.organizer.organizationName != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Organization: ${event.organizer.organizationName}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
                    const SizedBox(height: 16),
                    Text(
                      'Tickets',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(delay: const Duration(milliseconds: 1000)),
                    const SizedBox(height: 8),
                    ...event.ticketTypes.map((ticket) => Card(
                          child: ListTile(
                            title: Text(ticket.name.isNotEmpty ? ticket.name : 'Unnamed Ticket'),
                            subtitle: Text(
                              'Price: \$${ticket.price.toStringAsFixed(2)} | Available: ${ticket.available} / ${ticket.limit}',
                            ),
                          ),
                        ).animate().fadeIn(delay: const Duration(milliseconds: 1100))),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.refresh(eventDetailsProvider(eventId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: eventAsync.when(
        data: (event) => FloatingActionButton.extended(
          onPressed: () {
            if (authState.isAuthenticated) {
              context.push('/booking/${event.id}');
            } else {
              context.push('/login');
            }
          },
          label: const Text('Book Now'),
          icon: const Icon(Icons.event),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ).animate().fadeIn(delay: const Duration(milliseconds: 1200)),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}