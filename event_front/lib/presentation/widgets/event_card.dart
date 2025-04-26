import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:event_booking_app/data/models/event_model.dart';

class EventCard extends StatelessWidget {
  final EventModel event;

  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text('${DateFormat('MMM dd, yyyy').format(event.eventDate)} | ${event.location}'),
        onTap: () => context.push('/event/${event.id}'),
      ),
    );
  }
}