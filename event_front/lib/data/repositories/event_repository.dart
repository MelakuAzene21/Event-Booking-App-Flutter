import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_booking_app/core/config/api_config.dart';
import 'package:event_booking_app/data/models/event_model.dart';

class EventRepository {
  Future<List<EventModel>> getEvents() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventsEndpoint}'),
    );

    print('Raw response body: ${response.body}'); // Debug: Log raw response

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      final List<dynamic> eventList = data is List ? data : data['events'] ?? [];
      if (eventList.isNotEmpty) {
        return eventList.map((json) => EventModel.fromJson(json)).toList();
      } else {
        throw Exception('No events found in response');
      }
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch events');
    }
  }

  Future<EventModel> getEventDetails(String id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.eventDetailsEndpoint}/$id'),
    );

    print('Raw event details response: ${response.body}'); // Debug: Log raw response

    if (response.statusCode == 200) {
      return EventModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Failed to fetch event details');
    }
  }
}