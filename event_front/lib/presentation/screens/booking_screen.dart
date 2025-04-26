import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/booking_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String eventId;

  const BookingScreen({super.key, required this.eventId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? selectedTicketType;
  int ticketCount = 1;
  bool isPaymentDone = false;
  bool showQrCode = false;
  BookingModel? booking;

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Book Event')),
      body: eventAsync.when(
        data: (event) {
          if (showQrCode && booking != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Booking Successful!', style: TextStyle(fontSize: 20)),
                  QrImageView(
                    data: 'TCK-${booking!.id}-${booking!.userId}-${booking!.eventId}',
                    size: 200,
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/tickets'),
                    child: const Text('View Tickets'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Event: ${event.title}', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text('Select Ticket Type'),
                  value: selectedTicketType,
                  isExpanded: true,
                  items: event.ticketTypes
                      .map((ticket) => DropdownMenuItem(
                            value: ticket.name,
                            child: Text('${ticket.name} (\$${ticket.price})'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedTicketType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Tickets: $ticketCount'),
                Slider(
                  value: ticketCount.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() {
                      ticketCount = value.toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: \$${selectedTicketType != null ? (event.ticketTypes.firstWhere((t) => t.name == selectedTicketType).price * ticketCount).toStringAsFixed(2) : '0.00'}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                if (bookingState.error != null)
                  Text('Error: ${bookingState.error}', style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: selectedTicketType == null
                      ? null
                      : () async {
                          if (!isPaymentDone) {
                            // Mock payment
                            setState(() {
                              isPaymentDone = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Payment Successful (Mocked)')),
                            );
                          } else {
                            final ticketType = event.ticketTypes.firstWhere((t) => t.name == selectedTicketType);
                            final newBooking = BookingModel(
                              id: '',
                              eventId: event.id,
                              userId: '',
                              ticketType: selectedTicketType!,
                              ticketCount: ticketCount,
                              totalAmount: ticketType.price * ticketCount,
                            );
                            await ref.read(bookingProvider.notifier).createBooking(newBooking);
                            setState(() {
                              booking = ref.read(bookingProvider).booking;
                              showQrCode = true;
                            });
                          }
                        },
                  child: Text(isPaymentDone ? 'Confirm Booking' : 'Proceed to Payment'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}