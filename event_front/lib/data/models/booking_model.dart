class BookingModel {
  final String id;
  final String eventId;
  final String userId;
  final String ticketType;
  final int ticketCount;
  final double totalAmount;

  BookingModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketType,
    required this.ticketCount,
    required this.totalAmount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'],
      eventId: json['event'],
      userId: json['user'],
      ticketType: json['ticketType'],
      ticketCount: json['ticketCount'],
      totalAmount: (json['totalAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': eventId,
      'ticketType': ticketType,
      'ticketCount': ticketCount,
      'totalAmount': totalAmount,
    };
  }
}