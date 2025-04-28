import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/booking_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/core/utils/secure_storage.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String eventId;

  const BookingScreen({super.key, required this.eventId});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? selectedTicketType;
  int ticketCount = 1;
  bool isLoading = false;
  bool showQrCode = false;
  BookingModel? booking;
  String? txRef;

  Future<Map<String, dynamic>?> _getUserProfile() async {
    final token = await SecureStorage.getToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'token=$token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  Future<void> _initializePayment(double amount) async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No token found');

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payment/initialize'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
        body: jsonEncode({
          'amount': amount,
          'currency': 'ETB',
        }),
      );

      if (response.statusCode == 200) {
        final paymentData = jsonDecode(response.body);
        final paymentUrl = paymentData['paymentUrl'];
        txRef = paymentData['tx_ref'];
        if (paymentUrl != null) {
          await launchUrl(Uri.parse(paymentUrl), mode: LaunchMode.externalApplication);
          // After payment, verify the transaction
          await _verifyTransaction();
        } else {
          throw Exception('Payment URL not found');
        }
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing payment: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _verifyTransaction() async {
    if (txRef == null || selectedTicketType == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No token found');

      final userProfile = await _getUserProfile();
      if (userProfile == null) throw Exception('Failed to fetch user profile');

      final userId = userProfile['_id'];
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/payment/verify-transaction/$txRef'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
        body: jsonEncode({
          'eventId': widget.eventId,
          'ticketType': selectedTicketType,
          'ticketCount': ticketCount,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200) {
        final verifyData = jsonDecode(response.body);
        if (verifyData['success']) {
          setState(() {
            booking = BookingModel.fromJson(verifyData['book']);
            showQrCode = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment and booking successful!')),
          );
        } else {
          throw Exception(verifyData['message']);
        }
      } else {
        throw Exception(jsonDecode(response.body)['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying transaction: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: selectedTicketType == null
                        ? null
                        : () async {
                            final ticketType = event.ticketTypes.firstWhere((t) => t.name == selectedTicketType);
                            final totalAmount = ticketType.price * ticketCount;
                            await _initializePayment(totalAmount);
                          },
                    child: const Text('Proceed to Payment'),
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