import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_booking_app/domain/providers/ticket_provider.dart';
import 'package:event_booking_app/presentation/widgets/ticket_card.dart';

class TicketScreen extends ConsumerWidget {
  const TicketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(ticketsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Tickets')),
      body: ticketsAsync.when(
        data: (tickets) => ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            return TicketCard(ticket: tickets[index]);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}