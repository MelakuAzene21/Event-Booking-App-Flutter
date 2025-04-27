import 'dart:convert';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String eventTime;
  final String location;
  final String category;
  final List<TicketType> ticketTypes;
  final Organizer organizer;
  final bool isBookmarked;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.category,
    required this.ticketTypes,
    required this.organizer,
    this.isBookmarked = false,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    print('Parsing event: $json'); // Debug: Log JSON input
    return EventModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      description: json['description']?.toString() ?? '',
      eventDate: DateTime.tryParse(json['eventDate']?.toString() ?? '') ?? DateTime.now(),
      eventTime: json['eventTime']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      category: json['category'] is String
          ? json['category']
          : json['category']?['name']?.toString() ?? 'General',
      ticketTypes: (json['ticketTypes'] as List<dynamic>?)
              ?.map((t) => TicketType.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>? ?? {}),
      isBookmarked: json['isBookmarked'] as bool? ?? false,
    );
  }
}

class TicketType {
  final String name;
  final double price;
  final int available;
  final int booked;

  TicketType({
    required this.name,
    required this.price,
    required this.available,
    required this.booked,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      available: json['available'] as int? ?? 0,
      booked: json['booked'] as int? ?? 0,
    );
  }
}

class Organizer {
  final String name;
  final String email;
  final String? avatar;
  final String? about;
  final String? organizationName;

  Organizer({
    required this.name,
    required this.email,
    this.avatar,
    this.about,
    this.organizationName,
  });

  factory Organizer.fromJson(Map<String, dynamic> json) {
    return Organizer(
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      about: json['about']?.toString(),
      organizationName: json['organizationName']?.toString(),
    );
  }
}