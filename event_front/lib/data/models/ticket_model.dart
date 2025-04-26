import 'package:event_booking_app/data/models/booking_model.dart';
import 'package:event_booking_app/data/models/event_model.dart';
import 'package:event_booking_app/data/models/user_model.dart';

class TicketModel {
  final String id;
  final String bookingId;
  final String eventId;
  final String userId;
  final String ticketNumber;
  final String qrCode;
  final bool isUsed;
  final EventModel? event;
  final BookingModel? booking;
  final UserModel? user;

  TicketModel({
    required this.id,
    required this.bookingId,
    required this.eventId,
    required this.userId,
    required this.ticketNumber,
    required this.qrCode,
    required this.isUsed,
    this.event,
    this.booking,
    this.user,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['_id'],
      bookingId: json['booking']['_id'],
      eventId: json['event']['_id'],
      userId: json['user']['_id'],
      ticketNumber: json['ticketNumber'],
      qrCode: json['qrCode'],
      isUsed: json['isUsed'],
      event: EventModel.fromJson(json['event']),
      booking: BookingModel.fromJson(json['booking']),
      user: UserModel.fromJson(json['user']),
    );
  }
}