import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/domain/providers/booking_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
    if (token == null) {
      print('Error: No token found in secure storage');
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': 'token=$token',
        },
      ).timeout(const Duration(seconds: 10));

      print('Profile fetch response: ${response.statusCode}, ${response.body}');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching profile: Status ${response.statusCode}, ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  Future<void> _initializePayment(double amount) async {
    setState(() {
      isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No authentication token found. Please log in again.');

      print('Initializing payment with amount: $amount, currency: ETB');
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
      ).timeout(const Duration(seconds: 10));

      print('Payment initialization response: ${response.statusCode}, ${response.body}');

      if (response.statusCode == 200) {
        final paymentData = jsonDecode(response.body);
        final paymentUrl = paymentData['paymentUrl'];
        txRef = paymentData['tx_ref'];

        if (paymentUrl != null) {
          // Show payment page in an InAppWebView modal
          await _showPaymentModal(paymentUrl);
        } else {
          throw Exception('Payment URL not found in response');
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Failed to initialize payment';
        throw Exception('Server error: $errorMessage');
      }
    } catch (e) {
      print('Error initializing payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initializing payment: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _showPaymentModal(String paymentUrl) async {
    bool paymentSuccessful = false;

    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(paymentUrl)),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                          javaScriptEnabled: true,
                          useShouldOverrideUrlLoading: true,
                        ),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                        ),
                      ),
                      onWebViewCreated: (controller) {
                        print('InAppWebView created');
                      },
                      onLoadStart: (controller, url) {
                        print('InAppWebView loading: $url');
                      },
                      onLoadStop: (controller, url) {
                        print('InAppWebView finished loading: $url');
                      },
                      onLoadError: (controller, url, code, message) {
                        print('InAppWebView error: $code, $message');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error loading payment page: $message')),
                        );
                        Navigator.of(context).pop();
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        final url = navigationAction.request.url.toString();
                        // Detect Chapa success URL (adjust based on Chapa's actual success URL)
                        if (url.contains('success') || url.contains('chapa.co/success')) {
                          paymentSuccessful = true;
                          Navigator.of(context).pop();
                          return NavigationActionPolicy.CANCEL;
                        }
                        // Detect failure or cancel
                        if (url.contains('cancel') || url.contains('error')) {
                          Navigator.of(context).pop();
                          return NavigationActionPolicy.CANCEL;
                        }
                        return NavigationActionPolicy.ALLOW;
                      },
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    // Handle payment result
    if (paymentSuccessful) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful! Verifying transaction...')),
      );
      await _verifyTransaction();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment was cancelled or failed')),
      );
    }
  }

  Future<void> _verifyTransaction() async {
    if (txRef == null || selectedTicketType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Transaction reference or ticket type missing')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token == null) throw Exception('No authentication token found. Please log in again.');

      final userProfile = await _getUserProfile();
      if (userProfile == null) throw Exception('Failed to fetch user profile');

      final userId = userProfile['_id'];
      print('Verifying transaction with txRef: $txRef, userId: $userId');

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
      ).timeout(const Duration(seconds: 10));

      print('Transaction verification response: ${response.statusCode}, ${response.body}');

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
          throw Exception(verifyData['message'] ?? 'Transaction verification failed');
        }
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? 'Failed to verify transaction';
        throw Exception('Server error: $errorMessage');
      }
    } catch (e) {
      print('Error verifying transaction: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying transaction: ${e.toString()}')),
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