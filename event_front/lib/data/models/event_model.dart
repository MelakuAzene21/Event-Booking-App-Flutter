import 'dart:convert';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String eventTime;
  final Location location;
  final String category;
  final List<String> images;
  final List<TicketType> ticketTypes;
  final Organizer organizer;
  final int likes;
  final List<String> usersLiked;
  final List<String> bookmarkedBy;
  final String status;
  final bool isBookmarked;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.eventTime,
    required this.location,
    required this.category,
    required this.images,
    required this.ticketTypes,
    required this.organizer,
    required this.likes,
    required this.usersLiked,
    required this.bookmarkedBy,
    required this.status,
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
      location: Location.fromJson(json['location'] as Map<String, dynamic>? ?? {}),
      category: json['category']?.toString() ?? 'General',
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      ticketTypes: (json['ticketTypes'] as List<dynamic>?)
              ?.map((t) => TicketType.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>? ?? {}),
      likes: json['likes'] as int? ?? 0,
      usersLiked: (json['usersLiked'] as List<dynamic>?)?.cast<String>() ?? [],
      bookmarkedBy: (json['bookmarkedBy'] as List<dynamic>?)?.cast<String>() ?? [],
      status: json['status']?.toString() ?? 'pending',
      isBookmarked: json['bookmarkedBy']?.contains(json['user']?.toString()) ?? false,
    );
  }
}

class Location {
  final String name;
  final double? latitude;
  final double? longitude;

  Location({
    required this.name,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class TicketType {
  final String name;
  final double price;
  final int limit;
  final int booked;
  final int available;

  TicketType({
    required this.name,
    required this.price,
    required this.limit,
    required this.booked,
    required this.available,
  });

  factory TicketType.fromJson(Map<String, dynamic> json) {
    return TicketType(
      name: json['name']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      limit: json['limit'] as int? ?? 0,
      booked: json['booked'] as int? ?? 0,
      available: json['available'] as int? ?? 0,
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