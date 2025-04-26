
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
    return EventModel(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['eventDate']),
      eventTime: json['eventTime'],
      location: json['location'],
      category: json['category'] ?? 'General',
      ticketTypes: (json['ticketTypes'] as List)
          .map((t) => TicketType.fromJson(t))
          .toList(),
      organizer: Organizer.fromJson(json['organizer']),
      isBookmarked: json['isBookmarked'] ?? false,
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
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      available: json['available'] ?? 0,
      booked: json['booked'] ?? 0,
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
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      about: json['about'],
      organizationName: json['organizationName'],
    );
  }
}