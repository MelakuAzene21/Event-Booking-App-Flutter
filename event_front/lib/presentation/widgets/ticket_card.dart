import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:event_booking_app/data/models/ticket_model.dart';
import 'package:event_booking_app/domain/providers/ticket_provider.dart';

class TicketCard extends ConsumerWidget {
  final TicketModel ticket;

  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${ticket.event!.title}', style: Theme.of(context).textTheme.titleMedium),
            Text('Ticket: ${ticket.ticketNumber}'),
            Text('Status: ${ticket.isUsed ? 'Used' : 'Valid'}'),
            const SizedBox(height: 8),
            QrImageView(data: ticket.qrCode, size: 100),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  await ref.read(ticketProvider.notifier).deleteTicket(ticket.id);
                  ref.invalidate(ticketsProvider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}